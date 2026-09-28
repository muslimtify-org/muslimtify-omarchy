import QtQuick
import qs.Commons
import qs.Ui

// A labelled text field that shows the saved value, validates on Enter or
// when focus leaves, and emits `submitted` only for a new, valid value.
// It returns to the saved value when muslimtify rejects a change.
// qmllint disable missing-property
Column {
  id: root

  property string label: ""
  property string value: ""
  property string error: ""
  property string placeholder: ""
  property var validate: null
  property string fontFamily: Style.font.family

  signal submitted(string text)

  property string localError: ""
  readonly property string shownError: root.localError !== "" ? root.localError : root.error
  readonly property color foreground: Color.popups.text

  spacing: Style.spacing.labelGap

  function submit() {
    var text = input.text.trim()
    if (text === root.value) {
      root.localError = ""
      return
    }
    root.localError = root.validate ? root.validate(text) : ""
    if (root.localError === "") root.submitted(text)
  }

  onValueChanged: if (!input.activeFocus) input.text = root.value
  onErrorChanged: if (root.error !== "") input.text = root.value
  Component.onCompleted: input.text = root.value

  Text {
    visible: root.label !== ""
    text: root.label
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
  }

  TextField {
    id: input
    width: parent.width
    placeholderText: root.placeholder
    foreground: root.shownError !== "" ? Color.urgent : root.foreground
    font.family: root.fontFamily
    onEditingFinished: root.submit()
  }

  ErrorLine {
    width: parent.width
    text: root.shownError
    fontFamily: root.fontFamily
  }
}
// qmllint enable missing-property
