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
    property int _pwmClose: 2350
    property int _pwmTrimm: 1900
    property int _pwmOpen: 1000
    property int _btn_setservo1: 12
    property int _btn_setservo2: 11
    property int _btn_setservo3: 13
    property int _btn_setservo4: 14
    property var _servo_btn1: _servoOutput.servo12
    property var _servo_btn2: _servoOutput.servo11
    property var _servo_btn3: _servoOutput.servo13
    property var _servo_btn4: _servoOutput.servo14
    property bool fuseEnabled: true

    Timer {
        id: trimTimer
        interval: 5000
        repeat: false
        onTriggered: {
            if (_activeVehicle && !_activeVehicle.armed) {
                _activeVehicle.sendCommand(1, 183, false, _btn_setservo1, _pwmTrimm)
                _activeVehicle.sendCommand(1, 183, false, _btn_setservo2, _pwmTrimm)
                _activeVehicle.sendCommand(1, 183, false, _btn_setservo3, _pwmTrimm)
                _activeVehicle.sendCommand(1, 183, false, _btn_setservo4, _pwmTrimm)
            }
        }
    }

    Connections {
        target: QGroundControl.multiVehicleManager
        onActiveVehicleChanged: {
            if (_activeVehicle && !_activeVehicle.armed) {
                trimTimer.restart()
            } else {
                trimTimer.stop()
            }
        }
    }


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
            property real servoVal: _servoOutput && !isNaN(_servo_btn1.rawValue) ? _servo_btn1.rawValue : 0
            color: !enabled ? "gray" : (servoVal > _pwmClose - 50 ? "green" : (servoVal > _pwmTrimm - 50 && servoVal < _pwmTrimm + 50 ? "orange" : (servoVal < _pwmOpen + 50 ? "red" : "orange")))

            Text {
                anchors.centerIn: parent
                text: "Drop1"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm
                        if (fuseEnabled) {
                            pwm = button01.servoVal > _pwmClose - 50 ? _pwmTrimm : _pwmClose
                        } else {
                            pwm = button01.servoVal < _pwmOpen + 50 ? _pwmTrimm : _pwmOpen
                        }
                        _activeVehicle.sendCommand(1, 183, false, _btn_setservo1, pwm)
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
            property real servoVal: _servoOutput && !isNaN(_servo_btn2.rawValue) ? _servo_btn2.rawValue : 0
            color: !enabled ? "gray" : (servoVal > _pwmClose - 50 ? "green" : (servoVal > _pwmTrimm - 50 && servoVal < _pwmTrimm + 50 ? "orange" : (servoVal < _pwmOpen + 50 ? "red" : "orange")))

            Text {
                anchors.centerIn: parent
                text: "Drop2"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm
                        if (fuseEnabled) {
                            pwm = button02.servoVal > _pwmClose - 50 ? _pwmTrimm : _pwmClose
                        } else {
                            pwm = button02.servoVal < _pwmOpen + 50 ? _pwmTrimm : _pwmOpen
                        }
                        _activeVehicle.sendCommand(1, 183, false, _btn_setservo2, pwm)
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
            property real servoVal: _servoOutput && !isNaN(_servo_btn3.rawValue) ? _servo_btn3.rawValue : 0
            color: !enabled ? "gray" : (servoVal > _pwmClose - 50 ? "green" : (servoVal > _pwmTrimm - 50 && servoVal < _pwmTrimm + 50 ? "orange" : (servoVal < _pwmOpen + 50 ? "red" : "orange")))

            Text {
                anchors.centerIn: parent
                text: "Drop3"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm
                        if (fuseEnabled) {
                            pwm = button03.servoVal > _pwmClose - 50 ? _pwmTrimm : _pwmClose
                        } else {
                            pwm = button03.servoVal < _pwmOpen + 50 ? _pwmTrimm : _pwmOpen
                        }
                        _activeVehicle.sendCommand(1, 183, false, _btn_setservo3, pwm)
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
            property real servoVal: _servoOutput && !isNaN(_servo_btn4.rawValue) ? _servo_btn4.rawValue : 0
            color: !enabled ? "gray" : (servoVal > _pwmClose - 50 ? "green" : (servoVal > _pwmTrimm - 50 && servoVal < _pwmTrimm + 50 ? "orange" : (servoVal < _pwmOpen + 50 ? "red" : "orange")))

            Text {
                anchors.centerIn: parent
                text: "Drop4"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        var pwm
                        if (fuseEnabled) {
                            pwm = button04.servoVal > _pwmClose - 50 ? _pwmTrimm : _pwmClose
                        } else {
                            pwm = button04.servoVal < _pwmOpen + 50 ? _pwmTrimm : _pwmOpen
                        }
                        _activeVehicle.sendCommand(1, 183, false, _btn_setservo4, pwm)
                    }
                }
            }
        }
    }

}
