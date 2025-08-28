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
    property Fact activeProfileFact: QGroundControl.settingsManager.buttonsSettings.activeProfile
    property Fact profilesFact:      QGroundControl.settingsManager.buttonsSettings.profiles

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _lockStatus:   _activeVehicle ? _activeVehicle.lockStatus  : null
    property var _activeJoystick: joystickManager.activeJoystick
    property int _activationButtonId: 5
    property real _scrToolsUnit: ScreenTools.defaultFontPixelWidth
    property int _pwmClose: 2350
    property int _pwmTrimm: 1900
    property int _pwmOpen: 1000
    property var _buttonConfig: ButtonProfileManager.activeProfile
    property bool fuseEnabled: true
    property var _activeBtnIndices: []
    property bool _commandInProgress: false
    property var _pendingCommandIndices: []
    property var _buttons: []

    Component.onCompleted: {
        _clearActiveButtons()
    }

    function _clearActiveButtons() {
        _activeBtnIndices = []
        for (var i = 0; i < _buttons.length; i++) {
            _buttons[i].activated = false
        }
    }

    function _toggleButton(index, active) {
        if (active) {
            if (_activeBtnIndices.indexOf(index) === -1) {
                _activeBtnIndices.push(index)
            }
        } else {
            var idx = _activeBtnIndices.indexOf(index)
            if (idx !== -1) {
                _activeBtnIndices.splice(idx, 1)
            }
        }
    }

    function _commandFinished(buttonIndex) {
        var idx = _pendingCommandIndices.indexOf(buttonIndex)
        if (idx !== -1) {
            _pendingCommandIndices.splice(idx, 1)
            if (_pendingCommandIndices.length === 0) {
                _commandInProgress = false
            }
        }
    }

    Connections {
        target: ButtonProfileManager
        onActiveProfileChanged: {
            _buttonConfig = ButtonProfileManager.activeProfile
            _clearActiveButtons()
        }
    }

    Connections {
        target: _activeVehicle
        onMavCommandResult: {
            if (_commandInProgress && command === 183) {
                var idx = _pendingCommandIndices.shift()
                if (ackResult !== 0 && idx > 0 && _buttons.length >= idx) {
                    var btn = _buttons[idx - 1]
                    btn.openInProgress = false
                }
                if (_pendingCommandIndices.length === 0) {
                    _commandInProgress = false
                }
            }
        }
    }

    Connections {
        target: activeProfileFact
        onRawValueChanged: ButtonProfileManager.updateActiveProfile()
    }
    Connections {
        target: profilesFact
        onRawValueChanged: ButtonProfileManager.loadProfiles()
    }

    Connections {
        target:                 _activeJoystick
        ignoreUnknownSignals:   true
        onButtonPressed: {
            if (buttonId === _activationButtonId && pressed) {
                if (!fuseEnabled && _activeBtnIndices.length > 0 && !_commandInProgress && _activeVehicle) {
                    _commandInProgress = true
                    _pendingCommandIndices = _activeBtnIndices.slice()
                    for (var j = 0; j < _activeBtnIndices.length; j++) {
                        var idx = _activeBtnIndices[j]
                        var cfg = _buttonConfig[idx - 1]
                        var servo = cfg ? cfg.servo : idx
                        var pwm = cfg ? cfg.pwmOpen : _pwmOpen

                        var btn = _buttons[idx - 1]
                        btn.openInProgress = true
                        _activeVehicle.sendCommand(1, 183, false, servo, pwm)
                        console.log("onButtonPressed: servo = ", servo, "   PWM = ", pwm)
                    }
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
                        _clearActiveButtons()
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
                buttonIndex: index + 1
                config: modelData
                activeVehicle: _activeVehicle
                lockStatus: _lockStatus
                fuseEnabled: dropsButtons.fuseEnabled
                scrToolsUnit: _scrToolsUnit
                setActiveButtonCallback: function(i, active) { _toggleButton(i, active) }
                commandFinishedCallback: _commandFinished
            }
        }
    }

    Rectangle {
        id: openServoButton
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: _scrToolsUnit * 20
        width: _scrToolsUnit * 10
        height: _scrToolsUnit * 4
        radius: 4
        border.color: "white"
        border.width: 3

        color: "red"

        Text {
            anchors.centerIn: parent
            text: "DROP"
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!fuseEnabled && _activeBtnIndices.length > 0 && !_commandInProgress && _activeVehicle) {
                    console.log("commandInProgress = ", _commandInProgress)
                    _commandInProgress = true
                    _pendingCommandIndices = _activeBtnIndices.slice()
                    console.log(_pendingCommandIndices)
                    for (var j = 0; j < _activeBtnIndices.length; j++) {
                        console.log("j = ", j)
                        var idx = _activeBtnIndices[j]
                        console.log("idx = ", idx)
                        var cfg = _buttonConfig[idx - 1]
                        var servo = cfg ? cfg.servo : idx
                        console.log("servo = ", servo)
                        var pwm = cfg ? cfg.pwmOpen : _pwmOpen
                        console.log("pwm = ", pwm)

                        var btn = _buttons[idx - 1]
                        console.log("buttonIndex = ", btn.buttonIndex)
                        btn.openInProgress = true
                        console.log("openInProgress = ", btn.openInProgress)
                        _activeVehicle.sendCommand(1, 183, false, servo, pwm)
                        console.log("onButtonPressed: servo = ", servo, "   PWM = ", pwm)
                    }
                }
            }
        }
    }
}
