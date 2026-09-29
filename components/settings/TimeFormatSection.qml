import QtQuick
import qs.Commons
import qs.Ui
import "../../lib/Model.js" as Model

// Clock format for every time muslimtify prints. Needs muslimtify v0.4.3.
// qmllint disable missing-property
Column {
  id: root

  required property var service
  property string fontFamily: Style.font.family

  readonly property string current: String(root.service.config.display.time_format)
  readonly property color foreground: Color.popups.text

  spacing: Style.spacing.md

  PanelSectionHeader {
    text: "Time format"
    foreground: root.foreground
    fontFamily: root.fontFamily
  }

  ButtonGroup {
    options: Model.TIME_FORMATS
    value: root.current
    foreground: root.foreground
    fontFamily: root.fontFamily
    onChanged: function(value) {
      if (value !== root.current) root.service.setTimeFormat(value)
    }
  }

  ErrorLine {
    width: parent.width
    text: root.service.error("display.timeFormat")
    fontFamily: root.fontFamily
  }
}
// qmllint enable missing-property
