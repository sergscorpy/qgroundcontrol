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
    id: cameraControl
    visible: _cameraSettings.cameraType.value !== 2

    property SdkSender _sdkSender

    FlyView49KSCrossHair {
        id: crossHair
        anchors.fill: parent
    }
    
    Timer {
        id: gimbalModeUpdateTimer
        interval: 10000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: sdkSender.requestGimbalMode()
    }
    
    Timer {
        id: delayedModeRequestTimer
        interval: 1000
        repeat: false
        running: false
        onTriggered: sdkSender.requestGimbalMode()
    }
    
    Timer {
        id: disableTimer
        interval: 1500    // 5 секунд
        repeat: false
        running: false
    }
    
    Rectangle { // Загальний блок у вигляді шторки з ліва
        id:                 leftControlPanel
        anchors.top:        parent.top
        anchors.left:       parent.left
        width:              collapsed && !isA8mini ? 0 : _btnWidth + _scrMargins * 2
        height: collapsed
                ? _btnHeight * 3 + _scrMargins * 4
                : crosshairRoot.height - _scrMargins // - _pipOverlay.height
        color:      "#00000000"
        //radius:     _scrToolsUnit
        
        property bool collapsed: true
        
        Image {
            id:             hideBar
            source:         leftControlPanel.collapsed ? "/qmlimages/49ks/barShow.svg" : "/qmlimages/49ks/barHide.svg"
            mipmap:         true
            fillMode:       Image.PreserveAspectFit
            anchors.left:   leftControlPanel.right
            anchors.top:    leftControlPanel.top
            visible:        true
            height:         _btnHeight + _scrMargins * 2 // _scrToolsUnit * 8
            width:          _btnHeight + _scrMargins * 2 // _scrToolsUnit * 8
            sourceSize.height:  height
            
        }
        Item {
            id: mouseHideBar
            anchors.left:   leftControlPanel.right
            anchors.top:    leftControlPanel.top
            height:         _scrToolsUnit * 10
            width:          _scrToolsUnit * 10
            MouseArea {
                anchors.fill:   parent
                onClicked:      leftControlPanel.collapsed = !leftControlPanel.collapsed
                cursorShape:    Qt.PointingHandCursor
            }
        }
        
        Column { // Column "Приціл"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: _scrMargins
            anchors.margins: _scrMargins
            
            Button { // Button "Скид"
                id: dropp
                enabled: !disableTimer.running
                visible: _cameraSettings.cameraType.value === 0 //isAndroid
                width: _btnWidth
                height: _btnHeight
                onClicked: {
                    sdkSender.activateAimMode()
                    delayedModeRequestTimer.restart()
                    disableTimer.start()
                }
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem1
                        source: textItem1
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: !parent.enabled ? 0 : 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem1
                        anchors.centerIn: parent
                        text: "Скид"
                        font.pointSize: 10
                        font.bold: false
                        color: !parent.enabled ? "darkgray" : "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color: sdkSender.gimbalMode === 1
                           ? (parent.down ? "#66008B00" : "#e6005900")
                           : (parent.down ? "#33000000" : "#66000000")
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Button { // Button "Політ"
                enabled: !disableTimer.running
                visible: _cameraSettings.cameraType.value === 0 //isAndroid
                width: _btnWidth
                height: _btnHeight
                onClicked: {
                    sdkSender.activateFPVMode()
                    delayedModeRequestTimer.restart()
                    disableTimer.start()
                }
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem2
                        source: textItem2
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: !parent.enabled ? 0 : 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem2
                        anchors.centerIn: parent
                        text: "Політ"
                        font.pointSize: 10
                        font.bold: false
                        color: !parent.enabled ? "darkgray" : "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color: sdkSender.gimbalMode === 2
                           ? (parent.down ? "#66008B00" : "#e6005900")
                           : (parent.down ? "#33000000" : "#66000000")
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Button { // Button "Баліст."
                id: toggleSwitchAim
                visible: _cameraSettings.cameraType.value === 0 && _flyViewSettings.crossHair.value
                width: _btnWidth
                height: _btnHeight
                property bool isChecked: false
                onClicked: {
                    isChecked = !isChecked
                }
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem3
                        source: textItem3
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem3
                        anchors.centerIn: parent
                        text: "Баліст."
                        font.pointSize: 10
                        font.bold: false
                        color: "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color: parent.isChecked
                           ? (parent.down ? "#66008B00" : "#e6005900")
                           : (parent.down ? "#33000000" : "#66000000")
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Label { // Label "Video"
                id: labelReboot
                visible: !leftControlPanel.collapsed
                text: " "
                font.pointSize: 3
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: _scrMargins
                color: "white"
            }
            
            Button { // Button "Камера"
                visible: _cameraSettings.cameraType.value === 0 && !leftControlPanel.collapsed
                width: _btnWidth
                height: _btnHeight
                enabled: !sdkSender.cameraCommandInProgress
                onClicked: sdkSender.sendRebootCamera()
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem4
                        source: textItem4
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: !parent.enabled ? 0 : 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem4
                        anchors.centerIn: parent
                        text: "Камера"
                        font.pointSize: 10
                        font.bold: false
                        color: !parent.enabled ? "darkgray" : "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color:  !parent.enabled ? "#66000000"
                                            : parent.down   ? "#33000000"
                                                            : "#66000000"
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Button { // Button "Гімбал"
                visible: _cameraSettings.cameraType.value === 0 && !leftControlPanel.collapsed
                width: _btnWidth
                height: _btnHeight
                enabled: !sdkSender.gimbalCommandInProgress
                onClicked: sdkSender.sendRebootGimbal()
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem5
                        source: textItem5
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: !parent.enabled ? 0 : 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem5
                        anchors.centerIn: parent
                        text: "Гімбал"
                        font.pointSize: 10
                        font.bold: false
                        color: !parent.enabled ? "darkgray" : "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color:  !parent.enabled ? "#66000000"
                                            : parent.down   ? "#33000000"
                                                            : "#66000000"
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Label { // Label "Video"
                id: labelVideo
                visible: !leftControlPanel.collapsed
                text: " "
                font.pointSize: 3
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: _scrMargins
                color: "white"
            }
            
            Button { // Button "HDMI PC"
                visible: !leftControlPanel.collapsed && !isAndroid
                width: _btnWidth
                height: _btnHeight
                property bool isChecked: _videoSettings.videoSource.rawValue === "Herelink Hotspot"
                enabled: true
                onClicked: _videoSettings.videoSource.rawValue = "Herelink Hotspot"
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem6
                        source: textItem6
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem6
                        anchors.centerIn: parent
                        text: "HotSpot"
                        font.pointSize: 10
                        font.bold: false
                        color: "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color: parent.isChecked
                           ? (parent.down ? "#66008B00" : "#e6005900")
                           : (parent.down ? "#33000000" : "#66000000")
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Button { // Button "HDMI PC Router"
                visible: !leftControlPanel.collapsed && !isAndroid
                width: _btnWidth
                height: _btnHeight
                property bool isChecked: _videoSettings.videoSource.rawValue === "Herelink Hotspot (Dynamic)"
                enabled: true
                onClicked: {
                    _videoSettings.videoSource.rawValue = "Herelink Hotspot (Dynamic)"
                }
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem7
                        source: textItem7
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem7
                        anchors.centerIn: parent
                        text: "Router"
                        font.pointSize: 10
                        font.bold: false
                        color: "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color: parent.isChecked
                           ? (parent.down ? "#66008B00" : "#e6005900")
                           : (parent.down ? "#33000000" : "#66000000")
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Button { // Button "HDMI Android"
                visible: _cameraSettings.cameraType.value === 0 && !leftControlPanel.collapsed && isAndroid
                width: _btnWidth
                height: _btnHeight
                property bool isChecked: _videoSettings.videoSource.rawValue === "Herelink AirUnit"
                enabled: true
                onClicked: _videoSettings.videoSource.rawValue = "Herelink AirUnit"
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem8
                        source: textItem8
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem8
                        anchors.centerIn: parent
                        text: "HDMI"
                        font.pointSize: 10
                        font.bold: false
                        color: "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color: parent.isChecked
                           ? (parent.down ? "#66008B00" : "#e6005900")
                           : (parent.down ? "#33000000" : "#66000000")
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Button { // Button "IP Video" Android
                visible: _cameraSettings.cameraType.value === 0 && !leftControlPanel.collapsed && isAndroid
                width: _btnWidth
                height: _btnHeight
                property bool isChecked: _videoSettings.videoSource.rawValue === "IP Camera Stream"
                enabled: true
                onClicked: _videoSettings.videoSource.rawValue = "IP Camera Stream"
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem9
                        source: textItem9
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem9
                        anchors.centerIn: parent
                        text: "- IP -"
                        font.pointSize: 10
                        font.bold: false
                        color: "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color: parent.isChecked
                           ? (parent.down ? "#66008B00" : "#e6005900")
                           : (parent.down ? "#33000000" : "#66000000")
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Button { // Button "RTSP-1"
                visible: !leftControlPanel.collapsed && _cameraSettings.cameraType.value === 1
                width: _btnWidth
                height: _btnHeight
                property bool isChecked: _videoSettings.videoSource.rawValue === "RTSP Video Stream"
                enabled: true
                onClicked: _videoSettings.videoSource.rawValue = "RTSP Video Stream"
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem11
                        source: textItem11
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem11
                        anchors.centerIn: parent
                        text: "RTSP-1"
                        font.pointSize: 10
                        font.bold: false
                        color: "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color: parent.isChecked
                           ? (parent.down ? "#66008B00" : "#e6005900")
                           : (parent.down ? "#33000000" : "#66000000")
                    border.color: "#666666"
                    border.width: 1
                }
            }
            
            Button { // Button "RTSP-2"
                visible: !leftControlPanel.collapsed && _cameraSettings.cameraType.value === 1
                width: _btnWidth
                height: _btnHeight
                property bool isChecked: _videoSettings.videoSource.rawValue === "RTSP2 Video Stream"
                enabled: true
                onClicked: _videoSettings.videoSource.rawValue = "RTSP2 Video Stream"
                
                contentItem: Item {
                    anchors.fill: parent
                    
                    DropShadow {
                        anchors.fill: textItem10
                        source: textItem10
                        horizontalOffset: 1
                        verticalOffset: 1
                        radius: 6
                        color: "#000000"
                    }
                    
                    Text {
                        id: textItem10
                        anchors.centerIn: parent
                        text: "RTSP-2"
                        font.pointSize: 10
                        font.bold: false
                        color: "white"
                    }
                }
                
                background: Rectangle {
                    anchors.fill: parent
                    radius: _btnRadius
                    color: parent.isChecked
                           ? (parent.down ? "#66008B00" : "#e6005900")
                           : (parent.down ? "#33000000" : "#66000000")
                    border.color: "#666666"
                    border.width: 1
                }
            }
        }
    }
}
