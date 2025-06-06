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

    SdkSender {
        id: sdkSender
    }

    FlyView49KSButtons {
        id: cameraControl
        anchors.fill: parent

        _sdkSender: sdkSender
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
