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

    // параметр масштабування відносно ширини екрану
    property real _scrUnit: width / 65
    property real _margins: _scrUnit / 4


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

    // Обчислення зміщення індикатора (оскільки, зображення з камери на екрані андроїда масштабується
    // по ширині екрану, а верх та низ обрізається, за точку відліку берем ширину екрану та
    // кут огляду по осі Х)
    property real dx: Math.tan((_rollAngle * aimCorrFovX.value + aimCorrAnglX.value) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)
    property real dy: Math.tan((_pitchAngle * aimCorrFovY.value + aimCorrAnglY.value) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)

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
        visible: toggleSwitch.checked
    }

    Image {
        id: aim
        source: "/qmlimages/crosshair_2.svg"
        mipmap: true
        height: parent.width * 0.05
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: toggleSwitch.checked && toggleSwitchAim.checked && rollPichMax

        // Переміщення від центру
        x: xc + dx - width / 2
        y: yc + dy - height / 2
    }

    Shape {
        id: connectionLine
        width: parent.width
        height: parent.height
        anchors.fill: parent
        visible: toggleSwitch.checked && toggleSwitchAim.checked && rollPichMax

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

    Switch {
        id: toggleSwitch
        checked: true
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: _pipOverlay.height + _scrUnit
        anchors.leftMargin: _scrUnit
        visible: true


        indicator: Image {
            source: toggleSwitch.checked ? "/qmlimages/But_green_1.png" : "/qmlimages/But_red_1.png"
            mipmap: true
            sourceSize.height: _scrUnit * 3
            fillMode: Image.PreserveAspectCrop
            anchors.left: parent.left
            anchors.bottom: parent.bottom

        }
    }
    Switch {
        id: toggleSwitchAim
        checked: false
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: _pipOverlay.height + _scrUnit * 5
        anchors.leftMargin: _scrUnit
        visible: toggleSwitch.checked


        indicator: Image {
            source: toggleSwitchAim.checked ? "/qmlimages/But_green_2.png" : "/qmlimages/But_red_2.png"
            mipmap: true
            sourceSize.height: _scrUnit * 3
            fillMode: Image.PreserveAspectCrop
            anchors.left: parent.left
            anchors.bottom: parent.bottom

        }
    }
    Item {
        id: cameraControl
        anchors.fill: parent
        visible: true
        SdkSender {
            id: sdkSender
        }
        Row {
            anchors.top: parent.top
            x: parent.width - _rightPanelWidth - width - _scrUnit * 3
            spacing: _scrUnit
            anchors.margins: _toolsMargin

            Button {
                text: "Reboot Camera"
                width: _scrUnit * 6
                height: _scrUnit * 3.8
                enabled: !sdkSender.commandInProgress
                onClicked: sdkSender.sendRebootCamera()

                property string normalIcon: "/qmlimages/RebootCamera.png"
                property string pressedIcon: "/qmlimages/RebootCameraDown.png"
                property string disabledIcon: "/qmlimages/RebootCameraOff.png"

                background: Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: !parent.enabled ? parent.disabledIcon
                           : (parent.down ? parent.pressedIcon : parent.normalIcon)
                }
            }


            Button {
                text: "Reboot Gimbal"
                width: _scrUnit * 6
                height: _scrUnit * 3.8
                enabled: !sdkSender.commandInProgress
                onClicked: sdkSender.sendRebootGimbal()

                property string normalIcon: "/qmlimages/RebootGimbal.png"
                property string pressedIcon: "/qmlimages/RebootGimbalDown.png"
                property string disabledIcon: "/qmlimages/RebootGimbalOff.png"

                background: Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: !parent.enabled ? parent.disabledIcon
                           : (parent.down ? parent.pressedIcon : parent.normalIcon)
                }
            }

        }
        Item {
            id: testGimbal
            visible: true
            Text {
                anchors.top: butPichDown.bottom
                anchors.left: parent.left
                anchors.margins: _scrUnit
                text: "Pitch: " + sdkSender.pitchCamAngle.toFixed(1) + "°"
                font.pixelSize: 24
                color: "lime"
            }
            Button {
                id: butReadPosition
                anchors.top: parent.top
                anchors.margins: _scrUnit
                anchors.left: butPichCenter.right

                width: _scrUnit * 4
                height: _scrUnit * 4
                text: "?"
                onClicked: {
                    sdkSender.sendReadPositionCommand()
                }
            }
            Button {
                id: butPichDown
                anchors.top: parent.top
                anchors.margins: _scrUnit
                anchors.left: parent.left

                width: _scrUnit * 4
                height: _scrUnit * 4
                text: "-90"
                onClicked: {
                    sdkSender.sendPitchDown()
                }
            }
            Button {
                id: butPichCenter
                anchors.top: parent.top
                anchors.margins: _scrUnit
                anchors.left: butPichDown.right

                width: _scrUnit * 4
                height: _scrUnit * 4
                text: "0"
                onClicked: {
                    sdkSender.sendPitchCenter()
                }
            }
        }
    }
    Item {
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
        }

        // ComboBox для вибору камери
        QGCComboBox {
            id: cameraSelector
            width: _scrUnit * 8
            anchors.right: parent.right
            anchors.bottom:  aimCorrAnglX.top
            anchors.margins: _toolsMargin

            model: cameraNames
            currentIndex: cameraIndex

            onActivated: {
                cameraIndex = index
                fovInst = cameraFovValues[index]

                console.log("Selected camera:", cameraNames[index], "FOV:", fovInst)
            }
        }

        FlyViewSpinBox {
            id: aimCorrAnglX

            anchors.right: parent.right
            anchors.bottom: aimCorrAnglY.top
            anchors.margins: _toolsMargin

            minValue: -10
            maxValue: 10
            stepValue: 0.5
            value: 0
        }

        FlyViewSpinBox {
            id: aimCorrAnglY

            anchors.right: parent.right
            anchors.bottom: aimCorrFovX.top
            anchors.margins: _toolsMargin

            minValue: -10
            maxValue: 10
            stepValue: 0.5
            value: 0
        }

        FlyViewSpinBox {
            id: aimCorrFovX

            anchors.right: parent.right
            anchors.bottom: aimCorrFovY.top
            anchors.margins: _toolsMargin

            minValue: 0
            maxValue: 2
            stepValue: 0.05
            value: 0.8
        }

        FlyViewSpinBox {
            id: aimCorrFovY

            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: _toolsMargin

            minValue: 0
            maxValue: 2
            stepValue: 0.05
            value: 0.8
        }
    }

}
