
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


// Інтерфейс для введення поправки
Rectangle {
    id: _root
    width: scrUnit * 8
    height: scrUnit * 3
    color: "#2c2c2c"
    radius: height/2
    border.color: "#555555"
    border.width: 1
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: _margins

    property int value: correctionSpinBox.value    // Робимо значення доступним ззовні
    property int minValue: -10                     // Додаткові властивості для гнучкості
    property int maxValue: 10
    property int step: 1


    SpinBox {
        id: correctionSpinBox
        anchors.centerIn: parent
        width: scrUnit * 2 - _margins
        height: parent.height - _margins

        from: _root.minValue           // Мінімальне значення
        to: _root.maxValue               // Максимальне значення
        stepSize: _root.step           // Крок

        value: _root.value              // Початкове значення

        // Стиль для кнопок і поля
        contentItem: Text {
            text: correctionSpinBox.textFromValue(correctionSpinBox.value)
            font.pointSize: 16
            horizontalAlignment: Text.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            color: "black"
        }

        up.indicator: Rectangle {
            implicitWidth: parent.height
            implicitHeight: parent.height
            color: "#80454545"
            border.color: "#666"
            visible: true
            radius: parent.height/2
            x: - scrUnit * 3
            Text {
                anchors.centerIn: parent
                text: "+"
                color: "white"
                font.pixelSize: 24
            }
        }

        down.indicator: Rectangle {
            implicitWidth: parent.height
            implicitHeight: parent.height
            color: "#80454545"
            border.color: "#666"
            visible: true
            radius: parent.height/2
            x: scrUnit * 2
            Text {
                anchors.centerIn: parent
                text: "-"
                color: "white"
                font.pixelSize: 24
            }
        }
    }
}
