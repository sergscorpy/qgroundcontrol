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
import Qt.labs.settings         1.0

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.ScreenTools   1.0

Item {
    id:             _root
    anchors.fill:   parent
    visible:        _panoramaSourceConfigured

    property string _panoramaVideoSource: QGroundControl.settingsManager.videoSettings.panoramaVideoSource.rawValue
    property bool   _panoramaSourceConfigured: _panoramaVideoSource !== "" &&
                                               _panoramaVideoSource !== QGroundControl.settingsManager.videoSettings.disabledVideoSource &&
                                               _panoramaVideoSource !== "No Video Available"
    property bool   _isGst:             QGroundControl.videoManager.isGStreamer
    property bool   _fullMode:          false
    property bool   _isExpanded:        true
    property bool   _windowMode:        false
    property real   _margin:            ScreenTools.defaultFontPixelWidth * 0.75
    property real   _pipSize:           parent.width * 0.22
    property real   _maxSize:           0.75
    property real   _minSize:           0.10
    property bool   _hasSavedWindowState: false
    property bool   _savedFullMode:       false
    property bool   _savedIsExpanded:     true
    property real   _savedPipSize:        0

    Settings {
        id: _panoramaWindowSettings
        category: "PanoramaWindowState"

        property int x: 0
        property int y: 0
        property int width: 0
        property int height: 0
        property string screenName: ""
        property bool windowMode: false
    }

    function _findScreenByName(screenName) {
        const screens = Qt.application.screens
        for (let i = 0; i < screens.length; i++) {
            if (screens[i].name === screenName) {
                return screens[i]
            }
        }
        return null
    }

    function _setDefaultWindowGeometry() {
        const topLeft = _root.mapToGlobal(0, 0)
        const defaultWidth = Math.max(320, Math.round(_root.width * 0.30))
        const defaultHeight = Math.max(180, Math.round(_root.height * 0.30))
        panoramaWindow.width = defaultWidth
        panoramaWindow.height = defaultHeight
        panoramaWindow.x = Math.round(topLeft.x + (_root.width - defaultWidth) / 2)
        panoramaWindow.y = Math.round(topLeft.y + (_root.height - defaultHeight) / 2)
    }

    function _restoreWindowGeometryFromSettings() {
        if (_panoramaWindowSettings.width <= 0 || _panoramaWindowSettings.height <= 0 || _panoramaWindowSettings.screenName === "") {
            return false
        }

        const savedScreen = _findScreenByName(_panoramaWindowSettings.screenName)
        if (!savedScreen) {
            return false
        }

        panoramaWindow.screen = savedScreen
        panoramaWindow.x = _panoramaWindowSettings.x
        panoramaWindow.y = _panoramaWindowSettings.y
        panoramaWindow.width = _panoramaWindowSettings.width
        panoramaWindow.height = _panoramaWindowSettings.height
        return true
    }

    function _resetPanoramaUiState() {
        _hasSavedWindowState = false
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

    Component.onCompleted: {
        Qt.callLater(function() {
            if (!visible || !_panoramaWindowSettings.windowMode) {
                return
            }
            if (_restoreWindowGeometryFromSettings()) {
                _windowMode = true
                panoramaWindow.show()
            } else {
                _windowMode = false
            }
        })
    }

    Item {
        id:         panoramaFrame
        z:          QGroundControl.zOrderWidgets + 150

        width:      _fullMode ? _root.width : _pipSize
        height:     _fullMode ? _root.height : _pipSize * (9 / 16)
        visible:    !_windowMode && (_fullMode || _isExpanded)

        anchors.rightMargin: _fullMode ? 0 : _margin
        anchors.bottomMargin: _fullMode ? 0 : _margin
        anchors.top: undefined
        anchors.left: undefined
        anchors.right: _root.right
        anchors.bottom: _root.bottom

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
            id: panoramaMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            onClicked: {}
        }

        Image {
            id:             popupPIP
            source:         "/qmlimages/PiP.svg"
            mipmap:         true
            fillMode:       Image.PreserveAspectFit
            anchors.right:  parent.right
            anchors.top:    parent.top
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.5
            visible:        !_fullMode && _isExpanded && !ScreenTools.isMobile && panoramaMouseArea.containsMouse
            height:         ScreenTools.defaultFontPixelHeight * 2.5
            width:          ScreenTools.defaultFontPixelHeight * 2.5
            sourceSize.height: height

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (_windowMode) {
                        return
                    }
                    _savedFullMode = _fullMode
                    _savedIsExpanded = _isExpanded
                    _savedPipSize = _pipSize
                    _hasSavedWindowState = true
                    _fullMode = false

                    if (!_restoreWindowGeometryFromSettings()) {
                        _setDefaultWindowGeometry()
                    }

                    _windowMode = true
                    _panoramaWindowSettings.windowMode = true
                    panoramaWindow.show()
                }
            }
        }

        Image {
            id:             hidePIP
            source:         "/qmlimages/pipHide.svg"
            mipmap:         true
            fillMode:       Image.PreserveAspectFit
            anchors.right:  parent.right
            anchors.bottom: parent.bottom
            anchors.margins: ScreenTools.defaultFontPixelWidth * 0.5
            visible:        !_fullMode && _isExpanded && (ScreenTools.isMobile || panoramaMouseArea.containsMouse)
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
            anchors.left:   parent.left
            height:         ScreenTools.minTouchPixels
            width:          height
            visible:        !_fullMode && !_windowMode && _isExpanded

            property real initialMouseRootX: 0
            property real initialWidth:      0

            onPressed: {
                pipResize.initialMouseRootX = pipResize.mapToItem(_root, mouse.x, mouse.y).x
                pipResize.initialWidth = _pipSize
            }

            onPositionChanged: {
                if (pipResize.pressed) {
                    const parentWidth = _root.width
                    const currentMouseRootX = pipResize.mapToItem(_root, mouse.x, mouse.y).x
                    // PiP is anchored to the right edge, so dragging left should increase width.
                    const newWidth = pipResize.initialWidth - (currentMouseRootX - pipResize.initialMouseRootX)
                    _pipSize = Math.max(parentWidth * _minSize, Math.min(parentWidth * _maxSize, newWidth))
                }
            }
        }

        Image {
            source:         "/qmlimages/pipResize.svg"
            fillMode:       Image.PreserveAspectFit
            mipmap:         true
            anchors.left:   parent.left
            anchors.top:    parent.top
            visible:        !_fullMode && !_windowMode && _isExpanded && (ScreenTools.isMobile || panoramaMouseArea.containsMouse)
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
        onVisibleChanged: {
            if (visible) {
                _panoramaWindowSettings.windowMode = true
                if (screen) {
                    _panoramaWindowSettings.screenName = screen.name
                }
                QGroundControl.videoManager.rebindPanoramaVideoSink(panoramaWindowVideo)
            }
        }
        Item {
            id: panoramaWindowFrame
            anchors.fill: parent

            Rectangle {
                anchors.fill:   parent
                color:          "black"
                border.width:   0
                radius:         0
            }

            QGCVideoBackground {
                id:             panoramaWindowVideo
                objectName:     "panoramaWindowVideo"
                anchors.fill:   parent
                receiver:       QGroundControl.videoManager.panoramaVideoReceiver
            }
        }
        onXChanged: if (visible) _panoramaWindowSettings.x = x
        onYChanged: if (visible) _panoramaWindowSettings.y = y
        onWidthChanged: if (visible) _panoramaWindowSettings.width = width
        onHeightChanged: if (visible) _panoramaWindowSettings.height = height
        onScreenChanged: if (visible && screen) _panoramaWindowSettings.screenName = screen.name
        onClosing: {
            _windowMode = false
            _panoramaWindowSettings.windowMode = false
            QGroundControl.videoManager.rebindPanoramaVideoSink(panoramaVideo)
            if (_hasSavedWindowState) {
                Qt.callLater(function() {
                    _fullMode = _savedFullMode
                    _isExpanded = _savedIsExpanded
                    if (_savedPipSize > 0) {
                        _pipSize = _savedPipSize
                    }
                })
                _hasSavedWindowState = false
            }
        }
    }
}
