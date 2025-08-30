import QtQuick 2.12

Rectangle {
    id: button
    property int buttonIndex: 1
    property var config: ({servo:buttonIndex, pwmOpen:pwmOpenDefault, pwmTrimm:pwmTrimDefault, pwmClose:pwmCloseDefault})
    property var activeVehicle
    property var lockStatus
    property bool fuseEnabled: true
    property real scrToolsUnit: 1
    property bool activated: false
    property bool openInProgress: false
    signal resetOpenInProgress()
    property int pwmOpenDefault: 1000
    property int pwmTrimDefault: 1900
    property int pwmCloseDefault: 2350
    property var commandFinishedCallback

    Timer {
        id: openProgressResetTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            resetOpenInProgress()
            if (commandFinishedCallback) {
                commandFinishedCallback(buttonIndex)
            }
        }
    }

    width: scrToolsUnit * 10
    height: scrToolsUnit * 4
    radius: 4
    border.color: "white"
    border.width: 3
    property var lockFact: lockStatus && config ? lockStatus["chan" + buttonIndex] : null
    property bool locked: false
    enabled: activeVehicle

    color: !locked
           ? Qt.rgba(0,0,0,0)
           : fuseEnabled
                ? "green"
                : openInProgress
                    ? "#990000"
                    : activated
                        ? "#b34d00"
                        : "green"

    Text {
        id: text
        anchors.centerIn: parent
        text: config.buttonName ? config.buttonName : ("Drop" + buttonIndex)
        color: "white"
    }

    Component.onCompleted: {
        if (lockFact) {
            button.locked = lockFact.rawValue
        }
    }

    onOpenInProgressChanged: {
        console.log("Кнопка", buttonIndex, "openInProgress =", openInProgress)
        if (openInProgress) {
            openProgressResetTimer.restart()
        } else {
            openProgressResetTimer.stop()
        }
    }

    Connections {
        target: lockFact
        onRawValueChanged: {
            if (activeVehicle) {
                var pwm = lockFact.rawValue ? config.pwmClose : config.pwmTrimm
                activeVehicle.sendCommand(1, 183, false, config.servo, pwm)
                console.log("sendCommand: servo = ", config.servo, "   PWM = ", pwm, lockFact.rawValue, "   Btn%N = ", buttonIndex)
            }
            button.locked = lockFact.rawValue
            openProgressResetTimer.stop()
            if (lockFact.rawValue) {
                resetOpenInProgress()
            } else {
                button.activated = false
                resetOpenInProgress()
            }
            if (commandFinishedCallback) {
                commandFinishedCallback(buttonIndex)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !fuseEnabled && activeVehicle && !openInProgress && locked
        onClicked: {
            button.activated = !button.activated
        }
    }
}
