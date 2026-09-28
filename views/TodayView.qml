pragma ComponentBehavior: Bound
import QtQuick
import qs.Commons
import qs.Ui
import "../lib/Model.js" as Model
import "../components"

// qmllint disable missing-property
Column {
  id: root

  required property var service
  property string fontFamily: Style.font.family

  signal settingsRequested()
  signal linkRequested(string url)

  readonly property color foreground: Color.popups.text
  readonly property int nowMinutes: Model.minutesOfDay(root.service.now)

  spacing: Style.spacing.panelGap

  PanelHeader {
    width: parent.width
    title: "Muslimtify"
    meta: root.service.scheduleError !== "" ? root.service.scheduleError : Model.subtitle(root.service.now, root.service.config)
    fontFamily: root.fontFamily
    onRefreshClicked: root.service.refresh()
    onSettingsClicked: root.settingsRequested()
  }

  Text {
    textFormat: Text.PlainText
    visible: root.service.missing
    width: parent.width
    text: "muslimtify not found. Install it from " + Model.LINKS.website
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.body
    wrapMode: Text.WordWrap
  }

  NextPrayerCard {
    visible: !root.service.missing && !!root.service.next
    width: parent.width
    next: root.service.next
    fontFamily: root.fontFamily
  }

  Column {
    visible: !root.service.missing && !!root.service.today
    width: parent.width
    spacing: Style.spacing.xs

    PanelSectionHeader {
      text: "Today"
      foreground: root.foreground
      fontFamily: root.fontFamily
    }

    Repeater {
      model: root.service.today ? root.service.today.prayers : []

      PrayerRow {
        id: row

        required property var modelData

        readonly property var prayerConfig: root.service.config.prayers[row.modelData.name]

        width: parent.width
        name: Model.title(row.modelData.name)
        time: row.modelData.time
        status: Model.prayerState(row.modelData, root.service.next, root.nowMinutes)
        notifyOn: row.prayerConfig.enabled
        adhanOn: row.prayerConfig.adhan_enabled
        fontFamily: root.fontFamily
        onNotifyToggled: root.service.setPrayerEnabled(row.modelData.name, !row.prayerConfig.enabled)
        onAdhanToggled: root.service.setAdhan(row.modelData.name, !row.prayerConfig.adhan_enabled)
      }
    }
  }

  PanelSeparator {
    visible: !root.service.missing
    width: parent.width
    foreground: root.foreground
  }

  FooterLinks {
    visible: !root.service.missing
    width: parent.width
    fontFamily: root.fontFamily
    onLinkRequested: function(url) { root.linkRequested(url) }
  }
}
// qmllint enable missing-property
