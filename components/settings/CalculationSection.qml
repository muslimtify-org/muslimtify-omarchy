import QtQuick
import qs.Commons
import qs.Ui
import "../../lib/Model.js" as Model

// qmllint disable missing-property
Column {
  id: root

  required property var service
  property string fontFamily: Style.font.family

  readonly property var calculation: root.service.config.calculation
  readonly property color foreground: Color.popups.text

  spacing: Style.spacing.md

  PanelSectionHeader {
    text: "Calculation"
    foreground: root.foreground
    fontFamily: root.fontFamily
  }

  SearchableDropdown {
    width: parent.width
    label: "Method"
    value: root.calculation.method
    options: root.service.methods.length > 0 ? root.service.methods : [root.calculation.method]
    fontFamily: root.fontFamily
    onChanged: function(value) {
      if (value !== root.calculation.method) root.service.setMethod(value)
    }
  }

  ErrorLine {
    width: parent.width
    text: root.service.error("calculation.method")
    fontFamily: root.fontFamily
  }

  Dropdown {
    width: parent.width
    label: "Madzhab"
    value: root.calculation.madhab
    options: Model.MADZHABS
    fontFamily: root.fontFamily
    onChanged: function(value) {
      if (value !== root.calculation.madhab) root.service.setMadzhab(value)
    }
  }

  ErrorLine {
    width: parent.width
    text: root.service.error("calculation.madzhab")
    fontFamily: root.fontFamily
  }
}
// qmllint enable missing-property
