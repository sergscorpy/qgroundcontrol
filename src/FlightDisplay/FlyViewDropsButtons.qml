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

    Row {
        id: buttonRow
        spacing: _scrToolsUnit
        anchors.top: parent.top
        anchors.right: parent.right

        Rectangle {
            id: ch9Button
            enabled: _activeVehicle ? true : false
            width: _scrToolsUnit * 8
            height: _scrToolsUnit * 4
            radius: 4
            color: !enabled ? "gray" : (ch9Active ? "green" : "orange")
            property bool ch9Active: _servoOutput && !isNaN(_servoOutput.servo9.rawValue) && _servoOutput.servo9.rawValue > 1500

            Text {
                anchors.centerIn: parent
                text: "Ch9"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm = ch9Button.ch9Active ? 1100 : 1800
                        _activeVehicle.sendCommand( 1, 183, false, 9, pwm)
                    }
                }
            }
        }

        Rectangle {
            id: ch10Button
            enabled: _activeVehicle ? true : false
            width: _scrToolsUnit * 8
            height: _scrToolsUnit * 4
            radius: 4
            color: !enabled ? "gray" : (ch10Active ? "green" : "orange")
            property bool ch10Active: _servoOutput && !isNaN(_servoOutput.servo10.rawValue) && _servoOutput.servo10.rawValue > 1500

            Text {
                anchors.centerIn: parent
                text: "Ch10"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm = ch10Button.ch10Active ? 1100 : 1800
                        _activeVehicle.sendCommand(1, 183, false, 10, pwm)
                    }
                }
            }
        }
    }


}
