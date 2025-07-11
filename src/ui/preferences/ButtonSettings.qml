import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

Rectangle {
    id:                 buttonRoot
    color:              qgcPal.window
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    property var _currentSelection: null

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  enabled
    }

    ListModel {
        id: buttonModel
        ListElement { name: qsTr("Button 1") }
        ListElement { name: qsTr("Button 2") }
    }

    QGCFlickable {
        clip:               true
        anchors.top:        parent.top
        width:              parent.width
        height:             parent.height - buttonRow.height
        contentHeight:      settingsColumn.height
        contentWidth:       buttonRoot.width
        flickableDirection: Flickable.VerticalFlick

        Column {
            id:                 settingsColumn
            width:              buttonRoot.width
            anchors.margins:    ScreenTools.defaultFontPixelWidth
            spacing:            ScreenTools.defaultFontPixelHeight / 2

            Repeater {
                model: buttonModel
                delegate: QGCButton {
                    anchors.horizontalCenter:   settingsColumn.horizontalCenter
                    width:                      buttonRoot.width * 0.5
                    text:                       name
                    autoExclusive:              true
                    onClicked: {
                        checked = true
                        _currentSelection = index
                    }
                }
            }
        }
    }

    Row {
        id:                 buttonRow
        spacing:            ScreenTools.defaultFontPixelWidth
        anchors.bottom:     parent.bottom
        anchors.margins:    ScreenTools.defaultFontPixelWidth
        anchors.horizontalCenter: parent.horizontalCenter

        QGCButton {
            width:      ScreenTools.defaultFontPixelWidth * 10
            text:       qsTr("Delete")
        }
        QGCButton {
            text:       qsTr("Edit")
        }
        QGCButton {
            text:       qsTr("Add")
        }
        QGCButton {
            text:       qsTr("Activate")
        }
        QGCButton {
            text:       qsTr("Deactivate")
        }
    }
}
