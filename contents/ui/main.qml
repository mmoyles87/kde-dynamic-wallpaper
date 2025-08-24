import QtQuick 2.0
import QtQuick.Controls 2.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import "../code/timeCalculations.js" as TimeCalc

WallpaperItem {
    id: root
    
    // Location settings with default values
    property real latitude: wallpaper.configuration.Latitude !== undefined ? wallpaper.configuration.Latitude : 40.7128
    property real longitude: wallpaper.configuration.Longitude !== undefined ? wallpaper.configuration.Longitude : -74.0060
    
    // Image paths configuration with fallbacks
    property string dawnImage: wallpaper.configuration.DawnImage || "/home/matt/projects/kde6-dynamic-wallpaper/images/3.jpg"
    property string earlyMorningImage: wallpaper.configuration.EarlyMorningImage || "/home/matt/projects/kde6-dynamic-wallpaper/images/1.jpg"
    property string dayImage: wallpaper.configuration.DayImage || "/home/matt/projects/kde6-dynamic-wallpaper/images/2.jpg"
    property string eveningImage: wallpaper.configuration.EveningImage || "/home/matt/projects/kde6-dynamic-wallpaper/images/1.jpg"
    property string duskImage: wallpaper.configuration.DuskImage || "/home/matt/projects/kde6-dynamic-wallpaper/images/3.jpg"
    property string nightImage: wallpaper.configuration.NightImage || "/home/matt/projects/kde6-dynamic-wallpaper/images/4.jpg"
    
    // Update interval in minutes
    property int updateInterval: wallpaper.configuration.UpdateInterval || 5
    
    // Fill mode configuration
    property int fillModeIndex: wallpaper.configuration.FillMode !== undefined ? wallpaper.configuration.FillMode : 2

    // Timing mode (0=astronomical, 1=custom times)
    property int timingMode: wallpaper.configuration.TimingMode !== undefined ? wallpaper.configuration.TimingMode : 0
    // Custom time settings
    property string dawnTime: wallpaper.configuration.DawnTime || "06:00"
    property string earlyMorningTime: wallpaper.configuration.EarlyMorningTime || "07:30"
    property string dayTime: wallpaper.configuration.DayTime || "09:00"
    property string eveningTime: wallpaper.configuration.EveningTime || "18:00"
    property string duskTime: wallpaper.configuration.DuskTime || "20:00"
    property string nightTime: wallpaper.configuration.NightTime || "22:00"
    
    // Watch for changes to the configuration
    Connections {
        target: wallpaper.configuration
        function onFillModeChanged() {
            console.log("Dynamic Wallpaper: Configuration FillMode changed to", wallpaper.configuration.FillMode)
            fillModeIndex = wallpaper.configuration.FillMode
        }
    function onTimingModeChanged() { timingMode = wallpaper.configuration.TimingMode }
    function onDawnTimeChanged() { dawnTime = wallpaper.configuration.DawnTime }
    function onEarlyMorningTimeChanged() { earlyMorningTime = wallpaper.configuration.EarlyMorningTime }
    function onDayTimeChanged() { dayTime = wallpaper.configuration.DayTime }
    function onEveningTimeChanged() { eveningTime = wallpaper.configuration.EveningTime }
    function onDuskTimeChanged() { duskTime = wallpaper.configuration.DuskTime }
    function onNightTimeChanged() { nightTime = wallpaper.configuration.NightTime }
    }
    
    // Convert fill mode index to Image.fillMode value
    function getFillMode() {
        switch(fillModeIndex) {
            case 0: return Image.PreserveAspectCrop  // Scaled and Cropped
            case 1: return Image.Stretch             // Scaled
            case 2: return Image.PreserveAspectFit   // Scaled, Keep Proportions
            case 3: return Image.Pad                 // Centered
            case 4: return Image.Tile                // Tiled
            default: return Image.PreserveAspectCrop
        }
    }
    
    // Debug function to get fill mode name
    function getFillModeName() {
        switch(fillModeIndex) {
            case 0: return "PreserveAspectCrop"
            case 1: return "Stretch"
            case 2: return "PreserveAspectFit"
            case 3: return "Pad"
            case 4: return "Tile"
            default: return "PreserveAspectCrop"
        }
    }
    
    // Watch for fill mode changes
    onFillModeIndexChanged: {
        console.log("Dynamic Wallpaper: Fill mode changed to", fillModeIndex, "(" + getFillModeName() + ")")
        backgroundImage.fillMode = getFillMode()
        foregroundImage.fillMode = getFillMode()
    }
    
    // Current wallpaper path
    property string currentImage: ""
    
    // Background image (what's currently showing)
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: currentImage ? ("file://" + currentImage) : ""
        fillMode: getFillMode()
        asynchronous: true
        cache: false
    }
    
    // Foreground image (for transitions)
    Image {
        id: foregroundImage
        anchors.fill: parent
        fillMode: getFillMode()
        asynchronous: true
        cache: false
        opacity: 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }
        
        onOpacityChanged: {
            if (opacity === 1) {
                // When transition is complete, update background and reset foreground
                backgroundImage.source = foregroundImage.source
                currentImage = foregroundImage.source.toString().replace("file://", "")
                foregroundImage.opacity = 0
            }
        }
        
        onStatusChanged: {
            if (status === Image.Error) {
                console.log("Dynamic Wallpaper: Error loading image", source)
            } else if (status === Image.Ready) {
                console.log("Dynamic Wallpaper: Successfully loaded", source)
            }
        }
    }
    
    onLatitudeChanged: updateWallpaper()
    onLongitudeChanged: updateWallpaper()
    
    // Watch for configuration changes to image paths
    onDawnImageChanged: updateWallpaper()
    onEarlyMorningImageChanged: updateWallpaper()
    onDayImageChanged: updateWallpaper()
    onEveningImageChanged: updateWallpaper()
    onDuskImageChanged: updateWallpaper()
    onNightImageChanged: updateWallpaper()
    
    Timer {
        id: updateTimer
        interval: updateInterval * 60 * 1000 // Convert minutes to milliseconds
        running: true
        repeat: true
        onTriggered: updateWallpaper()
    }
    
    Timer {
        id: preciseTimer
        running: false
        repeat: false
        onTriggered: {
            updateWallpaper()
            updateTimer.restart()
        }
    }
    
    Component.onCompleted: {
        updateWallpaper()
        console.log("Dynamic Wallpaper: Plugin loaded with coordinates", latitude, longitude)
        console.log("Dynamic Wallpaper: Fill mode index", fillModeIndex, "(" + getFillModeName() + ")")
    }
    
    function updateWallpaper() {
        const imagePaths = {
            dawn: dawnImage,
            earlyMorning: earlyMorningImage,
            day: dayImage,
            evening: eveningImage,
            dusk: duskImage,
            night: nightImage
        }
        
        let newImage
        if (timingMode === 1) {
            const customTimes = {
                dawn: dawnTime,
                earlyMorning: earlyMorningTime,
                day: dayTime,
                evening: eveningTime,
                dusk: duskTime,
                night: nightTime
            }
            newImage = TimeCalc.getWallpaperForCustomTime(customTimes, imagePaths)
        } else {
            newImage = TimeCalc.getWallpaperForTime(latitude, longitude, imagePaths)
        }
        
        if (newImage !== currentImage) {
            console.log("Dynamic Wallpaper: Changing to", newImage)
            
            // If this is the first image, set it directly
            if (!currentImage) {
                currentImage = newImage
                backgroundImage.source = "file://" + newImage
            } else {
                // Use transition effect
                foregroundImage.source = "file://" + newImage
                foregroundImage.opacity = 1
            }
        }
        
        // Schedule next precise update
        let nextUpdateMs
        if (timingMode === 1) {
            const customTimes = {
                dawn: dawnTime,
                earlyMorning: earlyMorningTime,
                day: dayTime,
                evening: eveningTime,
                dusk: duskTime,
                night: nightTime
            }
            nextUpdateMs = TimeCalc.getNextUpdateTimeCustom(customTimes)
        } else {
            nextUpdateMs = TimeCalc.getNextUpdateTime(latitude, longitude)
        }
        if (nextUpdateMs < updateTimer.interval) {
            preciseTimer.interval = nextUpdateMs
            preciseTimer.start()
        }
    }
    
    // Debug information (remove in production)
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        width: debugText.width + 20
        height: debugText.height + 20
        color: "black"
        opacity: 0.7
        visible: wallpaper.configuration.ShowDebug !== undefined ? wallpaper.configuration.ShowDebug : true
        
        Text {
            id: debugText
            anchors.centerIn: parent
            color: "white"
            font.pointSize: 10
            text: ""
            
            Timer {
                interval: 1000
                running: parent.parent.visible
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    const now = new Date()
                    const timeStr = now.toLocaleTimeString()
                    const imageFile = root.currentImage ? root.currentImage.split('/').pop() : "none"
                    debugText.text = `Time: ${timeStr}\nImage: ${imageFile}\nLat: ${root.latitude.toFixed(4)}\nLon: ${root.longitude.toFixed(4)}\nDawn: ${root.dawnImage.split('/').pop()}\nDay: ${root.dayImage.split('/').pop()}`
                }
            }
        }
    }
}
