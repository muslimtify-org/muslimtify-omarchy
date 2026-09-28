import QtQuick
import qs.Commons
import qs.Ui
import "../lib/Model.js" as Model

// Bordered card: next prayer name, its time, the countdown, and progress
// since the previous prayer.
// qmllint disable missing-property
BorderSurface {
  id: root

  property var next: null
  property string fontFamily: Style.font.family

  readonly property color foreground: Color.popups.text
  readonly property color accent: Color.accent

  implicitHeight: content.implicitHeight + Style.spacing.lg * 2
  color: Style.normalFillFor(root.foreground, root.accent)
  borderSpec: Border.controlSpec("normal", root.foreground, root.accent)
  radius: Style.cornerRadius

  Column {
    id: content
    x: Style.spacing.lg
    y: Style.spacing.lg
    width: Math.max(1, root.width - Style.spacing.lg * 2)
    spacing: Style.spacing.xs

    PanelSectionHeader {
      text: root.next ? "Next · " + Model.title(root.next.name) + (root.next.isTomorrow ? " tomorrow" : "") : ""
      foreground: root.foreground
      fontFamily: root.fontFamily
    }

    Item {
      width: parent.width
      implicitHeight: timeText.implicitHeight

      Text {
        id: timeText
        text: root.next ? root.next.time : ""
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.display
        font.bold: true
      }

      Text {
        anchors.right: parent.right
        anchors.baseline: timeText.baseline
        text: root.next ? "in " + Model.formatDuration(root.next.remaining) : ""
        color: root.accent
        font.family: root.fontFamily
        font.pixelSize: Style.font.title
      }
    }

    Item {
      width: parent.width
      height: Style.space(4)

      Rectangle {
        anchors.fill: parent
        color: root.foreground
        opacity: 0.15
      }

      Rectangle {
        width: parent.width * (root.next ? root.next.progress : 0)
        height: parent.height
        color: root.accent
      }
    }
  }
}
// qmllint enable missing-property
