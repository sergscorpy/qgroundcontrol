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

// To implement a custom overlay copy this code to your own control in your custom code source. Then override the
// FlyViewCustomLayer.qml resource with your own qml. See the custom example and documentation for details.

Item {
    id: crosshairRoot
    anchors.fill: parent

    property var parentToolInsets               // These insets tell you what screen real estate is available for positioning the controls in your overlay
    property var totalToolInsets:   _toolInsets // These are the insets for your custom overlay additions
    property var mapControl
    property real _margins:         ScreenTools.defaultFontPixelHeight / 2


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

    // параметр масштабування відносно ширини екрану
    property real scrUnit: width / 65

    // Обчислення зміщення індикатора (оскільки, зображення з камери на екрані андроїда масштабується
    // по ширині екрану, а верх та низ обрізається, за точку відліку берем ширину екрану та
    // кут огляду по осі Х)
    property real dx: Math.tan((_rollAngle + aimCorrX.value) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)
    property real dy: Math.tan((_pitchAngle + aimCorrY.value) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)

    // Відключення донаведення при нахилі більше максимального кута
    property real angleMax: 50 // Максимальний кут відстеження
    property bool rollPichMax: Math.abs(_rollAngle) <= angleMax && Math.abs(_pitchAngle) <= angleMax

    // Масив назв камер
    property var cameraNames: [
        "SiYi A2 Mini",
        "SiYi A8 Mini"
    ]

    // Масив FOV відповідно до камер
    property var cameraFovValues: [
        160.0,   // FOV для SiYi A2 Mini
        81.0     // FOV для SiYi A8 Mini
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
        height: parent.width * 0.03
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: toggleSwitch.checked && toggleSwitchAim.checked && rollPichMax

        // Переміщення від центру
        x: xc + dx - width / 2
        y: yc + dy - height / 2 - aimCorrX.value
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
        anchors.bottomMargin: _pipOverlay.height + scrUnit
        anchors.leftMargin: scrUnit
        visible: true


        indicator: Image {
            source: toggleSwitch.checked ? "/qmlimages/But_green_1.png" : "/qmlimages/But_red_1.png"
            mipmap: true
            sourceSize.height: scrUnit * 3
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
        anchors.bottomMargin: _pipOverlay.height + scrUnit * 5
        anchors.leftMargin: scrUnit
        visible: toggleSwitch.checked


        indicator: Image {
            source: toggleSwitchAim.checked ? "/qmlimages/But_green_2.png" : "/qmlimages/But_red_2.png"
            mipmap: true
            sourceSize.height: scrUnit * 3
            fillMode: Image.PreserveAspectCrop
            anchors.left: parent.left
            anchors.bottom: parent.bottom

        }
    }

    Text {
        id: _fovInst
        text: "fovInst: " + fovInst
        font.pointSize: 16
        font.bold: false
        anchors.right: parent.right
        anchors.bottom:  _dAng.top
        anchors.margins: _toolsMargin
        color: "white"
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
        width: scrUnit * 8
        anchors.right: parent.right
        anchors.bottom:  aimCorrX.top
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
        id: aimCorrX

        anchors.right: parent.right
        anchors.bottom: aimCorrY.top
        anchors.margins: _toolsMargin
    }


    FlyViewSpinBox {
        id: aimCorrY

        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: _toolsMargin
    }


}
