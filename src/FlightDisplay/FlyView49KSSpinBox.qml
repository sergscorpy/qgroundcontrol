
/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

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
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0


// Інтерфейс для введення поправки
Item {
    id: root
    width: _scrUnit * 8
    height: _scrUnit * 3

    property real minValue: 0
    property real maxValue: 2
    property real stepValue: 0.05
    property real value: 1.0

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#2c2c2c"
        radius: height / 2
        border.color: "#555555"
        border.width: 1

        Row {
            anchors.fill: parent
            anchors.margins: _scrMargins
            spacing: _scrMargins

            Rectangle {
                id: decrementButton
                width: parent.height
                height: parent.height
                color: "#80454545"
                radius: height / 2
                border.color: "#666"

                Text {
                    anchors.centerIn: parent
                    text: "-"
                    color: "white"
                    font.pointSize: 16
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.value - root.stepValue >= root.minValue) {
                            root.value = (root.value - root.stepValue).toFixed(2)
                        }
                    }
                }
            }

            Rectangle {
                id: valueDisplay
                width: _scrUnit * 2
                height: parent.height
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: root.value
                    color: "#ffffff"
                    font.pointSize: 16
                }
            }

            Rectangle {
                id: incrementButton
                width: parent.height
                height: parent.height
                color: "#80454545"
                radius: height / 2
                border.color: "#666"

                Text {
                    anchors.centerIn: parent
                    text: "+"
                    color: "white"
                    font.pointSize: 16
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.value + root.stepValue <= root.maxValue) {
                            root.value = (root.value + root.stepValue).toFixed(2)
                        }
                    }
                }
            }
        }
    }
}
