import QtQuick 2.12
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.4
import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Dialogs 1.2

import QGroundControl 1.0
import QGroundControl.Airspace 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.Controls 1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Vehicle 1.0

Item {
    id: crosshairRoot
    anchors.fill: parent

    property var  vehicle:      globals.activeVehicle
    property real _rollAngle:   vehicle ? vehicle.roll.rawValue  : 0
    property real _pitchAngle:  vehicle ? vehicle.pitch.rawValue : 0

    property int  xc: width / 2
    property int  yc: height / 2

    // Фокусна відстань камери
    property real focalLength: 1000

    property real scrUnit: height / 20

    // Обчислення зміщення індикатора
    property real dx: Math.tan(_rollAngle * Math.PI / 180) * focalLength
    property real dy: Math.tan(_pitchAngle * Math.PI / 180) * focalLength



    Image {
        id: crossHair1
        anchors.centerIn: parent
        source: "/qmlimages/crosshair_1.svg"
        mipmap: true
        height: parent.height * 0.79
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: toggleSwitch.checked
    }

    Image {
        id: crossHair2
        anchors.centerIn: parent
        source: "/qmlimages/crosshair_2.svg"
        mipmap: true
        height: parent.height * 0.55
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: toggleSwitch.checked
    }

    Image {
        id: aim
        source: "/qmlimages/crosshair_2.svg"
        mipmap: true
        height: parent.height * 0.12
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: toggleSwitchAim.checked

        // Переміщення від центру
        x: xc + dx - width / 2
        y: yc + dy - height / 2
    }

    Shape {
        id: connectionLine
        width: parent.width
        height: parent.height
        anchors.fill: parent
        visible: toggleSwitchAim.checked

        ShapePath {
            strokeWidth: 3
            strokeColor: "lightgreen"

            startX: xc
            startY: yc

            PathLine {
                x: aim.x + aim.width / 2
                y: aim.y + aim.height / 2
            }
        }
    }


    Text {
        text: "Roll: " + _rollAngle.toFixed(2) + "°, Pitch: " + _pitchAngle.toFixed(2) + "°"
        font.pointSize: 16
        font.bold: false
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 30
        anchors.topMargin: 700
        color: "white"
    }

    Text {
        text: "dx: " + dx.toFixed(2) + "  dy: " + dy.toFixed(2)
        font.pointSize: 16
        font.bold: false
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 30
        anchors.topMargin: 750
        color: "white"
    }

    Switch {
        id: toggleSwitch
        checked: true
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 300
        anchors.leftMargin: 100
        visible: true


        indicator: Image {
            source: toggleSwitch.checked ? "/qmlimages/But_green.png" : "/qmlimages/But_red_1.png"
            mipmap: true
            sourceSize.height: 2*scrUnit
            fillMode: Image.PreserveAspectCrop
            anchors.left: parent.left
            anchors.bottom: parent.bottom

        }
    }
    Switch {
        id: toggleSwitchAim
        checked: true
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 400
        anchors.leftMargin: 100
        visible: true


        indicator: Image {
            source: toggleSwitchAim.checked ? "/qmlimages/But_green.png" : "/qmlimages/But_red_2.png"
            mipmap: true
            sourceSize.height: 2*scrUnit
            fillMode: Image.PreserveAspectCrop
            anchors.left: parent.left
            anchors.bottom: parent.bottom

        }
    }

}
