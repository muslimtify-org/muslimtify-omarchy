import QtQuick
import qs.Commons
import qs.Ui
import "../../lib/Model.js" as Model

// qmllint disable missing-property
Column {
  id: root

  required property var service
  property string fontFamily: Style.font.family

  readonly property var notification: root.service.config.notification
  readonly property color foreground: Color.popups.text

  spacing: Style.spacing.md

  PanelSectionHeader {
    text: "Notifications"
    foreground: root.foreground
    fontFamily: root.fontFamily
  }

  Dropdown {
    width: parent.width
    label: "Urgency"
    value: root.notification.urgency
    options: Model.URGENCIES
    fontFamily: root.fontFamily
    onChanged: function(value) {
      if (value !== root.notification.urgency) root.service.setUrgency(value)
    }
  }

  ErrorLine {
    width: parent.width
    text: root.service.error("notification.urgency")
    fontFamily: root.fontFamily
  }

  Dropdown {
    width: parent.width
    label: "Sound"
    value: root.notification.sound
    options: Model.SOUNDS
    fontFamily: root.fontFamily
    onChanged: function(value) {
      if (value !== root.notification.sound) root.service.setSound(value)
    }
  }

  ErrorLine {
    width: parent.width
    text: root.service.error("notification.sound")
    fontFamily: root.fontFamily
  }
}
// qmllint enable missing-property
