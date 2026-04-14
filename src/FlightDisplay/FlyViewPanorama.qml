/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.ScreenTools   1.0

Item {
    id:             _root
    anchors.fill:   parent
    visible:        _panoramaEnabled && _isGst

    property bool   _panoramaEnabled:   QGroundControl.settingsManager.videoSettings.panoramaEnabled.rawValue
    property bool   _isGst:             QGroundControl.videoManager.isGStreamer
    property bool   _fullMode:          false
    property real   _margin:            ScreenTools.defaultFontPixelWidth * 0.75

    Item {
        id:         panoramaFrame
        z:          QGroundControl.zOrderWidgets + 150

        width:      _fullMode ? _root.width : _root.width * 0.28
        height:     _fullMode ? _root.height : width * (9 / 16)

        anchors.right:      _root.right
        anchors.bottom:     _root.bottom
        anchors.rightMargin:_fullMode ? 0 : _margin
        anchors.bottomMargin:_fullMode ? 0 : _margin

        Rectangle {
            anchors.fill:   parent
            color:          "black"
            border.color:   Qt.rgba(1, 1, 1, 0.4)
            border.width:   _fullMode ? 0 : 1
            radius:         _fullMode ? 0 : ScreenTools.defaultFontPixelWidth * 0.3
        }

        QGCVideoBackground {
            id:             panoramaVideo
            objectName:     "panoramaVideo"
            anchors.fill:   parent
            receiver:       QGroundControl.videoManager.panoramaVideoReceiver
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            onDoubleClicked: _fullMode = !_fullMode
        }

        Rectangle {
            anchors.left:       parent.left
            anchors.top:        parent.top
            anchors.margins:    ScreenTools.defaultFontPixelWidth * 0.5
            color:              Qt.rgba(0, 0, 0, 0.6)
            radius:             ScreenTools.defaultFontPixelWidth * 0.2
            width:              labelText.width + ScreenTools.defaultFontPixelWidth
            height:             labelText.height + ScreenTools.defaultFontPixelHeight * 0.2
            visible:            !_fullMode

            QGCLabel {
                id:                 labelText
                anchors.centerIn:   parent
                text:               qsTr("PANORAMA")
            }
        }

        QGCButton {
            anchors.right:      parent.right
            anchors.top:        parent.top
            anchors.margins:    ScreenTools.defaultFontPixelWidth * 0.5
            text:               _fullMode ? qsTr("PiP") : qsTr("Full")
            onClicked:          _fullMode = !_fullMode
        }
    }
}
