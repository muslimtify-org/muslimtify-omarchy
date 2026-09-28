pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.Commons
import qs.Ui
import "lib/Model.js" as Model
import "services"
import "views"

// qmllint disable missing-property
Panel {
  id: root

  moduleName: "muslimtify-org.muslimtify"
  ipcTarget: "muslimtify-org.muslimtify"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  property bool showRemaining: false
  property bool settingsOpen: false

  readonly property int soonMinutes: Number(root.setting("soonMinutes", 15))
  readonly property string fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
  // The bar sizes the open-panel underline from this, so it spans the label.
  readonly property real openPanelIndicatorWidth: button.labelWidth

  function setSettingsOpen(value) {
    root.settingsOpen = value
    if (value) muslimtify.loadTimezones()
    else Qt.callLater(function() { if (root.opened) keyCatcher.forceActiveFocus() })
  }

  function openLink(url) {
    Quickshell.execDetached(["xdg-open", url])
    root.close()
  }

  onOpenedChanged: if (!root.opened) root.settingsOpen = false

  Muslimtify {
    id: muslimtify
    refreshSeconds: Number(root.setting("interval", 30))
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: button.vertical ? Model.ICONS.mosque : Model.barLabel(muslimtify.next, root.showRemaining)
    active: !!muslimtify.next && muslimtify.next.remaining <= root.soonMinutes
    onPressed: function(pressedButton) {
      if (pressedButton === Qt.RightButton) root.showRemaining = !root.showRemaining
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(root.settingsOpen ? 480 : 380))
    contentHeight: panel.fittedContentHeight(pageLoader.item ? pageLoader.item.implicitHeight : Style.space(320))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: root.settingsOpen

      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      onTextKey: function(text) {
        var key = String(text || "").toLowerCase()
        if (key === "s") root.setSettingsOpen(true)
        else if (key === "r") muslimtify.refresh()
      }

      Loader {
        id: pageLoader
        width: parent.width
        sourceComponent: root.settingsOpen ? settingsPage : todayPage
      }
    }
  }

  Component {
    id: todayPage

    TodayView {
      width: pageLoader.width
      service: muslimtify
      fontFamily: root.fontFamily
      onSettingsRequested: root.setSettingsOpen(true)
      onLinkRequested: function(url) { root.openLink(url) }
    }
  }

  Component {
    id: settingsPage

    SettingsView {
      width: pageLoader.width
      service: muslimtify
      fontFamily: root.fontFamily
      maxBodyHeight: Style.space(520)
      onCloseRequested: root.setSettingsOpen(false)
    }
  }
}
// qmllint enable missing-property
