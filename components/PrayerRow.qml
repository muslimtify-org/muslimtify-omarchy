import QtQuick
import qs.Commons
import qs.Ui
import "../lib/Model.js" as Model

// One prayer on the Today page: name, time, and two icons that toggle
// its notification and adhan. The next prayer sits in a box drawn with
// Omarchy's selected style. Every row keeps the same padding, so the list
// does not shift when the box moves.
// qmllint disable missing-property
BorderSurface {
  id: root

  property string name: ""
  property string time: ""
  property string status: "upcoming"
  property bool notifyOn: true
  property bool adhanOn: true
  property string fontFamily: Style.font.family

  signal notifyToggled()
  signal adhanToggled()

  readonly property color foreground: Color.popups.text
  readonly property color accent: Color.accent
  // Same dim as the header subtitle. The theme's muted token is unreadable on dark themes.
  readonly property color dim: Qt.darker(root.foreground, 1.4)
  readonly property bool isNext: root.status === "next"
  readonly property color textColor: root.isNext ? root.accent : (root.status === "past" ? root.dim : root.foreground)

  implicitHeight: Math.max(nameText.implicitHeight, icons.implicitHeight) + Style.spacing.xs * 2
  color: root.isNext ? Style.selectedFillFor(root.foreground, root.accent) : "transparent"
  borderSpec: root.isNext ? Border.controlSpec("selected", root.foreground, root.accent) : Border.none()
  radius: Style.cornerRadius

  Text {
    textFormat: Text.PlainText
    id: nameText
    anchors.left: parent.left
    anchors.leftMargin: Style.spacing.md
    anchors.verticalCenter: parent.verticalCenter
    width: Style.space(90)
    text: root.name
    color: root.textColor
    font.family: root.fontFamily
    font.pixelSize: Style.font.body
    font.bold: root.isNext
  }

  Text {
    textFormat: Text.PlainText
    anchors.left: nameText.right
    anchors.verticalCenter: parent.verticalCenter
    text: root.time
    color: root.textColor
    font.family: root.fontFamily
    font.pixelSize: Style.font.body
    font.bold: root.isNext
  }

  Row {
    id: icons
    anchors.right: parent.right
    anchors.rightMargin: Style.spacing.sm
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.spacing.sm

    PanelActionButton {
      iconText: root.notifyOn ? Model.ICONS.bell : Model.ICONS.bellOff
      tooltipText: root.notifyOn ? "Notifications on" : "Notifications off"
      foreground: root.notifyOn ? root.foreground : root.dim
      hoverColor: root.accent
      fontFamily: root.fontFamily
      onClicked: root.notifyToggled()
    }

    PanelActionButton {
      iconText: root.adhanOn ? Model.ICONS.adhan : Model.ICONS.adhanOff
      tooltipText: root.adhanOn ? "Adhan on" : "Adhan off"
      foreground: root.adhanOn ? root.foreground : root.dim
      hoverColor: root.accent
      fontFamily: root.fontFamily
      onClicked: root.adhanToggled()
    }
  }
}
// qmllint enable missing-property
