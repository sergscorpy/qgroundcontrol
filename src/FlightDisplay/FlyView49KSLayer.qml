/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12
import QtQuick.Shapes           1.12
import QtGraphicalEffects       1.0

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactControls  1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.GimbalTools   1.0

// To implement a custom overlay copy this code to your own control in your custom code source. Then override the
// FlyViewCustomLayer.qml resource with your own qml. See the custom example and documentation for details.

Item {
    id: crosshairRoot
    anchors.fill: parent

    property var parentToolInsets               // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _toolInsets // These are the insets for your custom overlay additions
    property var mapControl

    property var  _activeVehicle:   QGroundControl.multiVehicleManager.activeVehicle
    property var  _videoSettings:   QGroundControl.settingsManager.videoSettings
    property var  _cameraSettings:  QGroundControl.settingsManager.cameraSettings
    property var  _flyViewSettings: QGroundControl.settingsManager.flyViewSettings
    property bool _isRTSP:          _videoSettings.videoSource.rawValue === _videoSettings.rtspVideoSource
    property bool isAndroid:        Qt.platform.os === "android"
    property bool isWindows:        Qt.platform.os === "windows"
    property bool isA8mini:         _cameraSettings.cameraType.value === 0

    // параметр масштабування відносно ширини екрану
    property real _scrUnit: width / 65
    property real _btnHeight: _scrToolsUnit * 5
    property real _btnWidth: _scrToolsUnit * 13
    property real _btnRadius: _scrToolsUnit
    property real _scrMargins: _scrToolsUnit / 2
    property real _dropWidth: _scrToolsUnit * 13
    property real _scrToolsUnit: ScreenTools.defaultFontPixelWidth

    property var  _vehicle:      globals.activeVehicle
    property real _rollAngle:   _vehicle ? _vehicle.roll.rawValue  : 0
    property real _pitchAngle:  _vehicle ? _vehicle.pitch.rawValue : 0

    property int  xc: width / 2
    property int  yc: height / 2

    // Параметри камери
    property real focalLengthEquiv: 21  // Еквівалентна фокусна відстань (мм)
    property real sensorSize: 1 / 1.7   // Розмір сенсора у дюймах (1/1.7")

    // Якщо кут огляду камери відомий, можна використати його без необхідності додаткових обчислень
    property real fovInst: 81  // fovInst <-> fovX

    // Обчислення реальних параметрів сенсора
    function calculateSensorSize(sensorInches) {
        var diagonalMM = 17.3 * sensorInches; // Емпіричний коефіцієнт
        var width = (4 / Math.sqrt(4 * 4 + 3 * 3)) * diagonalMM;
        var height = (3 / Math.sqrt(4 * 4 + 3 * 3)) * diagonalMM;
        var cropFactor = 43.3 / diagonalMM; // Full Frame = 43.3 мм
        return { width: width, height: height, cropFactor: cropFactor };
    }
    property var sensorData: calculateSensorSize(sensorSize)
    property real sensorWidth: sensorData.width
    property real sensorHeight: sensorData.height
    property real cropFactor: sensorData.cropFactor

    // Реальна фокусна відстань
    property real focalLengthReal: focalLengthEquiv / cropFactor

    // Обчислення кутів огляду камери
    property real fovX: 2 * Math.atan(sensorWidth / (2 * focalLengthReal)) * (180 / Math.PI)
    property real fovY: 2 * Math.atan(sensorHeight / (2 * focalLengthReal)) * (180 / Math.PI)

    // Вимкнення поправки по гіроскопу у випадку увімкнення камери в режим прицілювання (Follow Mod)
    property real aimOn: sdkSender.gimbalMode === 1 ? 0 : 1

    // Обчислення зміщення індикатора (оскільки, зображення з камери на екрані андроїда масштабується
    // по ширині екрану, а верх та низ обрізається, за точку відліку берем ширину екрану та
    // кут огляду по осі Х)
    property real dx: Math.tan((aimOn * _rollAngle) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)
    property real dy: Math.tan((aimOn * _pitchAngle) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)


    // Відключення донаведення при нахилі більше максимального кута
    property real angleMax: 25 // Максимальний кут відстеження
    property bool rollPichMax: Math.abs(_rollAngle) <= angleMax && Math.abs(_pitchAngle) <= angleMax

    // Масив моделей камер
    property var cameraNames: [
        "SiYi A8 Mini",
        "SiYi A2 Mini"
    ]

    // Масив FOV відповідно до камер
    property var cameraFovValues: [
        81.0,    // FOV для SiYi A8 Mini
        160.0    // FOV для SiYi A2 Mini
    ]

    // Поточний індекс вибраної камери
    property int cameraIndex: 0

    Image {
        id: crossHair1
        anchors.centerIn: parent
        source: "/qmlimages/49ks/crosshair_1.svg"
        mipmap: true
        height: parent.width * 0.33
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: true
    }

    Image {
        id: aim
        source: "/qmlimages/49ks/crosshair_2.svg"
        mipmap: true
        height: parent.width * 0.05
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: toggleSwitchAim.isChecked && rollPichMax && isA8mini

        // Переміщення від центру
        x: xc + dx - width / 2
        y: yc + dy - height / 2
    }

    Shape {
        id: connectionLine
        width: parent.width
        height: parent.height
        anchors.fill: parent
        visible: toggleSwitchAim.isChecked && rollPichMax && isA8mini

        ShapePath {
            strokeWidth: 3
            strokeColor: "lightgreen"

            startX: xc
            startY: yc

            PathLine {
                x: aim.x + aim.width / 2
                y: aim.y + aim.height / 2
            }
        }
    }

    Item {
        id: cameraControl
        anchors.fill: parent
        visible: _cameraSettings.cameraType.value !== 2

        SdkSender {
            id: sdkSender
        }

        Timer {
            id: gimbalModeUpdateTimer
            interval: 10000
            repeat: true
            running: true
            triggeredOnStart: true
            onTriggered: sdkSender.requestGimbalMode()
        }

        Timer {
            id: delayedModeRequestTimer
            interval: 1000
            repeat: false
            running: false
            onTriggered: sdkSender.requestGimbalMode()
        }

        Timer {
            id: disableTimer
            interval: 1500    // 5 секунд
            repeat: false
            running: false
            // onTriggered: {
            //     console.log("Кнопку знову активовано")
            // }
        }

        Rectangle { // Загальний блок у вигляді шторки з ліва
            id:                 leftControlPanel
            anchors.top:        parent.top
            anchors.left:       parent.left
            width:              collapsed && !isA8mini ? 0 : _btnWidth + _scrMargins * 2
            height: collapsed
                    ? _btnHeight * 3 + _scrMargins * 4
                    : crosshairRoot.height - _scrMargins // - _pipOverlay.height
            color:      "#00000000"
            //radius:     _scrToolsUnit

            property bool collapsed: true

            Image {
                id:             hideBar
                source:         leftControlPanel.collapsed ? "/qmlimages/49ks/barShow.svg" : "/qmlimages/49ks/barHide.svg"
                mipmap:         true
                fillMode:       Image.PreserveAspectFit
                anchors.left:   leftControlPanel.right
                anchors.top:    leftControlPanel.top
                visible:        true
                height:         _btnHeight + _scrMargins * 2 // _scrToolsUnit * 8
                width:          _btnHeight + _scrMargins * 2 // _scrToolsUnit * 8
                sourceSize.height:  height

            }
            Item {
                id: mouseHideBar
                anchors.left:   leftControlPanel.right
                anchors.top:    leftControlPanel.top
                height:         _scrToolsUnit * 10
                width:          _scrToolsUnit * 10
                MouseArea {
                    anchors.fill:   parent
                    onClicked:      leftControlPanel.collapsed = !leftControlPanel.collapsed
                    cursorShape:    Qt.PointingHandCursor
                }
            }

            Column { // Column "Приціл"
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: _scrMargins
                anchors.margins: _scrMargins

                Button { // Button "Скид"
                    id: dropp
                    enabled: !disableTimer.running
                    visible: _cameraSettings.cameraType.value === 0 //isAndroid
                    width: _btnWidth
                    height: _btnHeight
                    onClicked: {
                        sdkSender.activateAimMode()
                        delayedModeRequestTimer.restart()
                        disableTimer.start()
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem1
                            source: textItem1
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: !parent.enabled ? 0 : 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem1
                            anchors.centerIn: parent
                            text: "Скид"
                            font.pointSize: 10
                            font.bold: false
                            color: !parent.enabled ? "darkgray" : "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: sdkSender.gimbalMode === 1
                               ? (parent.down ? "#66008B00" : "#e6005900")
                               : (parent.down ? "#33000000" : "#66000000")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "Політ"
                    enabled: !disableTimer.running
                    visible: _cameraSettings.cameraType.value === 0 //isAndroid
                    width: _btnWidth
                    height: _btnHeight
                    onClicked: {
                        sdkSender.activateFPVMode()
                        delayedModeRequestTimer.restart()
                        disableTimer.start()
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem2
                            source: textItem2
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: !parent.enabled ? 0 : 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem2
                            anchors.centerIn: parent
                            text: "Політ"
                            font.pointSize: 10
                            font.bold: false
                            color: !parent.enabled ? "darkgray" : "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: sdkSender.gimbalMode === 2
                               ? (parent.down ? "#66008B00" : "#e6005900")
                               : (parent.down ? "#33000000" : "#66000000")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "Баліст."
                    id: toggleSwitchAim
                    visible: _cameraSettings.cameraType.value === 0
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: false
                    onClicked: {
                        isChecked = !isChecked
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem3
                            source: textItem3
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem3
                            anchors.centerIn: parent
                            text: "Баліст."
                            font.pointSize: 10
                            font.bold: false
                            color: "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#66008B00" : "#e6005900")
                               : (parent.down ? "#33000000" : "#66000000")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Label { // Label "Video"
                    id: labelReboot
                    visible: !leftControlPanel.collapsed
                    text: " "
                    font.pointSize: 3
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: _scrMargins
                    color: "white"
                }

                Button { // Button "Камера"
                    visible: _cameraSettings.cameraType.value === 0 && !leftControlPanel.collapsed
                    width: _btnWidth
                    height: _btnHeight
                    enabled: !sdkSender.cameraCommandInProgress
                    onClicked: sdkSender.sendRebootCamera()

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem4
                            source: textItem4
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: !parent.enabled ? 0 : 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem4
                            anchors.centerIn: parent
                            text: "Камера"
                            font.pointSize: 10
                            font.bold: false
                            color: !parent.enabled ? "darkgray" : "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color:  !parent.enabled ? "#66000000"
                                                : parent.down   ? "#33000000"
                                                                : "#66000000"
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "Гімбал"
                    visible: _cameraSettings.cameraType.value === 0 && !leftControlPanel.collapsed
                    width: _btnWidth
                    height: _btnHeight
                    enabled: !sdkSender.gimbalCommandInProgress
                    onClicked: sdkSender.sendRebootGimbal()

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem5
                            source: textItem5
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: !parent.enabled ? 0 : 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem5
                            anchors.centerIn: parent
                            text: "Гімбал"
                            font.pointSize: 10
                            font.bold: false
                            color: !parent.enabled ? "darkgray" : "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color:  !parent.enabled ? "#66000000"
                                                : parent.down   ? "#33000000"
                                                                : "#66000000"
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Label { // Label "Video"
                    id: labelVideo
                    visible: !leftControlPanel.collapsed
                    text: " "
                    font.pointSize: 3
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: _scrMargins
                    color: "white"
                }

                Button { // Button "HDMI PC"
                    visible: !leftControlPanel.collapsed && !isAndroid
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "Herelink Hotspot"
                    enabled: true
                    onClicked: _videoSettings.videoSource.rawValue = "Herelink Hotspot"

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem6
                            source: textItem6
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem6
                            anchors.centerIn: parent
                            text: "HotSpot"
                            font.pointSize: 10
                            font.bold: false
                            color: "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#66008B00" : "#e6005900")
                               : (parent.down ? "#33000000" : "#66000000")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "HDMI PC Router"
                    visible: !leftControlPanel.collapsed && !isAndroid
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "Herelink Hotspot (Dynamic)"
                    enabled: true
                    onClicked: {
                        _videoSettings.videoSource.rawValue = "Herelink Hotspot (Dynamic)"
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem7
                            source: textItem7
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem7
                            anchors.centerIn: parent
                            text: "Router"
                            font.pointSize: 10
                            font.bold: false
                            color: "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#66008B00" : "#e6005900")
                               : (parent.down ? "#33000000" : "#66000000")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "HDMI Android"
                    visible: _cameraSettings.cameraType.value === 0 && !leftControlPanel.collapsed && isAndroid
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "Herelink AirUnit"
                    enabled: true
                    onClicked: _videoSettings.videoSource.rawValue = "Herelink AirUnit"

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem8
                            source: textItem8
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem8
                            anchors.centerIn: parent
                            text: "HDMI"
                            font.pointSize: 10
                            font.bold: false
                            color: "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#66008B00" : "#e6005900")
                               : (parent.down ? "#33000000" : "#66000000")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "IP Video" Android
                    visible: _cameraSettings.cameraType.value === 0 && !leftControlPanel.collapsed && isAndroid
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "IP Camera Stream"
                    enabled: true
                    onClicked: _videoSettings.videoSource.rawValue = "IP Camera Stream"

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem9
                            source: textItem9
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem9
                            anchors.centerIn: parent
                            text: "- IP -"
                            font.pointSize: 10
                            font.bold: false
                            color: "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#66008B00" : "#e6005900")
                               : (parent.down ? "#33000000" : "#66000000")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "RTSP-1"
                    visible: !leftControlPanel.collapsed && _cameraSettings.cameraType.value === 1
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "RTSP Video Stream"
                    enabled: true
                    onClicked: _videoSettings.videoSource.rawValue = "RTSP Video Stream"

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem11
                            source: textItem11
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem11
                            anchors.centerIn: parent
                            text: "RTSP-1"
                            font.pointSize: 10
                            font.bold: false
                            color: "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#66008B00" : "#e6005900")
                               : (parent.down ? "#33000000" : "#66000000")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "RTSP-2"
                    visible: !leftControlPanel.collapsed && _cameraSettings.cameraType.value === 1
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "RTSP2 Video Stream"
                    enabled: true
                    onClicked: _videoSettings.videoSource.rawValue = "RTSP2 Video Stream"

                    contentItem: Item {
                        anchors.fill: parent

                        DropShadow {
                            anchors.fill: textItem10
                            source: textItem10
                            horizontalOffset: 1
                            verticalOffset: 1
                            radius: 6
                            color: "#000000"
                        }

                        Text {
                            id: textItem10
                            anchors.centerIn: parent
                            text: "RTSP-2"
                            font.pointSize: 10
                            font.bold: false
                            color: "white"
                        }
                    }

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#66008B00" : "#e6005900")
                               : (parent.down ? "#33000000" : "#66000000")
                        border.color: "#666666"
                        border.width: 1
                    }
                }
            }
        }
    }

    Loader {
        id: rcLoader
        active: _vehicle !== null
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        anchors.topMargin: _scrToolsUnit * 17
        width: _btnWidth
        height: _btnHeight * 3
        sourceComponent: dropsPanelComponent
    }

    Component { // Drops indicator
        id: dropsPanelComponent

        Item {
            id: dropsPanel

            RCChannelMonitorController {
                id: rcController
            }

            property int rc2:       78
            property int rc9:       15
            property int rc10:      25

            Connections {
                target: rcController
                onChannelRCValueChanged: {
                    //console.log("RC Channel", channel, "value:", rcValue)
                    if (channel === 1) rc2 = rcValue
                    if (channel === 8) rc9 = rcValue
                    if (channel === 9) rc10 = rcValue
                }
            }

            Column {
                anchors.top: parent.top
                spacing: 6

                Image {
                    width: _dropWidth
                    mipmap: true
                    sourceSize.width: width
                    fillMode: Image.PreserveAspectCrop
                    visible: _flyViewSettings.dropLeft.value && _cameraSettings.cameraType.value !== 2
                    source: rc9 < 1500 ? "/qmlimages/49ks/DropsOn" : "/qmlimages/49ks/DropsOff"
                }
                Image {
                    width: _dropWidth
                    mipmap: true
                    sourceSize.width: width
                    fillMode: Image.PreserveAspectCrop
                    visible: _flyViewSettings.dropRight.value && _cameraSettings.cameraType.value !== 2
                    source: rc10 < 1500 ? "/qmlimages/49ks/DropsOn" : "/qmlimages/49ks/DropsOff"
                }
            }
        }
    }
}
