import QtQuick 2.12

Rectangle {
    id: button
    property int buttonIndex: 1
    property var config: ({servo:buttonIndex, pwmOpen:pwmOpenDefault, pwmTrimm:pwmTrimmDefault, pwmClose:pwmCloseDefault})
    property var activeVehicle
    property var servoOutput
    property var lockStatus
    property bool fuseEnabled: true
    property real scrToolsUnit: 1
    property bool disabled: false
    property bool activated: false
    property bool openInProgress: false
    property int pwmOpenDefault: 1000
    property int pwmTrimmDefault: 1900
    property int pwmCloseDefault: 2350
    property var setActiveButtonCallback

    width: scrToolsUnit * 10
    height: scrToolsUnit * 4
    radius: 4
    border.color: "white"
    border.width: 3
    enabled: (activeVehicle ? true : false) && !disabled

    property real servoVal: servoOutput && config ? servoOutput["servo" + config.servo].rawValue : 0
    property var lockFact: lockStatus && config ? lockStatus["chan" + buttonIndex] : null

    color: disabled ? Qt.rgba(0,0,0,0) : (fuseEnabled ?
            (servoVal > config.pwmClose - 25 ? "green" : (servoVal > config.pwmTrimm - 25 && servoVal < config.pwmTrimm + 25 ? "#cc9900" : (servoVal < config.pwmOpen + 50 ? "#990000" : "#b34d00"))) :
            (openInProgress ? "#990000" : (activated ? "#b34d00" : "green")))

    Text {
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
                console.log("sendCommand: servo = ", config.servo, "   PWM = ", pwm, "   Btn%N = ", buttonIndex)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!fuseEnabled && activeVehicle && !button.disabled && !button.openInProgress)
                if (setActiveButtonCallback) setActiveButtonCallback(buttonIndex)
        }
    }
}
