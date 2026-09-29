#!/bin/bash
# Runs each Model.js argument builder against the real muslimtify in a
# temporary HOME and checks what muslimtify saved. detectArgs and
# gpsArgs(true) need network or gpsd, so this test does not run them.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v muslimtify >/dev/null; then
  echo "skip - muslimtify is not installed"
  exit 0
fi
require_command node
require_command jq

home=$(mktemp -d)
trap 'rm -rf "$home"' EXIT
config="$home/.config/muslimtify/config.json"

m() {
  HOME="$home" XDG_CONFIG_HOME="$home/.config" muslimtify "$@"
}

# Prints the argv a Model.js call returns, one NUL-separated item each.
args() {
  node -e 'const M = require(process.env.ROOT + "/lib/Model.js"); process.stdout.write(eval(process.argv[1]).join("\0"))' "$1"
}

# check <Model.js call> <jq predicate on the saved config>
check() {
  local call="$1" predicate="$2" argv
  mapfile -d '' argv < <(args "$call")
  m "${argv[@]}" >/dev/null 2>&1 || fail "muslimtify accepts $call"
  jq -e "$predicate" "$config" >/dev/null || fail "$call saves $predicate" "$(jq -c . "$config")"
  pass "$call saves $predicate"
}

m location set --lat=21.4225 --long=39.8262 --city=Makkah --country=SA --timezone=Asia/Riyadh >/dev/null

check 'M.coordinatesArgs("-6.9", "107.6")' '.location.latitude == -6.9 and .location.longitude == 107.6 and .location.auto_detect == false'
check 'M.locationArgs("city", "Bandung Kota")' '.location.city == "Bandung Kota"'
check 'M.locationArgs("country", "id")' '.location.country == "ID"'
check 'M.locationArgs("timezone", "Asia/Jakarta")' '.location.timezone == "Asia/Jakarta"'
check 'M.locationArgs("refreshInterval", "3600")' '.location.refresh_interval == 3600'
check 'M.gpsArgs(false)' '.location.use_gps == false'
check 'M.methodArgs("mwl")' '.calculation.method == "mwl"'
check 'M.madzhabArgs("hanafi")' '.calculation.madhab == "hanafi"'
check 'M.prayerEnabledArgs("asr", false)' '.prayers.asr.enabled == false'
check 'M.prayerEnabledArgs("asr", true)' '.prayers.asr.enabled == true'
check 'M.adhanArgs("asr", false)' '.prayers.asr.adhan_enabled == false'
check 'M.adhanArgs("asr", true)' '.prayers.asr.adhan_enabled == true'
check 'M.remindersArgs("asr", [20, 10])' '.prayers.asr.reminders == [20, 10]'
check 'M.offsetArgs("asr", -5)' '.prayers.asr.offset == -5'
check 'M.urgencyArgs("low")' '.notification.urgency == "low"'
check 'M.soundArgs("off")' '.notification.sound == "off"'
check 'M.timeFormatArgs("12")' '.display.time_format == 12'
check 'M.timeFormatArgs("24")' '.display.time_format == 24'

mapfile -d '' argv < <(args 'M.scheduleArgs(1)')
m "${argv[@]}" | jq -e '.prayers.fajr.time' >/dev/null || fail "scheduleArgs(1) prints a schedule"
pass "scheduleArgs(1) prints a schedule"

mapfile -d '' argv < <(args 'M.offsetArgs("asr", 61)')
if m "${argv[@]}" >/dev/null 2>"$home/stderr"; then fail "muslimtify rejects an offset of 61"; fi
grep -q . "$home/stderr" || fail "muslimtify explains a rejected offset on stderr"
pass "muslimtify rejects an offset of 61 with a message on stderr"
