pragma ComponentBehavior: Bound
import QtQuick
import qs.Commons
import qs.Ui
import "../lib/Model.js" as Model

// The GitHub and website links, right-aligned. Hover shows the URL.
// qmllint disable missing-property
Item {
  id: root

  property string fontFamily: Style.font.family

  signal linkRequested(string url)

  readonly property color foreground: Color.popups.text
  readonly property color accent: Color.accent

  implicitHeight: links.implicitHeight

  Row {
    id: links
    anchors.right: parent.right
    spacing: Style.spacing.xl

    Repeater {
      model: [
        { icon: Model.ICONS.github, label: "Star on GitHub", url: Model.LINKS.github },
        { icon: Model.ICONS.website, label: "Website", url: Model.LINKS.website }
      ]

      Text {
        textFormat: Text.PlainText
        id: link

        required property var modelData

        text: link.modelData.icon + " " + link.modelData.label
        color: mouse.containsMouse ? root.accent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.body

        MouseArea {
          id: mouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.linkRequested(link.modelData.url)
        }

        PanelToolTip {
          visible: mouse.containsMouse
          text: link.modelData.url
          fontFamily: root.fontFamily
        }
      }
    }
  }
}
// qmllint enable missing-property
