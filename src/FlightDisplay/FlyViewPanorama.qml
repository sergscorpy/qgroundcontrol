/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                  2.12
import QtQuick.Window           2.12

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
    property bool   _isExpanded:        true
    property bool   _windowMode:        false
    property real   _margin:            ScreenTools.defaultFontPixelWidth * 0.75
    property real   _pipSize:           parent.width * 0.22
    property real   _maxSize:           0.75
    property real   _minSize:           0.10

    function _resetPanoramaUiState() {
        _windowMode = false
        _fullMode = false
        _isExpanded = true
        if (panoramaWindow.visible) {
            panoramaWindow.close()
        }
    }

    onVisibleChanged: {
        if (!visible) {
            _resetPanoramaUiState()
        }
    }

    Item {
        id:         panoramaFrame
        z:          QGroundControl.zOrderWidgets + 150

        width:      _fullMode ? _root.width : _pipSize
        height:     _fullMode ? _root.height : _pipSize * (9 / 16)
        visible:    _fullMode || _isExpanded || _windowMode

        anchors.right:      _windowMode ? undefined : _root.right
        anchors.bottom:     _windowMode ? undefined : _root.bottom
        anchors.rightMargin: (_windowMode || _fullMode) ? 0 : _margin
        anchors.bottomMargin: (_windowMode || _fullMode) ? 0 : _margin

        parent: _windowMode ? panoramaWindow.contentItem : _root
        anchors.fill: _windowMode ? parent : undefined

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
            onClicked: {
                if (!_windowMode) {
                    _fullMode = !_fullMode
                }
            }
        }

        Image {
            id:             popupPIP
            source:         "/qmlimages/PiP.svg"
            mipmap:         true
            fillMode:       Image.PreserveAspectFit
            anchors.left:   parent.left
            anchors.top:    parent.top
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.5
            visible:        !_fullMode && _isExpanded && !ScreenTools.isMobile
            height:         ScreenTools.defaultFontPixelHeight * 2.5
            width:          ScreenTools.defaultFontPixelHeight * 2.5
            sourceSize.height: height

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    _fullMode = false
                    _windowMode = true
                    panoramaWindow.width = panoramaFrame.width
                    panoramaWindow.height = panoramaFrame.height
                    panoramaWindow.show()
                }
            }
        }

        Image {
            id:             hidePIP
            source:         "/qmlimages/pipHide.svg"
            mipmap:         true
            fillMode:       Image.PreserveAspectFit
            anchors.left:   parent.left
            anchors.bottom: parent.bottom
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.5
            visible:        !_fullMode && _isExpanded
            height:         ScreenTools.defaultFontPixelHeight * 2.5
            width:          ScreenTools.defaultFontPixelHeight * 2.5
            sourceSize.height: height

            MouseArea {
                anchors.fill: parent
                onClicked: _isExpanded = false
            }
        }

        MouseArea {
            id:             pipResize
            anchors.top:    parent.top
            anchors.right:  parent.right
            height:         ScreenTools.minTouchPixels
            width:          height
            hoverEnabled:   true
            visible:        !_fullMode && _isExpanded && (_windowMode || ScreenTools.isMobile || containsMouse)

            property real initialX:     0
            property real initialWidth: 0

            onPressed: {
                pipResize.anchors.top = undefined
                pipResize.anchors.right = undefined
                pipResize.initialX = mouse.x
                pipResize.initialWidth = _pipSize
            }

            onReleased: {
                pipResize.anchors.top = panoramaFrame.top
                pipResize.anchors.right = panoramaFrame.right
            }

            onPositionChanged: {
                if (pipResize.pressed) {
                    const parentWidth = _root.width
                    const newWidth = pipResize.initialWidth + mouse.x - pipResize.initialX
                    if (newWidth < parentWidth * _maxSize && newWidth > parentWidth * _minSize) {
                        _pipSize = newWidth
                    }
                }
            }
        }

        Image {
            source:         "/qmlimages/pipResize.svg"
            fillMode:       Image.PreserveAspectFit
            mipmap:         true
            anchors.right:  parent.right
            anchors.top:    parent.top
            visible:        !_fullMode && _isExpanded && (ScreenTools.isMobile || pipResize.containsMouse)
            height:         ScreenTools.defaultFontPixelHeight * 2.5
            width:          ScreenTools.defaultFontPixelHeight * 2.5
            sourceSize.height: height
        }
    }

    Rectangle {
        id:                     showPip
        anchors.right:          parent.right
        anchors.bottom:         parent.bottom
        anchors.margins:        _margin
        height:                 ScreenTools.defaultFontPixelHeight * 2
        width:                  ScreenTools.defaultFontPixelHeight * 2
        radius:                 ScreenTools.defaultFontPixelHeight / 3
        visible:                !_fullMode && !_windowMode && !_isExpanded
        color:                  Qt.rgba(0, 0, 0, 0.5)
        z:                      QGroundControl.zOrderWidgets + 151

        Image {
            width:              parent.width  * 0.75
            height:             parent.height * 0.75
            sourceSize.height:  height
            source:             "/res/buttonRight.svg"
            mipmap:             true
            fillMode:           Image.PreserveAspectFit
            anchors.verticalCenter:     parent.verticalCenter
            anchors.horizontalCenter:   parent.horizontalCenter
        }
        MouseArea {
            anchors.fill:   parent
            onClicked:      _isExpanded = true
        }
    }

    Connections {
        target: _root.parent
        function onWidthChanged() {
            const parentWidth = _root.width
            if (_pipSize > parentWidth * _maxSize) {
                _pipSize = parentWidth * _maxSize
            } else if (_pipSize < parentWidth * _minSize) {
                _pipSize = parentWidth * _minSize
            }
        }
    }

    Window {
        id:         panoramaWindow
        visible:    false
        onClosing: {
            _fullMode = false
            _isExpanded = true
            _windowMode = false
        }
    }
}
