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
    signal toggleActivated()
    signal resetActivated()
    signal lockChanged(bool locked)
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
    property var lockFact: lockStatus && config ? lockStatus["chan" + buttonIndex] : null
    property bool locked: false
    enabled: activeVehicle

    color: Qt.rgba(0,0,0,0)

    Image {
        anchors.fill: parent
        source: !locked
               ? "qrc:/qmlimages/Drops_Empty.svg"
               : fuseEnabled
                    ? "qrc:/qmlimages/Drops_Green.svg"
                    : openInProgress
                        ? "qrc:/qmlimages/Drops_Red.svg"
                        : activated
                            ? "qrc:/qmlimages/Drops_Orange.svg"
                            : "qrc:/qmlimages/Drops_Green.svg"
        fillMode: Image.PreserveAspectFit
    }

    Text {
        id: text
        anchors.centerIn: parent
        text: "         " + buttonIndex
        color: "white"
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
            openProgressResetTimer.stop()
            lockChanged(lockFact.rawValue)
            if (lockFact.rawValue) {
                resetOpenInProgress()
            } else {
                resetActivated()
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
        onClicked: toggleActivated()
    }
}
