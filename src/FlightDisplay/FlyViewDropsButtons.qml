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
    anchors.fill: parent
    anchors.margins: _toolsMargin

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _servoOutput:  _activeVehicle ? _activeVehicle.servoOutput : null
    property var _activeJoystick: joystickManager.activeJoystick
    property int _activationButtonId: 5
    property real _scrToolsUnit: ScreenTools.defaultFontPixelWidth
    property int _pwmClose: 2350
    property int _pwmTrimm: 1900
    property int _pwmOpen: 1000
    property int _btn_setservo1: 1
    property int _btn_setservo2: 2
    property int _btn_setservo3: 3
    property int _btn_setservo4: 4
    property var _servo_btn1: _activeVehicle ? _servoOutput.servo1 : null
    property var _servo_btn2: _activeVehicle ? _servoOutput.servo2 : null
    property var _servo_btn3: _activeVehicle ? _servoOutput.servo3 : null
    property var _servo_btn4: _activeVehicle ? _servoOutput.servo4 : null
    property bool fuseEnabled: true
    property int  _activeBtnIndex: 0
    property bool _commandInProgress: false
    property int  _commandBtnIndex: 0
    property var _buttons: []

    property var _trimServos: []
    property int _trimIndex: 0
    property bool _trimInProgress: false

    Component.onCompleted: {
        _buttons = [button01, button02, button03, button04]
    }

    function _setActiveButton(index) {
        _activeBtnIndex = index
        for (var i = 0; i < _buttons.length; i++) {
            var b = _buttons[i]
            b.activated = (i === index - 1)
        }
    }

    Timer {
        id: disableTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (_commandBtnIndex > 0 && _buttons.length >= _commandBtnIndex) {
                var btn = _buttons[_commandBtnIndex - 1]
                btn.disabled = true
                btn.activated = false
                btn.openInProgress = false
            }
            _activeBtnIndex = 0
            _commandBtnIndex = 0
        }
    }

    function _sendNextTrim() {
        if (_trimIndex < _trimServos.length) {
            var servo = _trimServos[_trimIndex]
            _trimIndex += 1
            _activeVehicle.sendCommand(1, 183, false, servo, _pwmTrimm)
        } else {
            _trimInProgress = false
        }
    }


    Timer {
        id: trimTimer
        interval: 5000
        repeat: false
        onTriggered: {
            if (_activeVehicle && !_activeVehicle.armed && !_trimInProgress) {
                _trimServos = [_btn_setservo1, _btn_setservo2, _btn_setservo3, _btn_setservo4]
                _trimIndex = 0
                _trimInProgress = true
                _sendNextTrim()
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
            _trimInProgress = false
        }
    }

    Connections {
        target: _activeVehicle
        onMavCommandResult: {
            if (_trimInProgress && command === 183 && ackResult !== 5) {
                _sendNextTrim()
            }
            if (_commandInProgress && command === 183) {
                _commandInProgress = false
                if (ackResult === 0) {
                    disableTimer.restart()
                } else {
                    if (_commandBtnIndex > 0 && _buttons.length >= _commandBtnIndex) {
                        var btn = _buttons[_commandBtnIndex - 1]
                        btn.openInProgress = false
                    }
                    _commandBtnIndex = 0
                }
            }
        }
    }

    Connections {
        target:                 _activeJoystick
        ignoreUnknownSignals:   true
        function showBtnMessage(btnIndex, pressed) {
            if (pressed) {
                var name = btnIndex
                if (_activeJoystick && _activeJoystick.buttonActions && btnIndex < _activeJoystick.buttonActions.length) {
                    var action = _activeJoystick.buttonActions[btnIndex]
                    if (action && action !== _activeJoystick.disabledActionName) {
                        name = action
                    }
                }
                mainWindow.showMessageDialog(qsTr("Joystick Button"), qsTr("%1 pressed").arg(name))
            }
        }
        onButtonPressed: {
            if (buttonId === _activationButtonId && pressed) {
                if (!fuseEnabled && _activeBtnIndex > 0 && !_commandInProgress && _activeVehicle) {
                    _commandInProgress = true
                    _commandBtnIndex = _activeBtnIndex
                    var servo
                    if (_activeBtnIndex === 1)        servo = _btn_setservo1
                    else if (_activeBtnIndex === 2)   servo = _btn_setservo2
                    else if (_activeBtnIndex === 3)   servo = _btn_setservo3
                    else                               servo = _btn_setservo4

                    var btn = _buttons[_activeBtnIndex - 1]
                    btn.openInProgress = true
                    _activeVehicle.sendCommand(1, 183, false, servo, _pwmOpen)
                }
            }
        }
    }


    Column {
        id: buttonColumn
        spacing: _scrToolsUnit * 2
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: _scrToolsUnit * 10
        //anchors.leftMargin: _scrToolsUnit * 1

        Rectangle {
            id: fuseButton
            width: _scrToolsUnit * 10
            height: _scrToolsUnit * 4
            radius: 4
            border.color: "red"
            border.width: 2
            color: fuseEnabled ? "green" : "red"

            Text {
                anchors.centerIn: parent
                text: "Safety"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    fuseEnabled = !fuseEnabled
                    if (!fuseEnabled) {
                        _setActiveButton(0)
                    }
                }
            }
        }

        Rectangle {
            id: button01
            property bool disabled: false
            property bool activated: false
            property bool openInProgress: false
            enabled: (_activeVehicle ? true : false) && !disabled
            width: _scrToolsUnit * 10
            height: _scrToolsUnit * 4
            radius: 4
            border.color: "white"
            border.width: 2
            property real servoVal: _servoOutput && !isNaN(_servo_btn1.rawValue) ? _servo_btn1.rawValue : 0
            color: disabled ? Qt.rgba(0,0,0,0) : (fuseEnabled ?
                    (servoVal > _pwmClose - 25 ? "green" : (servoVal > _pwmTrimm - 25 && servoVal < _pwmTrimm + 25 ? "yellow" : (servoVal < _pwmOpen + 50 ? "red" : "orange"))) :
                    (openInProgress ? "red" : (activated ? "orange" : "green")))

            Text {
                anchors.centerIn: parent
                text: "Drop1"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        if (fuseEnabled) {
                            var pwm = button01.servoVal > _pwmClose - 25 ? _pwmTrimm : _pwmClose
                            _activeVehicle.sendCommand(1, 183, false, _btn_setservo1, pwm)
                        } else if (!button01.disabled && !button01.openInProgress) {
                            _setActiveButton(1)
                        }
                    }
                }
            }
        }

        Rectangle {
            id: button02
            property bool disabled: false
            property bool activated: false
            property bool openInProgress: false
            enabled: (_activeVehicle ? true : false) && !disabled
            width: _scrToolsUnit * 10
            height: _scrToolsUnit * 4
            radius: 4
            border.color: "white"
            border.width: 2
            property real servoVal: _servoOutput && !isNaN(_servo_btn2.rawValue) ? _servo_btn2.rawValue : 0
            color: disabled ? Qt.rgba(0,0,0,0) : (fuseEnabled ?
                    (servoVal > _pwmClose - 25 ? "green" : (servoVal > _pwmTrimm - 25 && servoVal < _pwmTrimm + 25 ? "yellow" : (servoVal < _pwmOpen + 50 ? "red" : "orange"))) :
                    (openInProgress ? "red" : (activated ? "orange" : "green")))

            Text {
                anchors.centerIn: parent
                text: "Drop2"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        if (fuseEnabled) {
                            var pwm = button02.servoVal > _pwmClose - 25 ? _pwmTrimm : _pwmClose
                            _activeVehicle.sendCommand(1, 183, false, _btn_setservo2, pwm)
                        } else if (!button02.disabled && !button02.openInProgress) {
                            _setActiveButton(2)
                        }
                    }
                }
            }
        }

        Rectangle {
            id: button03
            property bool disabled: false
            property bool activated: false
            property bool openInProgress: false
            enabled: (_activeVehicle ? true : false) && !disabled
            width: _scrToolsUnit * 10
            height: _scrToolsUnit * 4
            radius: 4
            border.color: "white"
            border.width: 2
            property real servoVal: _servoOutput && !isNaN(_servo_btn3.rawValue) ? _servo_btn3.rawValue : 0
            color: disabled ? Qt.rgba(0,0,0,0) : (fuseEnabled ?
                    (servoVal > _pwmClose - 25 ? "green" : (servoVal > _pwmTrimm - 25 && servoVal < _pwmTrimm + 25 ? "yellow" : (servoVal < _pwmOpen + 50 ? "red" : "orange"))) :
                    (openInProgress ? "red" : (activated ? "orange" : "green")))

            Text {
                anchors.centerIn: parent
                text: "Drop3"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        if (fuseEnabled) {
                            var pwm = button03.servoVal > _pwmClose - 25 ? _pwmTrimm : _pwmClose
                            _activeVehicle.sendCommand(1, 183, false, _btn_setservo3, pwm)
                        } else if (!button03.disabled && !button03.openInProgress) {
                            _setActiveButton(3)
                        }
                    }
                }
            }
        }

        Rectangle {
            id: button04
            property bool disabled: false
            property bool activated: false
            property bool openInProgress: false
            enabled: (_activeVehicle ? true : false) && !disabled
            width: _scrToolsUnit * 10
            height: _scrToolsUnit * 4
            radius: 4
            border.color: "white"
            border.width: 2
            property real servoVal: _servoOutput && !isNaN(_servo_btn4.rawValue) ? _servo_btn4.rawValue : 0
            color: disabled ? Qt.rgba(0,0,0,0) : (fuseEnabled ?
                    (servoVal > _pwmClose - 25 ? "green" : (servoVal > _pwmTrimm - 25 && servoVal < _pwmTrimm + 25 ? "yellow" : (servoVal < _pwmOpen + 50 ? "red" : "orange"))) :
                    (openInProgress ? "red" : (activated ? "orange" : "green")))

            Text {
                anchors.centerIn: parent
                text: "Drop4"
                color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_activeVehicle) {
                        if (fuseEnabled) {
                            var pwm = button04.servoVal > _pwmClose - 25 ? _pwmTrimm : _pwmClose
                            _activeVehicle.sendCommand(1, 183, false, _btn_setservo4, pwm)
                        } else if (!button04.disabled && !button04.openInProgress) {
                            _setActiveButton(4)
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: resetButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: _scrToolsUnit * 20
        width: _scrToolsUnit * 10
        height: _scrToolsUnit * 4
        radius: 4
        border.color: "white"
        border.width: 2
        color: "blue"

        Text {
            anchors.centerIn: parent
            text: "Reset"
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                for (var i = 0; i < _buttons.length; i++) {
                    _buttons[i].disabled = false
                    _buttons[i].openInProgress = false
                }
                _setActiveButton(0)
            }
        }
    }
}
