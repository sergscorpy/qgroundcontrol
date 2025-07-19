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
    visible: ButtonProfileManager.activeProfileFact && ButtonProfileManager.activeProfileFact.rawValue >= 0

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _servoOutput:  _activeVehicle ? _activeVehicle.servoOutput : null
    property var _activeJoystick: joystickManager.activeJoystick
    property int _activationButtonId: 5
    property real _scrToolsUnit: ScreenTools.defaultFontPixelWidth
    property int _pwmClose: 2350
    property int _pwmTrimm: 1900
    property int _pwmOpen: 1000
    property var _buttonConfig: ButtonProfileManager.activeProfile
    property bool fuseEnabled: true
    property int  _activeBtnIndex: 0
    property bool _commandInProgress: false
    property int  _commandBtnIndex: 0
    property var _buttons: []

    property var _trimServos: []
    property int _trimIndex: 0
    property bool _trimInProgress: false

    Component.onCompleted: {
        _setActiveButton(0)
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
        interval: 500
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
        if (!_activeVehicle) {
            _trimInProgress = false
            return
        }
        if (_trimIndex < _trimServos.length) {
            var cfg = _trimServos[_trimIndex]
            _trimIndex += 1
            _activeVehicle.sendCommand(1, 183, false, cfg.servo, cfg.pwmTrimm)
        } else {
            _trimInProgress = false
        }
    }


    Timer {
        id: trimTimer
        interval: 5000
        repeat: false
        onTriggered: {
            if (_activeVehicle && !_activeVehicle.armed && !_trimInProgress && _buttonConfig.length > 0) {
                _trimServos = _buttonConfig
                _trimIndex = 0
                _trimInProgress = true
                _sendNextTrim()
            }
        }
    }

    Timer {
        id: trimDelayTimer
        interval: 1000
        repeat: false
        onTriggered: _sendNextTrim()
    }

    Connections {
        target: QGroundControl.multiVehicleManager
        onActiveVehicleChanged: {
            if (_activeVehicle && !_activeVehicle.armed && _buttonConfig.length > 0) {
                trimTimer.restart()
            } else {
                trimTimer.stop()
                trimDelayTimer.stop()
            }
            _trimInProgress = false
        }
    }

    Connections {
        target: ButtonProfileManager
        onActiveProfileChanged: {
            _buttonConfig = ButtonProfileManager.activeProfile
            _setActiveButton(0)
        }
    }

    Connections {
        target: _activeVehicle
        onMavCommandResult: {
            if (_trimInProgress && command === 183 && ackResult !== 5) {
                trimDelayTimer.restart()
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
        target: QGroundControl.settingsManager.buttonsSettings.activeProfile
        onRawValueChanged: {
            ButtonProfileManager.updateActiveProfile()
        }
    }

    Connections {
        target:                 _activeJoystick
        ignoreUnknownSignals:   true
        onButtonPressed: {
            if (buttonId === _activationButtonId && pressed) {
                if (!fuseEnabled && _activeBtnIndex > 0 && !_commandInProgress && _activeVehicle) {
                    _commandInProgress = true
                    _commandBtnIndex = _activeBtnIndex
                    var cfg = _buttonConfig[_activeBtnIndex - 1]
                    var servo = cfg ? cfg.servo : _activeBtnIndex
                    var pwm = cfg ? cfg.pwmOpen : _pwmOpen

                    var btn = _buttons[_activeBtnIndex - 1]
                    btn.openInProgress = true
                    _activeVehicle.sendCommand(1, 183, false, servo, pwm)
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
            border.color: "#990000"
            border.width: 3
            color: fuseEnabled ? "green" : "#990000"

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
            height: _scrToolsUnit * 1
            width: _scrToolsUnit * 10
            color: "transparent"
        }

        Repeater {
            id: buttonRepeater
            model: _buttonConfig
            onItemAdded: {
                _buttons.splice(index, 0, item)
            }
            onItemRemoved: {
                _buttons.splice(index, 1)
            }
            delegate: DropCommandButton {
                index: index + 1
                config: modelData
                activeVehicle: _activeVehicle
                servoOutput: _servoOutput
                fuseEnabled: fuseEnabled
                scrToolsUnit: _scrToolsUnit
                setActiveButtonCallback: function(i) { _setActiveButton(i) }
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
        border.width: 3
        color: "#1a4dcc"

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
                fuseEnabled = true
                if (_activeVehicle && !_activeVehicle.armed) {
                    _trimServos = _buttonConfig
                    _trimIndex = 0
                    _trimInProgress = true
                    _sendNextTrim()
                }
            }
        }
    }
}
