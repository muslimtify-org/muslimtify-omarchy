import QtQuick
import qs.Commons
import qs.Ui
import "../../lib/Model.js" as Model

// One prayer's reminders and offset. Notification and adhan are toggled
// from the Today rows.
// qmllint disable missing-property
Column {
  id: root

  required property var service
  required property string prayer
  property string fontFamily: Style.font.family

  readonly property var prayerConfig: root.service.config.prayers[root.prayer]
  readonly property color foreground: Color.popups.text

  spacing: Style.spacing.md

  PanelSectionHeader {
    text: Model.title(root.prayer)
    foreground: root.foreground
    fontFamily: root.fontFamily
  }

  Row {
    width: parent.width
    spacing: Style.spacing.md

    SettingField {
      width: (parent.width - parent.spacing) * 2 / 3
      label: "Reminders (minutes before)"
      value: Model.formatReminders(root.prayerConfig.reminders)
      placeholder: "30, 15, 5"
      error: root.service.error(root.prayer + ".reminders")
      validate: Model.validateReminders
      fontFamily: root.fontFamily
      onSubmitted: function(text) { root.service.setReminders(root.prayer, Model.parseReminders(text)) }
    }

    SettingField {
      width: (parent.width - parent.spacing) / 3
      label: "Offset (minutes)"
      value: String(root.prayerConfig.offset)
      error: root.service.error(root.prayer + ".offset")
      validate: Model.validateOffset
      fontFamily: root.fontFamily
      onSubmitted: function(text) { root.service.setOffset(root.prayer, text) }
    }
  }
}
// qmllint enable missing-property
