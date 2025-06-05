import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12
import QtQuick.Shapes           1.12
import QtGraphicalEffects       1.0

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QGroundControl               1.0
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
    id: crossHair

    Image {
        id: crossHair1
        anchors.centerIn: parent
        source: "/qmlimages/49ks/crosshair_1.svg"
        mipmap: true
        height: parent.width * 0.33
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: _flyViewSettings.crossHair.value
    }
    
    Image {
        id: aim
        source: "/qmlimages/49ks/crosshair_2.svg"
        mipmap: true
        height: parent.width * 0.05
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: toggleSwitchAim.isChecked && crossHair1.visible && rollPichMax && isA8mini
        
        // Переміщення від центру
        x: xc + dx - width / 2
        y: yc + dy - height / 2
    }
    
    Shape {
        id: connectionLine
        width: parent.width
        height: parent.height
        anchors.fill: parent
        visible: toggleSwitchAim.isChecked && crossHair1.visible && rollPichMax && isA8mini
        
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
}
