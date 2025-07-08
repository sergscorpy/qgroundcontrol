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

    Column {
        id: buttonColumn
        spacing: _scrToolsUnit
        anchors.top: parent.top
        anchors.right: parent.right

        Rectangle {
            id: button01
            enabled: _activeVehicle ? true : false
            width: _scrToolsUnit * 8
            height: _scrToolsUnit * 4
            radius: 4
            color: !enabled ? "gray" : (ch16Active ? "green" : "orange")
            property bool ch16Active: _servoOutput && !isNaN(_servoOutput.servo16.rawValue) && _servoOutput.servo16.rawValue > 1100

            Text {
                anchors.centerIn: parent
                text: "Ch16"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm = button01.ch16Active ? 800 : 1350
                        _activeVehicle.sendCommand( 1, 183, false, 16, pwm)
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
            color: !enabled ? "gray" : (ch17Active ? "green" : "orange")
            property bool ch17Active: _servoOutput && !isNaN(_servoOutput.servo17.rawValue) && _servoOutput.servo17.rawValue > 1100

            Text {
                anchors.centerIn: parent
                text: "Ch17"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm = button02.ch17Active ? 800 : 1350
                        _activeVehicle.sendCommand(1, 183, false, 17, pwm)
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
            color: !enabled ? "gray" : (ch18Active ? "green" : "orange")
            property bool ch18Active: _servoOutput && !isNaN(_servoOutput.servo18.rawValue) && _servoOutput.servo18.rawValue > 1100

            Text {
                anchors.centerIn: parent
                text: "Ch18"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm = button03.ch18Active ? 800 : 1350
                        _activeVehicle.sendCommand(1, 183, false, 18, pwm)
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
            color: !enabled ? "gray" : (ch19Active ? "green" : "orange")
            property bool ch19Active: _servoOutput && !isNaN(_servoOutput.servo19.rawValue) && _servoOutput.servo19.rawValue > 1100

            Text {
                anchors.centerIn: parent
                text: "Ch19"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm = button04.ch19Active ? 800 : 1350
                        _activeVehicle.sendCommand(1, 183, false, 19, pwm)
                    }
                }
            }
        }
    }


}
