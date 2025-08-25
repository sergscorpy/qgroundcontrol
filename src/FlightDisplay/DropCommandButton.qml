import QtQuick 2.12

Rectangle {
    id: button
    property int buttonIndex: 1
    property var config: ({servo:buttonIndex, pwmOpen:pwmOpenDefault, pwmTrimm:pwmTrimDefault, pwmClose:pwmCloseDefault})
    property var activeVehicle
    property var lockStatus
    property bool fuseEnabled: true
    property real scrToolsUnit: 1
    property bool disabled: false
    property bool activated: false
    property bool openInProgress: false
    property int pwmOpenDefault: 1000
    property int pwmTrimDefault: 1900
    property int pwmCloseDefault: 2350
    property var setActiveButtonCallback

    width: scrToolsUnit * 10
    height: scrToolsUnit * 4
    radius: 4
    border.color: "white"
    border.width: 3
    property var lockFact: lockStatus && config ? lockStatus["chan" + buttonIndex] : null
    property bool locked: lockFact ? lockFact.rawValue : false
    enabled: (activeVehicle ? true : false) && !disabled && (fuseEnabled || locked)

    color: disabled ? Qt.rgba(0,0,0,0) :
            (fuseEnabled
                ? (locked ? "green" : Qt.rgba(0,0,0,0))
                : (locked
                    ? (openInProgress ? "#990000" : (activated ? "#b34d00" : "green"))
                    : Qt.rgba(0,0,0,0)))

    Text {
        id: text
        anchors.centerIn: parent
        text: config.buttonName ? config.buttonName : ("Drop" + buttonIndex)
        color: "white"
    }

    Connections {
        target: lockFact
        onRawValueChanged: {
            if (activeVehicle) {
                var pwm = lockFact.rawValue ? config.pwmClose : config.pwmTrimm
                activeVehicle.sendCommand(1, 183, false, config.servo, pwm)
                console.log("sendCommand: servo = ", config.servo, "   PWM = ", pwm, lockFact.rawValue, "   Btn%N = ", buttonIndex)
            }
            if (lockFact.rawValue) {
                button.disabled = false
                button.openInProgress = false
            } else {
                button.disabled = true
                button.activated = false
                button.openInProgress = false
                if (setActiveButtonCallback) {
                    setActiveButtonCallback(0)
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: !fuseEnabled && activeVehicle && !button.disabled && !button.openInProgress && locked
        onClicked: {
            if (setActiveButtonCallback) setActiveButtonCallback(buttonIndex)
        }
    }
}
