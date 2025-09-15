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
    property bool _commandInProgress: false
    property bool _autoCommandEnabled: false
    property var _pendingCommandIndices: []

    ListModel {
        id: buttonModel
    }

    Component.onCompleted: {
        _populateButtonModel()
        _syncServoStates()
    }

    function _populateButtonModel() {
        buttonModel.clear()
        if (_buttonConfig) {
            var count = Math.min(_buttonConfig.length, 8)
            for (var i = 0; i < count; i++) {
                var lockFact = _lockStatus && _lockStatus["chan" + (i + 1)]
                               ? _lockStatus["chan" + (i + 1)].rawValue
                               : false
                buttonModel.append({ activated: false, openInProgress: false, locked: lockFact })
            }
        }
    }

    function _clearActiveButtons() {
        for (var i = 0; i < buttonModel.count; i++) {
            buttonModel.setProperty(i, "activated", false)
        }
    }

    function _logOpenInProgress() {
        var statuses = []
        for (var i = 0; i < buttonModel.count; i++) {
            statuses.push("Btn" + (i + 1) + "=" + buttonModel.get(i).openInProgress)
        }
        console.log("openInProgress statuses:", statuses.join(", "))
    }

    function _getActiveButtonIndices() {
        var active = []
        for (var i = 0; i < buttonModel.count; i++) {
            if (buttonModel.get(i).activated) {
                active.push(i + 1)
            }
        }
        return active
    }

    function _commandFinished(buttonIndex) {
        buttonModel.setProperty(buttonIndex - 1, "openInProgress", false)
        _logOpenInProgress()
        var idx = _pendingCommandIndices.indexOf(buttonIndex)
        if (idx !== -1) {
            _pendingCommandIndices.splice(idx, 1)
            if (_pendingCommandIndices.length === 0) {
                _commandInProgress = false
            }
        }
    }

    function _syncServoStates() {
        _autoCommandEnabled = false
        if (!_activeVehicle) {
            _autoCommandEnabled = true
            return
        }
        var idx = 0
        var sendNext = function() {
            if (idx >= buttonModel.count) {
                _autoCommandEnabled = true
                return
            }
            var cfg = _buttonConfig[idx]
            var lockFact = _lockStatus && _lockStatus["chan" + (idx + 1)]
            if (cfg && lockFact) {
                var pwm = lockFact.rawValue ? cfg.pwmClose : cfg.pwmTrimm
                _activeVehicle.sendCommand(1, 183, false, cfg.servo, pwm)
                console.log("syncCommand: servo = ", cfg.servo, "   PWM = ", pwm, lockFact.rawValue, "   Btn%N = ", idx + 1)
            }
            idx++
            var delayTimer = Qt.createQmlObject('import QtQuick 2.0; Timer { interval: 1500; running: true; repeat: false }', dropsButtons)
            delayTimer.triggered.connect(function() {
                delayTimer.destroy()
                sendNext()
            })
        }
        var startTimer = Qt.createQmlObject('import QtQuick 2.0; Timer { interval: 5000; running: true; repeat: false }', dropsButtons)
        startTimer.triggered.connect(function() {
            startTimer.destroy()
            sendNext()
        })
    }

    Connections {
        target: ButtonProfileManager
        onActiveProfileChanged: {
            _buttonConfig = ButtonProfileManager.activeProfile
            _populateButtonModel()
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
        target: QGroundControl.multiVehicleManager
        onActiveVehicleChanged: {
            _populateButtonModel()
            if (_activeVehicle) {
                _activeVehicle.sendCommand(1, 512, false, 252)
            }
            _syncServoStates()
        }
    }

    Connections {
        target:                 _activeVehicle
        ignoreUnknownSignals:   true
        onLockStatusChanged: {
            _populateButtonModel()
        }
    }

    Connections {
        target:                 _activeJoystick
        ignoreUnknownSignals:   true
        onButtonPressed: {
            if (buttonId === _activationButtonId && pressed) {
                var activeIndices = _getActiveButtonIndices()
                if (!fuseEnabled && activeIndices.length > 0 && !_commandInProgress && _activeVehicle) {
                    console.log("commandInProgress = ", _commandInProgress)
                    _commandInProgress = true
                    _pendingCommandIndices = activeIndices.slice()
                    console.log(_pendingCommandIndices)
                    var sendNext = function(j) {
                        if (j >= activeIndices.length) {
                            return
                        }
                        console.log("j = ", j)
                        var idx = activeIndices[j]
                        console.log("idx = ", idx)
                        var cfg = _buttonConfig[idx - 1]
                        var servo = cfg ? cfg.servo : idx
                        console.log("servo = ", servo)
                        var pwm = cfg ? cfg.pwmOpen : _pwmOpen
                        console.log("pwm = ", pwm)

                        buttonModel.setProperty(idx - 1, "openInProgress", true)
                        _logOpenInProgress()
                        _activeVehicle.sendCommand(1, 183, false, servo, pwm)
                        console.log("onButtonPressed: servo = ", servo, "   PWM = ", pwm)

                        var delayTimer = Qt.createQmlObject(
                            'import QtQuick 2.0; Timer { interval: 50; running: true; repeat: false }',
                            dropsButtons)
                        delayTimer.triggered.connect(function() {
                            delayTimer.destroy()
                            sendNext(j + 1)
                        })
                    }
                    sendNext(0)
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

        Rectangle {
            id: fuseButton
            width: _scrToolsUnit * 10
            height: _scrToolsUnit * 4

            color: "transparent"

            Image {
                anchors.fill: parent
                source: fuseEnabled ? "qrc:/qmlimages/Safe_On.svg" : "qrc:/qmlimages/Safe_Off.svg"
                fillMode: Image.PreserveAspectFit
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

        Grid {
            id: buttonGrid
            columns: 2
            rows: 4
            columnSpacing: _scrToolsUnit * 2
            rowSpacing: _scrToolsUnit * 2
            flow: Grid.TopToBottom
            Repeater {
                id: buttonRepeater
                model: buttonModel
                delegate: DropCommandButton {
                    id: button
                    buttonIndex: index + 1
                    config: _buttonConfig[index]
                    activeVehicle: _activeVehicle
                    lockStatus: _lockStatus
                    fuseEnabled: dropsButtons.fuseEnabled
                    scrToolsUnit: _scrToolsUnit
                    commandFinishedCallback: _commandFinished
                    autoCommandEnabled: dropsButtons._autoCommandEnabled
                    Binding { target: button; property: "activated"; value: model.activated }
                    Binding { target: button; property: "openInProgress"; value: model.openInProgress }
                    Binding { target: button; property: "locked"; value: model.locked }
                    onToggleActivated: buttonModel.setProperty(index, "activated", !model.activated)
                    onResetActivated: buttonModel.setProperty(index, "activated", false)
                    onResetOpenInProgress: {
                        buttonModel.setProperty(index, "openInProgress", false)
                        dropsButtons._logOpenInProgress()
                    }
                    onLockChanged: buttonModel.setProperty(index, "locked", locked)
                }
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
        visible: ScreenTools.isWindows
        color: "red"

        Text {
            anchors.centerIn: parent
            text: "DROP"
            color: "white"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var activeIndices = _getActiveButtonIndices()
                if (!fuseEnabled && activeIndices.length > 0 && !_commandInProgress && _activeVehicle) {
                    console.log("commandInProgress = ", _commandInProgress)
                    _commandInProgress = true
                    _pendingCommandIndices = activeIndices.slice()
                    console.log(_pendingCommandIndices)
                    var sendNext = function(j) {
                        if (j >= activeIndices.length) {
                            return
                        }
                        console.log("j = ", j)
                        var idx = activeIndices[j]
                        console.log("idx = ", idx)
                        var cfg = _buttonConfig[idx - 1]
                        var servo = cfg ? cfg.servo : idx
                        console.log("servo = ", servo)
                        var pwm = cfg ? cfg.pwmOpen : _pwmOpen
                        console.log("pwm = ", pwm)

                        buttonModel.setProperty(idx - 1, "openInProgress", true)
                        _logOpenInProgress()
                        _activeVehicle.sendCommand(1, 183, false, servo, pwm)
                        console.log("onButtonPressed: servo = ", servo, "   PWM = ", pwm)

                        var delayTimer = Qt.createQmlObject(
                            'import QtQuick 2.0; Timer { interval: 50; running: true; repeat: false }',
                            dropsButtons)
                        delayTimer.triggered.connect(function() {
                            delayTimer.destroy()
                            sendNext(j + 1)
                        })
                    }
                    sendNext(0)
                }
            }
        }
    }
}
