import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12
import QtQuick.Shapes           1.12

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1
import QtGraphicalEffects       1.0

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Airmap        1.0
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
    id: dropsButtons
    anchors.topMargin: _scrToolsUnit * 26
    anchors.rightMargin: _scrToolsUnit * 1


    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _servoOutput:  _activeVehicle ? _activeVehicle.servoOutput : null
    property real _scrToolsUnit: ScreenTools.defaultFontPixelWidth
    property int pwmClose: 2350
    property int pwmTrimm: 1900
    property int pwmOpen: 1000
    property bool fuseEnabled: true

    Column {
        id: buttonColumn
        spacing: _scrToolsUnit * 2
        anchors.top: parent.top
        anchors.right: parent.right

        Rectangle {
            id: fuseButton
            width: _scrToolsUnit * 10
            height: _scrToolsUnit * 4
            radius: 4
            color: fuseEnabled ? "green" : "red"

            Text {
                anchors.centerIn: parent
                text: "Safety"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: fuseEnabled = !fuseEnabled
            }
        }

        Rectangle {
            id: button01
            enabled: _activeVehicle ? true : false
            width: _scrToolsUnit * 8
            height: _scrToolsUnit * 4
            radius: 4
            property real servoVal: _servoOutput && !isNaN(_servoOutput.servo1.rawValue) ? _servoOutput.servo1.rawValue : 0
            color: !enabled ? "gray" : (servoVal > pwmClose - 50 ? "green" : (servoVal > pwmTrimm - 50 && servoVal < pwmTrimm + 50 ? "orange" : (servoVal < pwmOpen + 50 ? "red" : "orange")))

            Text {
                anchors.centerIn: parent
                text: "Ch1"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm
                        if (fuseEnabled) {
                            pwm = button01.servoVal > pwmClose - 50 ? pwmTrimm : pwmClose
                        } else {
                            pwm = button01.servoVal < pwmOpen + 50 ? pwmTrimm : pwmOpen
                        }
                        _activeVehicle.sendCommand(1, 183, false, 1, pwm)
                    }
                }
            }
        }

        Rectangle {
            id: button02
            enabled: _activeVehicle ? true : false
            width: _scrToolsUnit * 8
            height: _scrToolsUnit * 4
            radius: 4
            property real servoVal: _servoOutput && !isNaN(_servoOutput.servo2.rawValue) ? _servoOutput.servo2.rawValue : 0
            color: !enabled ? "gray" : (servoVal > pwmClose - 50 ? "green" : (servoVal > pwmTrimm - 50 && servoVal < pwmTrimm + 50 ? "orange" : (servoVal < pwmOpen + 50 ? "red" : "orange")))

            Text {
                anchors.centerIn: parent
                text: "Ch2"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm
                        if (fuseEnabled) {
                            pwm = button02.servoVal > pwmClose - 50 ? pwmTrimm : pwmClose
                        } else {
                            pwm = button02.servoVal < pwmOpen + 50 ? pwmTrimm : pwmOpen
                        }
                        _activeVehicle.sendCommand(1, 183, false, 2, pwm)
                    }
                }
            }
        }

        Rectangle {
            id: button03
            enabled: _activeVehicle ? true : false
            width: _scrToolsUnit * 8
            height: _scrToolsUnit * 4
            radius: 4
            property real servoVal: _servoOutput && !isNaN(_servoOutput.servo3.rawValue) ? _servoOutput.servo3.rawValue : 0
            color: !enabled ? "gray" : (servoVal > pwmClose - 50 ? "green" : (servoVal > pwmTrimm - 50 && servoVal < pwmTrimm + 50 ? "orange" : (servoVal < pwmOpen + 50 ? "red" : "orange")))

            Text {
                anchors.centerIn: parent
                text: "Ch3"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm
                        if (fuseEnabled) {
                            pwm = button03.servoVal > pwmClose - 50 ? pwmTrimm : pwmClose
                        } else {
                            pwm = button03.servoVal < pwmOpen + 50 ? pwmTrimm : pwmOpen
                        }
                        _activeVehicle.sendCommand(1, 183, false, 3, pwm)
                    }
                }
            }
        }

        Rectangle {
            id: button04
            enabled: _activeVehicle ? true : false
            width: _scrToolsUnit * 8
            height: _scrToolsUnit * 4
            radius: 4
            property real servoVal: _servoOutput && !isNaN(_servoOutput.servo4.rawValue) ? _servoOutput.servo4.rawValue : 0
            color: !enabled ? "gray" : (servoVal > pwmClose - 50 ? "green" : (servoVal > pwmTrimm - 50 && servoVal < pwmTrimm + 50 ? "orange" : (servoVal < pwmOpen + 50 ? "red" : "orange")))

            Text {
                anchors.centerIn: parent
                text: "Ch4"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm
                        if (fuseEnabled) {
                            pwm = button04.servoVal > pwmClose - 50 ? pwmTrimm : pwmClose
                        } else {
                            pwm = button04.servoVal < pwmOpen + 50 ? pwmTrimm : pwmOpen
                        }
                        _activeVehicle.sendCommand(1, 183, false, 4, pwm)
                    }
                }
            }
        }
    }

}
