import QtQuick
import qs.Commons

// One line of error text. Hidden while empty.
// qmllint disable missing-property
Text {
  id: root

  property string fontFamily: Style.font.family

  visible: root.text !== ""
  color: Color.urgent
  font.family: root.fontFamily
  font.pixelSize: Style.font.caption
  wrapMode: Text.WordWrap
}
// qmllint enable missing-property
