pragma ComponentBehavior: Bound
import QtQuick
import qs.Commons
import "../lib/Model.js" as Model
import "../components"
import "../components/settings"

// qmllint disable missing-property
FocusScope {
  id: root

  required property var service
  property string fontFamily: Style.font.family
  property real maxBodyHeight: Style.space(520)

  signal closeRequested()

  implicitHeight: page.implicitHeight
  focus: true

  Keys.onEscapePressed: root.closeRequested()
  Keys.onPressed: function(event) {
    if (String(event.text || "").toLowerCase() === "s") {
      root.closeRequested()
      event.accepted = true
    }
  }
  Component.onCompleted: root.forceActiveFocus()

  Column {
    id: page
    width: parent.width
    spacing: Style.spacing.panelGap

    PanelHeader {
      width: parent.width
      title: "Settings"
      meta: "Saved by muslimtify"
      fontFamily: root.fontFamily
      settingsOpen: true
      onRefreshClicked: root.service.refresh()
      onSettingsClicked: root.closeRequested()
    }

    Flickable {
      width: parent.width
      height: Math.min(sections.implicitHeight, root.maxBodyHeight)
      contentHeight: sections.implicitHeight
      clip: true
      boundsBehavior: Flickable.StopAtBounds

      Column {
        id: sections
        width: parent.width
        spacing: Style.spacing.huge

        TimeFormatSection {
          width: parent.width
          service: root.service
          fontFamily: root.fontFamily
        }

        LocationSection {
          width: parent.width
          service: root.service
          fontFamily: root.fontFamily
        }

        CalculationSection {
          width: parent.width
          service: root.service
          fontFamily: root.fontFamily
        }

        Repeater {
          model: Model.PRAYERS

          PrayerSection {
            id: prayerSection

            required property string modelData

            width: sections.width
            service: root.service
            prayer: prayerSection.modelData
            fontFamily: root.fontFamily
          }
        }

        NotificationSection {
          width: parent.width
          service: root.service
          fontFamily: root.fontFamily
        }
      }
    }
  }
}
// qmllint enable missing-property
