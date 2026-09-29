#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const M = requireFromRoot('lib/Model.js')
const fixture = name => fs.readFileSync(path.join(root, 'test/fixtures', name), 'utf8')
const close = (a, b) => Math.abs(a - b) < 1e-9

// Parsing real muslimtify output
const showText = fixture('show.json')
const show = JSON.parse(showText)
const schedule = M.parseSchedule(showText)
assert(schedule !== null, 'parseSchedule reads show --json')
assertDeepEqual(schedule.prayers.map(p => p.name), M.PRAYERS, 'parseSchedule keeps prayer order')
assertDeepEqual(schedule.prayers.map(p => p.time), M.PRAYERS.map(n => show.prayers[n].time), 'parseSchedule keeps each time')
assertEqual(schedule.date, show.date, 'parseSchedule keeps the date')
assert(M.parseSchedule(fixture('show-tomorrow.json')) !== null, 'parseSchedule reads show --json --day-offset 1')
assertEqual(M.parseSchedule('not json'), null, 'parseSchedule rejects invalid JSON')
assertEqual(M.parseSchedule('{"prayers":{}}'), null, 'parseSchedule rejects missing prayers')

const config = M.parseConfig(fixture('config.json'))
assertEqual(config.location.city, 'Makkah', 'parseConfig reads the city')
assertEqual(config.location.country, 'SA', 'parseConfig reads the country')
assertEqual(config.calculation.method, 'makkah', 'parseConfig reads the method')
assert(Array.isArray(config.prayers.fajr.reminders), 'parseConfig keeps reminders as a list')
assertEqual(M.parseConfig('{'), null, 'parseConfig rejects invalid JSON')
assertDeepEqual(M.parseConfig(''), M.defaultConfig(), 'parseConfig falls back to defaults for a missing file')
assertEqual(M.parseConfig('{"location":{"city":7}}').location.city, '', 'parseConfig ignores a value of the wrong type')

const methodsText = fixture('methods.txt')
const methods = M.parseMethods(methodsText)
assertEqual(methods.length, methodsText.split('\n').filter(l => /^  \S/.test(l)).length, 'parseMethods reads every method line')
assertDeepEqual(methods.filter(m => m.current).map(m => m.value), ['makkah'], 'parseMethods marks the current method')
assert(methods.every(m => m.label !== '' && m.label[0] !== '*'), 'parseMethods strips the current marker from labels')

assertDeepEqual(M.parseLines(' a \n\n b\n'), ['a', 'b'], 'parseLines trims and drops blank lines')
assertEqual(M.errorLine('Detecting location...\nError: no network\n'), 'Error: no network', 'errorLine prefers the Error line')
assertEqual(M.errorLine('GPS: cannot reach gpsd.\n'), 'GPS: cannot reach gpsd.', 'errorLine falls back to the last line')
assertEqual(M.errorLine(''), '', 'errorLine is empty for empty stderr')

// Time helpers
assertEqual(M.toMinutes('7:05'), 425, 'toMinutes reads a one-digit hour')
assertEqual(M.toMinutes('24:00'), -1, 'toMinutes rejects hour 24')
assertEqual(M.toMinutes('ab'), -1, 'toMinutes rejects text')
assertEqual(M.toMinutes('04:24 AM'), 264, 'toMinutes reads a 12-hour morning time')
assertEqual(M.toMinutes('02:53 PM'), 893, 'toMinutes reads a 12-hour afternoon time')
assertEqual(M.toMinutes('12:05 AM'), 5, 'toMinutes reads 12 AM as midnight')
assertEqual(M.toMinutes('12:30 PM'), 750, 'toMinutes reads 12 PM as noon')
assertEqual(M.toMinutes('11:59 PM'), 1439, 'toMinutes reads the last minute of the day')
assertEqual(M.toMinutes('13:00 PM'), -1, 'toMinutes rejects hour 13 with PM')
assertEqual(M.toMinutes('00:10 AM'), -1, 'toMinutes rejects hour 0 with AM')
const show12Text = fixture('show-12h.json')
const show12 = JSON.parse(show12Text)
const schedule12 = M.parseSchedule(show12Text)
assert(schedule12 !== null, 'parseSchedule reads 12-hour show --json')
assertDeepEqual(schedule12.prayers.map(p => p.time), M.PRAYERS.map(n => show12.prayers[n].time), 'parseSchedule keeps each 12-hour time as printed')
assert(schedule12.prayers.every((p, i, all) => i === 0 || p.minutes > all[i - 1].minutes), 'parseSchedule orders 12-hour prayers through the day')
assertEqual(M.formatDuration(0), '00:00', 'formatDuration pads zero')
assertEqual(M.formatDuration(511), '08:31', 'formatDuration formats hours and minutes')
assertEqual(M.formatDuration(-5), '00:00', 'formatDuration clamps negatives')

const monday = new Date(2026, 8, 28, 10, 0)
assertEqual(M.minutesOfDay(monday), 600, 'minutesOfDay counts from midnight')
assertEqual(M.subtitle(monday, { location: { city: '', timezone: 'Asia/Jakarta' } }), 'Monday 28 Sep · Jakarta', 'subtitle uses the timezone city when no city is set')
assertEqual(M.subtitle(monday, { location: { city: 'Bandung Kota', timezone: 'Asia/Jakarta' } }), 'Monday 28 Sep · Bandung Kota', 'subtitle prefers the city')
assertEqual(M.subtitle(monday, { location: { city: '', timezone: 'America/New_York' } }), 'Monday 28 Sep · New York', 'subtitle turns underscores into spaces')
assertEqual(M.subtitle(monday, { location: { city: '', timezone: '' } }), 'Monday 28 Sep', 'subtitle drops the place when none is known')

// Next prayer on a synthetic day
const makeDay = (date, fajr) => M.parseSchedule(JSON.stringify({ date, prayers: {
  fajr: { time: fajr }, dhuhr: { time: '12:00' }, asr: { time: '15:15' },
  maghrib: { time: '18:00' }, isha: { time: '19:15' } } }))
const day = makeDay('2026-09-28', '04:30')
const nextDay = makeDay('2026-09-29', '04:31')

let next = M.nextPrayer(day, nextDay, 200)
assertEqual(next.name, 'fajr', 'before Fajr the next prayer is Fajr')
assertEqual(next.remaining, 70, 'before Fajr the countdown runs to Fajr')
assert(close(next.progress, 485 / 555), 'before Fajr progress counts from Isha')

next = M.nextPrayer(day, nextDay, 800)
assertEqual(next.name, 'asr', 'between Dhuhr and Asr the next prayer is Asr')
assertEqual(next.remaining, 115, 'between Dhuhr and Asr the countdown runs to Asr')
assert(close(next.progress, 80 / 195), 'between Dhuhr and Asr progress counts from Dhuhr')
assertEqual(next.isTomorrow, false, 'Asr is today')

next = M.nextPrayer(day, nextDay, 720)
assertEqual(next.name, 'asr', 'at the minute of Dhuhr the next prayer is Asr')
assertEqual(next.progress, 0, 'progress is zero at the minute of a prayer')

next = M.nextPrayer(day, nextDay, 1200)
assertEqual(next.name, 'fajr', 'after Isha the next prayer is Fajr')
assertEqual(next.time, '04:31', "after Isha the time is tomorrow's Fajr")
assertEqual(next.isTomorrow, true, 'after Isha the next prayer is tomorrow')
assertEqual(next.remaining, 511, 'after Isha the countdown crosses midnight')
assert(close(next.progress, 45 / 556), 'after Isha progress counts from Isha')

assertEqual(M.nextPrayer(day, null, 1200), null, 'after Isha without tomorrow there is no next prayer')
assertEqual(M.nextPrayer(null, nextDay, 800), null, 'without today there is no next prayer')

const asrNext = M.nextPrayer(day, nextDay, 800)
assertDeepEqual(day.prayers.map(p => M.prayerState(p, asrNext, 800)), ['past', 'past', 'next', 'upcoming', 'upcoming'], 'prayerState marks past, next and upcoming')
const afterIsha = M.nextPrayer(day, nextDay, 1200)
assertDeepEqual(day.prayers.map(p => M.prayerState(p, afterIsha, 1200)), ['past', 'past', 'past', 'past', 'past'], 'after Isha every prayer today is past')

assertEqual(M.barLabel(asrNext, false), 'Asr 15:15', 'barLabel shows the time as plain text')
assertEqual(M.barLabel(asrNext, true), 'Asr -01:55', 'barLabel shows the countdown as plain text')
assertEqual(M.barLabel(null, false), M.ICONS.mosque, 'barLabel shows only the icon without a next prayer')

// Validators
assertEqual(M.validateLatitude('90'), '', 'latitude 90 is valid')
assertEqual(M.validateLatitude('-90'), '', 'latitude -90 is valid')
assert(M.validateLatitude('90.1') !== '', 'latitude 90.1 is invalid')
assert(M.validateLatitude('abc') !== '', 'latitude text is invalid')
assert(M.validateLatitude('') !== '', 'empty latitude is invalid')
assertEqual(M.validateLongitude('180'), '', 'longitude 180 is valid')
assert(M.validateLongitude('180.5') !== '', 'longitude 180.5 is invalid')
assertEqual(M.validateOffset('60'), '', 'offset 60 is valid')
assertEqual(M.validateOffset('-60'), '', 'offset -60 is valid')
assertEqual(M.validateOffset('+4'), '', 'offset +4 is valid')
assert(M.validateOffset('61') !== '', 'offset 61 is invalid')
assert(M.validateOffset('1.5') !== '', 'a fractional offset is invalid')
assertEqual(M.validateCountry('id'), '', 'a two-letter country is valid')
assert(M.validateCountry('IDN') !== '', 'a three-letter country is invalid')
assert(M.validateCountry('') !== '', 'an empty country is invalid')
assertEqual(M.validateRefreshInterval('0'), '', 'refresh interval 0 is valid')
assertEqual(M.validateRefreshInterval('3600'), '', 'refresh interval 3600 is valid')
assert(M.validateRefreshInterval('3599') !== '', 'refresh interval 3599 is invalid')
assert(M.validateRefreshInterval('-1') !== '', 'a negative refresh interval is invalid')
assertDeepEqual(M.parseReminders('30, 15, 5'), [30, 15, 5], 'parseReminders reads a list')
assertDeepEqual(M.parseReminders('10'), [10], 'parseReminders reads one value')
assertEqual(M.parseReminders(''), null, 'parseReminders rejects an empty list')
assertEqual(M.parseReminders('30,,5'), null, 'parseReminders rejects an empty item')
assertEqual(M.parseReminders('0'), null, 'parseReminders rejects zero')
assertEqual(M.formatReminders([30, 15, 5]), '30, 15, 5', 'formatReminders joins with commas')

// CLI arguments
assertDeepEqual(M.scheduleArgs(0), ['show', '--json'], 'scheduleArgs for today')
assertDeepEqual(M.scheduleArgs(1), ['show', '--json', '--day-offset', '1'], 'scheduleArgs for tomorrow')
assertDeepEqual(M.coordinatesArgs(' -6.9 ', '107.6'), ['location', 'set', '--lat=-6.9', '--long=107.6'], 'coordinatesArgs trims both values')
assertDeepEqual(M.locationArgs('city', 'Bandung Kota'), ['location', 'set', '--city=Bandung Kota'], 'locationArgs keeps spaces in one argument')
assertDeepEqual(M.locationArgs('country', 'id'), ['location', 'set', '--country=ID'], 'locationArgs uppercases the country')
assertDeepEqual(M.locationArgs('refreshInterval', '3600'), ['location', 'set', '--refresh-interval=3600'], 'locationArgs maps the refresh interval')
let threw = false
try { M.locationArgs('nope', 'x') } catch (error) { threw = true }
assert(threw, 'locationArgs rejects an unknown field')
assertDeepEqual(M.detectArgs(), ['location', 'set', '--auto'], 'detectArgs')
assertDeepEqual(M.gpsArgs(true), ['location', 'gps', 'on'], 'gpsArgs on')
assertDeepEqual(M.methodArgs('mwl'), ['method', 'mwl'], 'methodArgs')
assertDeepEqual(M.madzhabArgs('hanafi'), ['madzhab', 'hanafi'], 'madzhabArgs')
assertDeepEqual(M.prayerEnabledArgs('asr', false), ['notification', 'disable', 'asr'], 'prayerEnabledArgs off')
assertDeepEqual(M.adhanArgs('asr', true), ['notification', '--adhan', 'enable', 'asr'], 'adhanArgs on')
assertDeepEqual(M.remindersArgs('asr', [20, 10]), ['notification', '--reminder', 'asr', '20', '10'], 'remindersArgs')
assertDeepEqual(M.offsetArgs('asr', '-5'), ['offset', 'asr', '-5'], 'offsetArgs')
assertDeepEqual(M.urgencyArgs('low'), ['notification', '--urgency', 'low'], 'urgencyArgs')
assertDeepEqual(M.soundArgs('off'), ['notification', '--sound', 'off'], 'soundArgs')
JS
