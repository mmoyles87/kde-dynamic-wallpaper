import QtQuick
import QtQuick.Controls as QtControls2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kquickcontrols as KQuickControls
import org.kde.kirigami as Kirigami
import "../code/timeCalculations.js" as TimeCalc
import "../code/locationDetection.js" as LocationDetection

ColumnLayout {
    id: root
    
    property var configDialog
    property var wallpaperConfiguration: ({})
    property var parentLayout
    
    property alias cfg_Latitude: latitudeSpinBox.realValue
    property alias cfg_Longitude: longitudeSpinBox.realValue
    property alias cfg_LocationMode: locationModeConfig.value
    property alias cfg_UpdateInterval: updateIntervalSpinBox.value
    property alias cfg_ShowDebug: debugCheckBox.checked
    property alias cfg_FillMode: fillModeConfig.value
    
    property alias cfg_DawnImage: dawnImagePath.text
    property alias cfg_EarlyMorningImage: earlyMorningImagePath.text
    property alias cfg_DayImage: dayImagePath.text
    property alias cfg_EveningImage: eveningImagePath.text
    property alias cfg_DuskImage: duskImagePath.text
    property alias cfg_NightImage: nightImagePath.text
    
    // Hidden control for location mode (0=IP geolocation, 1=manual, 2=timezone)
    QtControls2.SpinBox {
        id: locationModeConfig
        visible: false
        value: 0  // Default to IP geolocation mode
    }
    
    Kirigami.FormLayout {
        Layout.fillWidth: true
        
        Kirigami.Separator {
            Kirigami.FormData.label: "Wallpaper Images"
            Kirigami.FormData.isSection: true
        }
        
        // Dawn Image
        RowLayout {
            Kirigami.FormData.label: "Dawn image:"
            
            Rectangle {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 90
                border.color: dawnMouseArea.containsMouse ? "blue" : "gray"
                border.width: 2
                color: "transparent"
                radius: 4
                
                Image {
                    id: dawnPreview
                    anchors.fill: parent
                    anchors.margins: 4
                    fillMode: Image.PreserveAspectCrop
                    source: dawnImagePath.text ? Qt.resolvedUrl(dawnImagePath.text) : ""
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.3
                        visible: parent.status === Image.Error || parent.status === Image.Null
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Click to Select\nDawn Image"
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                // Overlay for click hint
                Rectangle {
                    anchors.fill: parent
                    color: "blue"
                    opacity: dawnMouseArea.containsMouse ? 0.2 : 0
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Click to Change"
                        color: "white"
                        font.pixelSize: 10
                        visible: dawnMouseArea.containsMouse
                    }
                }
                
                MouseArea {
                    id: dawnMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: dawnImageDialog.open()
                }
            }
            
            // Hidden text field for storing the path
            QtControls2.TextField {
                id: dawnImagePath
                visible: false
                text: "/home/matt/projects/kde6-dynamic-wallpaper/images/3.jpg"
                onTextChanged: dawnPreview.source = text ? Qt.resolvedUrl(text) : ""
            }
        }
        
        // Early Morning Image
        RowLayout {
            Kirigami.FormData.label: "Early morning image:"
            
            Rectangle {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 90
                border.color: earlyMorningMouseArea.containsMouse ? "blue" : "gray"
                border.width: 2
                color: "transparent"
                radius: 4
                
                Image {
                    id: earlyMorningPreview
                    anchors.fill: parent
                    anchors.margins: 4
                    fillMode: Image.PreserveAspectCrop
                    source: earlyMorningImagePath.text ? Qt.resolvedUrl(earlyMorningImagePath.text) : ""
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.3
                        visible: parent.status === Image.Error || parent.status === Image.Null
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Click to Select\nEarly Morning Image"
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: "blue"
                    opacity: earlyMorningMouseArea.containsMouse ? 0.2 : 0
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Click to Change"
                        color: "white"
                        font.pixelSize: 10
                        visible: earlyMorningMouseArea.containsMouse
                    }
                }
                
                MouseArea {
                    id: earlyMorningMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: earlyMorningImageDialog.open()
                }
            }
            
            QtControls2.TextField {
                id: earlyMorningImagePath
                visible: false
                text: "/home/matt/projects/kde6-dynamic-wallpaper/images/1.jpg"
                onTextChanged: earlyMorningPreview.source = text ? Qt.resolvedUrl(text) : ""
            }
        }
        
        // Day Image
        RowLayout {
            Kirigami.FormData.label: "Day image:"
            
            Rectangle {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 90
                border.color: dayMouseArea.containsMouse ? "blue" : "gray"
                border.width: 2
                color: "transparent"
                radius: 4
                
                Image {
                    id: dayPreview
                    anchors.fill: parent
                    anchors.margins: 4
                    fillMode: Image.PreserveAspectCrop
                    source: dayImagePath.text ? Qt.resolvedUrl(dayImagePath.text) : ""
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.3
                        visible: parent.status === Image.Error || parent.status === Image.Null
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Click to Select\nDay Image"
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: "blue"
                    opacity: dayMouseArea.containsMouse ? 0.2 : 0
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Click to Change"
                        color: "white"
                        font.pixelSize: 10
                        visible: dayMouseArea.containsMouse
                    }
                }
                
                MouseArea {
                    id: dayMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: dayImageDialog.open()
                }
            }
            
            QtControls2.TextField {
                id: dayImagePath
                visible: false
                text: "/home/matt/projects/kde6-dynamic-wallpaper/images/2.jpg"
                onTextChanged: dayPreview.source = text ? Qt.resolvedUrl(text) : ""
            }
        }
        
        // Evening Image
        RowLayout {
            Kirigami.FormData.label: "Evening image:"
            
            Rectangle {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 90
                border.color: eveningMouseArea.containsMouse ? "blue" : "gray"
                border.width: 2
                color: "transparent"
                radius: 4
                
                Image {
                    id: eveningPreview
                    anchors.fill: parent
                    anchors.margins: 4
                    fillMode: Image.PreserveAspectCrop
                    source: eveningImagePath.text ? Qt.resolvedUrl(eveningImagePath.text) : ""
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.3
                        visible: parent.status === Image.Error || parent.status === Image.Null
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Click to Select\nEvening Image"
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: "blue"
                    opacity: eveningMouseArea.containsMouse ? 0.2 : 0
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Click to Change"
                        color: "white"
                        font.pixelSize: 10
                        visible: eveningMouseArea.containsMouse
                    }
                }
                
                MouseArea {
                    id: eveningMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: eveningImageDialog.open()
                }
            }
            
            QtControls2.TextField {
                id: eveningImagePath
                visible: false
                text: "/home/matt/projects/kde6-dynamic-wallpaper/images/1.jpg"
                onTextChanged: eveningPreview.source = text ? Qt.resolvedUrl(text) : ""
            }
        }
        
        // Dusk Image
        RowLayout {
            Kirigami.FormData.label: "Dusk image:"
            
            Rectangle {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 90
                border.color: duskMouseArea.containsMouse ? "blue" : "gray"
                border.width: 2
                color: "transparent"
                radius: 4
                
                Image {
                    id: duskPreview
                    anchors.fill: parent
                    anchors.margins: 4
                    fillMode: Image.PreserveAspectCrop
                    source: duskImagePath.text ? Qt.resolvedUrl(duskImagePath.text) : ""
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.3
                        visible: parent.status === Image.Error || parent.status === Image.Null
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Click to Select\nDusk Image"
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: "blue"
                    opacity: duskMouseArea.containsMouse ? 0.2 : 0
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Click to Change"
                        color: "white"
                        font.pixelSize: 10
                        visible: duskMouseArea.containsMouse
                    }
                }
                
                MouseArea {
                    id: duskMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: duskImageDialog.open()
                }
            }
            
            QtControls2.TextField {
                id: duskImagePath
                visible: false
                text: "/home/matt/projects/kde6-dynamic-wallpaper/images/3.jpg"
                onTextChanged: duskPreview.source = text ? Qt.resolvedUrl(text) : ""
            }
        }
        
        // Night Image
        RowLayout {
            Kirigami.FormData.label: "Night image:"
            
            Rectangle {
                Layout.preferredWidth: 150
                Layout.preferredHeight: 90
                border.color: nightMouseArea.containsMouse ? "blue" : "gray"
                border.width: 2
                color: "transparent"
                radius: 4
                
                Image {
                    id: nightPreview
                    anchors.fill: parent
                    anchors.margins: 4
                    fillMode: Image.PreserveAspectCrop
                    source: nightImagePath.text ? Qt.resolvedUrl(nightImagePath.text) : ""
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.3
                        visible: parent.status === Image.Error || parent.status === Image.Null
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Click to Select\nNight Image"
                            color: "white"
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    color: "blue"
                    opacity: nightMouseArea.containsMouse ? 0.2 : 0
                    radius: 4
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Click to Change"
                        color: "white"
                        font.pixelSize: 10
                        visible: nightMouseArea.containsMouse
                    }
                }
                
                MouseArea {
                    id: nightMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: nightImageDialog.open()
                }
            }
            
            QtControls2.TextField {
                id: nightImagePath
                visible: false
                text: "/home/matt/projects/kde6-dynamic-wallpaper/images/4.jpg"
                onTextChanged: nightPreview.source = text ? Qt.resolvedUrl(text) : ""
            }
        }
        
        Kirigami.Separator {
            Kirigami.FormData.label: "Display Settings"
            Kirigami.FormData.isSection: true
        }
        
        QtControls2.ComboBox {
            id: fillModeComboBox
            Kirigami.FormData.label: "Scaling:"
            model: [
                "Scaled and Cropped",
                "Scaled",
                "Scaled, Keep Proportions", 
                "Centered",
                "Tiled"
            ]
            currentIndex: 2  // Default to "Scaled, Keep Proportions"
            onCurrentIndexChanged: {
                console.log("FillMode ComboBox changed to", currentIndex)
                fillModeConfig.value = currentIndex
            }
        }
        
        // Hidden control for fill mode
        QtControls2.SpinBox {
            id: fillModeConfig
            visible: false
            value: 2  // Default value
            onValueChanged: {
                console.log("FillMode config changed to", value)
                if (fillModeComboBox.currentIndex !== value) {
                    fillModeComboBox.currentIndex = value
                }
            }
        }
        
        Kirigami.Separator {
            Kirigami.FormData.label: "Location Settings"
            Kirigami.FormData.isSection: true
        }
        
        QtControls2.ButtonGroup {
            id: locationModeGroup
        }
        
        QtControls2.RadioButton {
            id: automaticIPLocationRadio
            Kirigami.FormData.label: "Location mode:"
            text: "Automatic (IP-based geolocation)"
            checked: cfg_LocationMode === 0
            QtControls2.ButtonGroup.group: locationModeGroup
            onCheckedChanged: {
                if (checked) {
                    cfg_LocationMode = 0
                    detectIPLocation()
                }
            }
            Component.onCompleted: {
                console.log("IP geolocation radio button created")
            }
        }
        
        QtControls2.RadioButton {
            id: automaticTimezoneRadio
            text: "Automatic (timezone estimation)"
            checked: cfg_LocationMode === 2
            QtControls2.ButtonGroup.group: locationModeGroup
            onCheckedChanged: {
                if (checked) {
                    cfg_LocationMode = 2
                    detectTimezoneLocation()
                }
            }
            Component.onCompleted: {
                console.log("Timezone radio button created")
            }
        }
        
        QtControls2.RadioButton {
            id: manualLocationRadio
            text: "Manual coordinates"
            checked: cfg_LocationMode === 1
            QtControls2.ButtonGroup.group: locationModeGroup
            onCheckedChanged: {
                if (checked) {
                    cfg_LocationMode = 1
                }
            }
            Component.onCompleted: {
                console.log("Manual location radio button created")
            }
        }
        
        QtControls2.Button {
            Kirigami.FormData.label: ""
            text: "Detect Location from IP"
            visible: automaticIPLocationRadio.checked
            onClicked: detectIPLocation()
        }
        
        QtControls2.Button {
            Kirigami.FormData.label: ""
            text: "Detect Location from Timezone" 
            visible: automaticTimezoneRadio.checked
            onClicked: detectTimezoneLocation()
        }
        
        QtControls2.SpinBox {
            id: latitudeSpinBox
            Kirigami.FormData.label: "Latitude:"
            from: -90000
            to: 90000
            stepSize: 1
            value: 40728  // Default: NYC (40.728)
            enabled: manualLocationRadio.checked
            
            property real realValue: value / 1000
            
            textFromValue: function(value, locale) {
                return (value / 1000).toFixed(3) + "°"
            }
            
            valueFromText: function(text, locale) {
                return Math.round(parseFloat(text.replace('°', '')) * 1000)
            }
        }
        
        QtControls2.SpinBox {
            id: longitudeSpinBox
            Kirigami.FormData.label: "Longitude:"
            from: -180000
            to: 180000
            stepSize: 1
            value: -74006  // Default: NYC (-74.006)
            enabled: manualLocationRadio.checked
            
            property real realValue: value / 1000
            
            textFromValue: function(value, locale) {
                return (value / 1000).toFixed(3) + "°"
            }
            
            valueFromText: function(text, locale) {
                return Math.round(parseFloat(text.replace('°', '')) * 1000)
            }
        }
        
        QtControls2.Label {
            id: locationDisplayLabel
            Kirigami.FormData.label: "Current location:"
            text: {
                if (automaticLocationRadio.checked) {
                    return `Auto: ${LocationDetection.formatCoordinates(latitudeSpinBox.realValue, longitudeSpinBox.realValue)}`
                } else {
                    return LocationDetection.formatCoordinates(latitudeSpinBox.realValue, longitudeSpinBox.realValue)
                }
            }
            opacity: 0.8
            font.pointSize: Kirigami.Theme.smallFont.pointSize
        }
        
        QtControls2.Button {
            Kirigami.FormData.label: "Current Time Information:"
            text: "Show Time Periods"
            onClicked: timeInfoPopup.open()
        }
        
        Kirigami.Separator {
            Kirigami.FormData.label: "Update Settings"
            Kirigami.FormData.isSection: true
        }
        
        QtControls2.SpinBox {
            id: updateIntervalSpinBox
            Kirigami.FormData.label: "Update interval (minutes):"
            from: 1
            to: 60
            value: 5
        }
        
        QtControls2.CheckBox {
            id: debugCheckBox
            Kirigami.FormData.label: "Show debug info:"
            checked: false
        }
    }
    
    // File dialogs for image selection
    FileDialog {
        id: dawnImageDialog
        title: "Select Dawn Wallpaper"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp *.gif *.tiff *.webp)", "All files (*)"]
        onAccepted: {
            dawnImagePath.text = selectedFile.toString().replace("file://", "")
            // Force configuration change notification
            cfg_DawnImage = dawnImagePath.text
        }
    }
    
    FileDialog {
        id: earlyMorningImageDialog
        title: "Select Early Morning Wallpaper"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp *.gif *.tiff *.webp)", "All files (*)"]
        onAccepted: {
            earlyMorningImagePath.text = selectedFile.toString().replace("file://", "")
            cfg_EarlyMorningImage = earlyMorningImagePath.text
        }
    }
    
    FileDialog {
        id: dayImageDialog
        title: "Select Day Wallpaper"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp *.gif *.tiff *.webp)", "All files (*)"]
        onAccepted: {
            dayImagePath.text = selectedFile.toString().replace("file://", "")
            cfg_DayImage = dayImagePath.text
        }
    }
    
    FileDialog {
        id: eveningImageDialog
        title: "Select Evening Wallpaper"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp *.gif *.tiff *.webp)", "All files (*)"]
        onAccepted: {
            eveningImagePath.text = selectedFile.toString().replace("file://", "")
            cfg_EveningImage = eveningImagePath.text
        }
    }
    
    FileDialog {
        id: duskImageDialog
        title: "Select Dusk Wallpaper"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp *.gif *.tiff *.webp)", "All files (*)"]
        onAccepted: {
            duskImagePath.text = selectedFile.toString().replace("file://", "")
            cfg_DuskImage = duskImagePath.text
        }
    }
    
    FileDialog {
        id: nightImageDialog
        title: "Select Night Wallpaper"
        nameFilters: ["Image files (*.jpg *.jpeg *.png *.bmp *.gif *.tiff *.webp)", "All files (*)"]
        onAccepted: {
            nightImagePath.text = selectedFile.toString().replace("file://", "")
            cfg_NightImage = nightImagePath.text
        }
    }
    
    // Time Information Popup
    QtControls2.Popup {
        id: timeInfoPopup
        modal: true
        focus: true
        width: 600
        height: 500
        anchors.centerIn: parent
        
        QtControls2.ScrollView {
            anchors.fill: parent
            anchors.margins: 10
            
            QtControls2.TextArea {
                id: timeInfoText
                readOnly: true
                selectByMouse: true
                wrapMode: TextEdit.WordWrap
                text: getTimePeriodsInfo()
                font.family: "monospace"
                
                function getTimePeriodsInfo() {
                    const lat = latitudeSpinBox.realValue
                    const lon = longitudeSpinBox.realValue
                    const now = new Date()
                    
                    let info = `Location: ${lat.toFixed(3)}°, ${lon.toFixed(3)}°\n`
                    info += `Current Time: ${now.toLocaleString()}\n\n`
                    
                    // Calculate times using TimeCalc
                    const times = TimeCalc.getTwilightTimes(now, lat, lon)
                    
                    if (times) {
                        info += "Today's Time Periods:\n\n"
                        info += `Astronomical Dawn: ${formatTime(times.astronomicalTwilightSunrise)}\n`
                        info += `Civil Dawn: ${formatTime(times.civilTwilightSunrise)}\n`
                        info += `Sunrise: ${formatTime(times.sunrise)}\n`
                        info += `Sunset: ${formatTime(times.sunset)}\n`
                        info += `Civil Dusk: ${formatTime(times.civilTwilightSunset)}\n`
                        info += `Astronomical Dusk: ${formatTime(times.astronomicalTwilightSunset)}\n\n`
                        
                        info += "Wallpaper Periods:\n\n"
                        info += `🌅 Dawn: ${formatTime(times.astronomicalTwilightSunrise)} - ${formatTime(times.civilTwilightSunrise)}\n`
                        info += `🌇 Early Morning: ${formatTime(times.civilTwilightSunrise)} - ${formatTime(times.sunrise + 2)}\n`
                        info += `☀️ Day: ${formatTime(times.sunrise + 2)} - ${formatTime(times.sunset - 1)}\n`
                        info += `🌆 Evening: ${formatTime(times.sunset - 1)} - ${formatTime(times.civilTwilightSunset)}\n`
                        info += `🌇 Dusk: ${formatTime(times.civilTwilightSunset)} - ${formatTime(times.astronomicalTwilightSunset)}\n`
                        info += `🌙 Night: ${formatTime(times.astronomicalTwilightSunset)} - 02:00\n`
                    } else {
                        info += "Unable to calculate times for this location.\n"
                        info += "You may be in a polar region or the coordinates are invalid."
                    }
                    
                    return info
                }
                
                function formatTime(timeDecimal) {
                    const hours = Math.floor(timeDecimal)
                    const minutes = Math.floor((timeDecimal - hours) * 60)
                    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`
                }
            }
        }
        
        QtControls2.Button {
            text: "Close"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 10
            onClicked: timeInfoPopup.close()
        }
        
        QtControls2.Button {
            text: "Refresh"
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 80
            anchors.margins: 10
            onClicked: {
                timeInfoText.text = timeInfoText.getTimePeriodsInfo()
            }
        }
    }
    
    // IP-based location detection function
    function detectIPLocation() {
        console.log("Detecting location via IP geolocation...")
        
        LocationDetection.requestAutomaticLocation(function(location) {
            if (location && LocationDetection.isValidCoordinate(location.lat, location.lon)) {
                // Update the spinboxes with detected coordinates
                latitudeSpinBox.value = Math.round(location.lat * 1000)
                longitudeSpinBox.value = Math.round(location.lon * 1000)
                
                console.log("IP location detected:", location.lat, location.lon)
                locationDisplayLabel.text = `Auto (${location.source}): ${LocationDetection.formatCoordinates(location.lat, location.lon)}`
                
                if (location.city && location.country) {
                    locationDisplayLabel.text += ` - ${location.city}, ${location.country}`
                }
            } else {
                console.log("Failed to detect IP location, using default")
                locationDisplayLabel.text = "Auto: Failed to detect location"
            }
        })
    }
    
    // Timezone-based location detection function  
    function detectTimezoneLocation() {
        console.log("Detecting location from timezone...")
        const location = LocationDetection.getLocationFromTimezone()
        
        if (location && LocationDetection.isValidCoordinate(location.lat, location.lon)) {
            // Update the spinboxes with detected coordinates
            latitudeSpinBox.value = Math.round(location.lat * 1000)
            longitudeSpinBox.value = Math.round(location.lon * 1000)
            
            console.log("Timezone location detected:", location.lat, location.lon)
            locationDisplayLabel.text = `Auto (Timezone): ${LocationDetection.formatCoordinates(location.lat, location.lon)}`
        } else {
            console.log("Failed to detect timezone location, using default")
            locationDisplayLabel.text = "Auto: Failed to detect location"
        }
    }
    
    // Initialize location on component load
    Component.onCompleted: {
        if (automaticIPLocationRadio.checked) {
            detectIPLocation()
        } else if (automaticTimezoneRadio.checked) {
            detectTimezoneLocation()
        }
    }
}
