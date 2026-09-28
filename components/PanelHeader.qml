pragma ComponentBehavior: Bound
import QtQuick
import qs.Commons
import qs.Ui
import "../lib/Model.js" as Model

// Icon, title and subtitle, with the refresh and settings buttons on the
// right. Shared by both pages.
// qmllint disable missing-property
Row {
  id: root

  property string title: ""
  property string meta: ""
  property string fontFamily: Style.font.family
  property bool settingsOpen: false

  signal refreshClicked()
  signal settingsClicked()

  readonly property color foreground: Color.popups.text
  readonly property color accent: Color.accent

  spacing: Style.spacing.md

  PanelHero {
    width: Math.max(1, root.width - actions.implicitWidth - root.spacing)
    anchors.verticalCenter: parent.verticalCenter
    iconComponent: logo
    title: root.title
    meta: root.meta
    foreground: root.foreground
    fontFamily: root.fontFamily
  }

  Row {
    id: actions
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.spacing.sm

    PanelActionButton {
      iconText: Model.ICONS.refresh
      tooltipText: "Refresh"
      foreground: root.foreground
      hoverColor: root.accent
      fontFamily: root.fontFamily
      bordered: true
      onClicked: root.refreshClicked()
    }

    PanelActionButton {
      iconText: Model.ICONS.settings
      tooltipText: root.settingsOpen ? "Close settings" : "Settings"
      foreground: root.settingsOpen ? root.accent : root.foreground
      hoverColor: root.accent
      fontFamily: root.fontFamily
      bordered: true
      onClicked: root.settingsClicked()
    }
  }

  Component {
    id: logo

    Item {
      implicitWidth: Style.space(32)
      implicitHeight: Style.space(32)

      Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("../assets/muslimtify.png")
        sourceSize: Qt.size(Style.space(64), Style.space(64))
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
      }
    }
  }
}
// qmllint enable missing-property
