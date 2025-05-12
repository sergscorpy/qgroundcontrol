import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12
import QtQuick.Shapes           1.12

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Airmap        1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.GimbalTools   1.0

Item {
    id: flyViewKazhan
    width: 180
    height: 80

    SdkSender {
        id: sdkSender
    }

    QGCButton {
        id: thermalModeButton
        text: qsTr("Thermal")
        anchors.fill: parent
        font.pointSize: ScreenTools.defaultFontPointSize + 4
        opacity: 0.95
        z: 1000
        checkable: false
        down: false

        anchors.margins: 6

        property real normalScale: 1.0
        property real pressedScale: 0.92

        scale: normalScale

        background: Rectangle {
            anchors.fill: parent
            radius: 6
            color: QGroundControl.globalTheme.buttonBackground
            border.color: QGroundControl.globalTheme.buttonBorder
            border.width: 1
        }

        contentItem: Text {
            text: thermalModeButton.text
            color: QGroundControl.globalTheme.text
            font.pointSize: thermalModeButton.font.pointSize
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onPressed: {
            scale = pressedScale;
        }

        onReleased: {
            scale = normalScale;
        }

        onClicked: {
            sdkSender.changeColorSchema()
        }

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
    }
}
