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

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Airmap        1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
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
    property bool _isRTSP:          _videoSettings.videoSource.rawValue === _videoSettings.rtspVideoSource
    property bool isAndroid:        Qt.platform.os === "android"
    property bool isWindows:        Qt.platform.os === "windows"

    // параметр масштабування відносно ширини екрану
    property real _scrUnit: width / 65
    property real _btnHeight: _scrToolsUnit * 5
    property real _btnWidth: _scrToolsUnit * 13
    property real _btnRadius: _scrToolsUnit * 2
    property real _scrMargins: _scrToolsUnit / 2
    property real _scrToolsUnit: ScreenTools.defaultFontPixelWidth


    QGCToolInsets {
        id:                         _toolInsets
        leftEdgeCenterInset:        0
        leftEdgeTopInset:           0
        leftEdgeBottomInset:        0
        rightEdgeCenterInset:       0
        rightEdgeTopInset:          0
        rightEdgeBottomInset:       0
        topEdgeCenterInset:         0
        topEdgeLeftInset:           0
        topEdgeRightInset:          0
        bottomEdgeCenterInset:      0
        bottomEdgeLeftInset:        0
        bottomEdgeRightInset:       0
    }

    property var  vehicle:      globals.activeVehicle
    property real _rollAngle:   vehicle ? vehicle.roll.rawValue  : 0
    property real _pitchAngle:  vehicle ? vehicle.pitch.rawValue : 0

    property int  xc: width / 2
    property int  yc: height / 2

    // Параметри камери
    property real focalLengthEquiv: 21  // Еквівалентна фокусна відстань (мм)
    property real sensorSize: 1 / 1.7   // Розмір сенсора у дюймах (1/1.7")

    // Якщо кут огляду камери відомий, можна використати його без необхідності додаткових обчислень
    //property real fovInst: 81  // fovInst <-> fovX

    // Значення FOV, що залежить від вибору камери
    property real fovInst: cameraFovValues[cameraIndex]

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
    property real dx: Math.tan((aimOn * _rollAngle * aimCorrFovX.value + aimCorrAnglX.value) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)
    property real dy: Math.tan((aimOn * _pitchAngle * aimCorrFovY.value + aimCorrAnglY.value) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)


    // Відключення донаведення при нахилі більше максимального кута
    // Значення задається в налаштуваннях
    property Fact _maxCorrectionAngle: QGroundControl.settingsManager.flyViewSettings.maxCorrectionAngle

    property real angleMax: _maxCorrectionAngle.value // Максимальний кут відстеження
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
        source: "/qmlimages/crosshair_1.svg"
        mipmap: true
        height: parent.width * 0.33
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: true //toggleSwitch.checked
    }

    Image {
        id: aim
        source: "/qmlimages/crosshair_2.svg"
        mipmap: true
        height: parent.width * 0.05
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: toggleSwitchAim.isChecked && rollPichMax

        // Переміщення від центру
        x: xc + dx - width / 2
        y: yc + dy - height / 2
    }

    Shape {
        id: connectionLine
        width: parent.width
        height: parent.height
        anchors.fill: parent
        visible: toggleSwitchAim.isChecked && rollPichMax

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
        visible: true

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

        Rectangle { // тепер загальний блок у вигляді шторки з ліва
            id:                 leftControlPanel
            anchors.top:        parent.top
            anchors.left:       parent.left
            anchors.leftMargin: _toolsMargin
            width:              _btnWidth + _scrMargins * 2
            height: collapsed
                    ? _btnHeight * 3 + _scrMargins * 4
                    : crosshairRoot.height - _scrMargins // - _pipOverlay.height
            color:      "#80000000"
            //radius:     _scrToolsUnit

            property bool collapsed: true

            Image {
                id:             hideBar
                source:         leftControlPanel.collapsed ? "/qmlimages/barShow.svg" : "/qmlimages/barHide.svg"
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
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Column { // Column "Приціл"
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: _scrMargins
                anchors.margins: _scrMargins

                Label { // Label "Приціл"
                    id: labelCameraMod
                    visible: !leftControlPanel.collapsed
                    text: "Режим прицілу"
                    font.pointSize: 10
                    font.bold: true
                    width: _btnWidth
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: _scrMargins
                    color: "white"
                }

                Button { // Button "Скид"
                    id: dropp
                    enabled: !disableTimer.running
                    visible: true //isAndroid // !leftControlPanel.collapsed
                    width: _btnWidth
                    height: _btnHeight
                    onClicked: {
                        sdkSender.activateAimMode()
                        delayedModeRequestTimer.restart()
                        disableTimer.start()
                    }

                    text: "Скид"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: sdkSender.gimbalMode === 1
                               ? (parent.down ? "#228B22" : "#32CD32")   // Follow Mode — темно/світло зелений
                               : (parent.down ? "#DDDDDD" : "#FFFFFF")   // інші — стандартні кольори
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "Політ"
                    enabled: !disableTimer.running
                    visible: true //isAndroid //!leftControlPanel.collapsed
                    width: _btnWidth
                    height: _btnHeight
                    onClicked: {
                        sdkSender.activateFPVMode()
                        delayedModeRequestTimer.restart()
                        disableTimer.start()
                    }

                    text: "Політ"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: sdkSender.gimbalMode === 2
                               ? (parent.down ? "#228B22" : "#32CD32")   // FPV Mode — темно/світло зелений
                               : (parent.down ? "#DDDDDD" : "#FFFFFF")   // інші — стандартні кольори
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "Баліст."
                    id: toggleSwitchAim
                    visible: true // !leftControlPanel.collapsed
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: false
                    onClicked: {
                        isChecked = !isChecked
                    }

                    text: "Баліст."
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#228B22" : "#32CD32")
                               : (parent.down ? "#DDDDDD" : "#FFFFFF")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Label { // Label "Video"
                    id: labelReboot
                    visible: !leftControlPanel.collapsed
                    text: "Reboot"
                    font.pointSize: 10
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: _scrMargins
                    color: "white"
                }

                Button { // Button "Камера"
                    visible: !leftControlPanel.collapsed
                    width: _btnWidth
                    height: _btnHeight
                    enabled: !sdkSender.cameraCommandInProgress
                    onClicked: sdkSender.sendRebootCamera()

                    text: "Камера"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color:  !parent.enabled ? "#AAAAAA"           // неактивна — сіра
                                                : parent.down   ? "#DDDDDD"           // натиснута — світлосіра
                                                                : "#FFFFFF"           // нормальна — біла
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "Гімбал"
                    visible: !leftControlPanel.collapsed
                    width: _btnWidth
                    height: _btnHeight
                    enabled: !sdkSender.gimbalCommandInProgress
                    onClicked: sdkSender.sendRebootGimbal()

                    text: "Гімбал"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color:  !parent.enabled     ? "#AAAAAA"           // неактивна — сіра
                                                    : parent.down       ? "#DDDDDD"           // натиснута — світлосіра
                                                                        : "#FFFFFF"           // нормальна — біла
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Label { // Label "Video"
                    id: labelVideo
                    visible: !leftControlPanel.collapsed
                    text: "Video"
                    font.pointSize: 10
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

                    text: "HotSpot"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#228B22" : "#32CD32")
                               : (parent.down ? "#DDDDDD" : "#FFFFFF")
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

                    text: "Router"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#228B22" : "#32CD32")
                               : (parent.down ? "#DDDDDD" : "#FFFFFF")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "HDMI Android"
                    visible: !leftControlPanel.collapsed && isAndroid
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "Herelink Air Unit"
                    enabled: true
                        onClicked: _videoSettings.videoSource.rawValue = "Herelink Air Unit"

                    text: "HDMI"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#228B22" : "#32CD32")
                               : (parent.down ? "#DDDDDD" : "#FFFFFF")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "IP Video" Android
                    visible: !leftControlPanel.collapsed && isAndroid
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "IP Camera Stream"
                    enabled: true
                        onClicked: _videoSettings.videoSource.rawValue = "IP Camera Stream"

                    text: "- IP -"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#228B22" : "#32CD32")
                               : (parent.down ? "#DDDDDD" : "#FFFFFF")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "RTSP-1"
                    visible: !leftControlPanel.collapsed && _videoSettings.usingButtonRTSP1.value
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "RTSP Video Stream"
                    enabled: true
                    onClicked: _videoSettings.videoSource.rawValue = "RTSP Video Stream"

                    text: "RTSP-1"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#228B22" : "#32CD32")
                               : (parent.down ? "#DDDDDD" : "#FFFFFF")
                        border.color: "#666666"
                        border.width: 1
                    }
                }

                Button { // Button "RTSP-2"
                    visible: !leftControlPanel.collapsed && _videoSettings.usingButtonRTSP2.value
                    width: _btnWidth
                    height: _btnHeight
                    property bool isChecked: _videoSettings.videoSource.rawValue === "RTSP2 Video Stream"
                    enabled: true
                    onClicked: _videoSettings.videoSource.rawValue = "RTSP2 Video Stream"

                    text: "RTSP-2"
                    font.pointSize: 10
                    font.bold: false

                    background: Rectangle {
                        anchors.fill: parent
                        radius: _btnRadius
                        color: parent.isChecked
                               ? (parent.down ? "#228B22" : "#32CD32")
                               : (parent.down ? "#DDDDDD" : "#FFFFFF")
                        border.color: "#666666"
                        border.width: 1
                    }
                }
            }
        }
    }

    Item { // Блок налаштувань прицілу
        id: correctContainer
        anchors.fill: parent
        visible: QGroundControl.settingsManager.flyViewSettings.showCorrectionControls.value

        Text {
            id: _fovInst
            text: "fovInst: " + fovInst
            font.pointSize: 16
            font.bold: false
            anchors.right: parent.right
            anchors.bottom:  _dAng.top
            anchors.margins: _toolsMargin
            color: "white"
            visible: false
        }

        Text {
            id: _dAng
            text: "Roll: " + _rollAngle.toFixed(2) + "°, Pitch: " + _pitchAngle.toFixed(2) + "°"
            font.pointSize: 16
            font.bold: false
            anchors.right: parent.right
            anchors.bottom:  _dx.top
            anchors.margins: _toolsMargin
            color: "white"
            visible: false
        }

        Text {
            id: _dx
            text: "dx: " + dx.toFixed(2) + "  dy: " + dy.toFixed(2)
            font.pointSize: 16
            font.bold: false
            anchors.right: parent.right
            anchors.bottom:  cameraSelector.top
            anchors.margins: _toolsMargin
            color: "white"
            visible: false
        }

        // ComboBox для вибору камери
        QGCComboBox {
            id: cameraSelector
            width: _scrUnit * 8
            anchors.right: parent.right
            anchors.bottom:  aimCorrAnglX.top
            anchors.margins: _toolsMargin
            visible: false

            model: cameraNames
            currentIndex: cameraIndex

            onActivated: {
                cameraIndex = index
                fovInst = cameraFovValues[index]

                console.log("Selected camera:", cameraNames[index], "FOV:", fovInst)
            }
        }
        Column {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: _toolsMargin
            spacing: _toolsMargin

            FlyViewSpinBox {
                id: aimCorrAnglX

                minValue: -10
                maxValue: 10
                stepValue: 0.5
                value: 0
            }

            FlyViewSpinBox {
                id: aimCorrAnglY

                minValue: -10
                maxValue: 10
                stepValue: 0.5
                value: 0
            }

            FlyViewSpinBox {
                id: aimCorrFovX

                minValue: 0
                maxValue: 2
                stepValue: 0.05
                value: 0.8
                visible: false
            }

            FlyViewSpinBox {
                id: aimCorrFovY

                minValue: 0
                maxValue: 2
                stepValue: 0.05
                value: 0.8
                visible: false
            }
        }
    }

}
