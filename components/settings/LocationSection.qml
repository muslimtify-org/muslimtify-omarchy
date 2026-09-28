import QtQuick
import qs.Commons
import qs.Ui
import "../../lib/Model.js" as Model

// qmllint disable missing-property
Column {
  id: root

  required property var service
  property string fontFamily: Style.font.family

  readonly property var location: root.service.config.location
  readonly property color foreground: Color.popups.text
  readonly property color dim: Qt.darker(root.foreground, 1.4)

  spacing: Style.spacing.md

  PanelSectionHeader {
    text: "Location"
    foreground: root.foreground
    fontFamily: root.fontFamily
  }

  Item {
    width: parent.width
    implicitHeight: detectButton.implicitHeight

    Text {
      textFormat: Text.PlainText
      anchors.left: parent.left
      anchors.verticalCenter: parent.verticalCenter
      text: root.location.auto_detect ? "Auto-detected" : "Set manually"
      color: root.dim
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
    }

    Button {
      id: detectButton
      anchors.right: parent.right
      text: "Detect from IP"
      fontFamily: root.fontFamily
      bordered: true
      onClicked: root.service.detectLocation()
    }
  }

  ErrorLine {
    width: parent.width
    text: root.service.error("location.detect")
    fontFamily: root.fontFamily
  }

  Row {
    width: parent.width
    spacing: Style.spacing.md

    SettingField {
      width: (parent.width - parent.spacing) / 2
      label: "Latitude"
      value: String(root.location.latitude)
      error: root.service.error("location.coordinates")
      validate: Model.validateLatitude
      fontFamily: root.fontFamily
      onSubmitted: function(text) { root.service.setCoordinates(text, String(root.location.longitude)) }
    }

    SettingField {
      width: (parent.width - parent.spacing) / 2
      label: "Longitude"
      value: String(root.location.longitude)
      validate: Model.validateLongitude
      fontFamily: root.fontFamily
      onSubmitted: function(text) { root.service.setCoordinates(String(root.location.latitude), text) }
    }
  }

  Text {
    textFormat: Text.PlainText
    width: parent.width
    text: "Changing coordinates clears the city and country and sets the timezone from them."
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    wrapMode: Text.WordWrap
  }

  SearchableDropdown {
    width: parent.width
    label: "Timezone"
    value: root.location.timezone
    options: root.service.timezones.length > 0 ? root.service.timezones : [root.location.timezone]
    fontFamily: root.fontFamily
    onChanged: function(value) {
      if (value !== root.location.timezone) root.service.setLocationField("timezone", value)
    }
  }

  ErrorLine {
    width: parent.width
    text: root.service.error("location.timezone")
    fontFamily: root.fontFamily
  }

  Row {
    width: parent.width
    spacing: Style.spacing.md

    SettingField {
      width: (parent.width - parent.spacing) * 2 / 3
      label: "City"
      value: root.location.city
      error: root.service.error("location.city")
      fontFamily: root.fontFamily
      onSubmitted: function(text) { root.service.setLocationField("city", text) }
    }

    SettingField {
      width: (parent.width - parent.spacing) / 3
      label: "Country"
      value: root.location.country
      error: root.service.error("location.country")
      validate: Model.validateCountry
      fontFamily: root.fontFamily
      onSubmitted: function(text) { root.service.setLocationField("country", text) }
    }
  }

  SettingField {
    width: parent.width
    label: "Refresh interval (seconds, 0 turns it off)"
    value: String(root.location.refresh_interval)
    error: root.service.error("location.refreshInterval")
    validate: Model.validateRefreshInterval
    fontFamily: root.fontFamily
    onSubmitted: function(text) { root.service.setLocationField("refreshInterval", text) }
  }

  Toggle {
    width: parent.width
    label: "Use GPS"
    description: "Read the location from gpsd"
    checked: root.location.use_gps
    fontFamily: root.fontFamily
    onClicked: root.service.setGps(!root.location.use_gps)
  }

  ErrorLine {
    width: parent.width
    text: root.service.error("location.gps")
    fontFamily: root.fontFamily
  }
}
// qmllint enable missing-property
