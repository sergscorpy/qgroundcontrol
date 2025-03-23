/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                      2.12
import QtQuick.Controls             2.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0

// Label control whichs pop up a flight mode change menu when clicked
QGCLabel {
    id:     _root
    text:   currentVehicle ? currentVehicle.flightMode : qsTr("N/A", "No data to display")

    property var    currentVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property real   mouseAreaLeftMargin:    0

    Menu {
        id: flightModesMenu
    }

    Component {
        id: flightModeMenuItemComponent

        MenuItem {
            enabled: true
            onTriggered: currentVehicle.flightMode = text
        }
    }

    property var flightModesMenuItems: []

    function updateFlightModesMenu() {
        // Масив дозволених режимів, які хочемо бачити в меню
        var allowedModes = [
            "Altitude Hold",
            "Loiter",
            "RTL",
            "Guided No GPS"
        ]

        if (currentVehicle && currentVehicle.flightModeSetAvailable) {
            var i;

            // Спочатку видаляємо всі старі пункти меню
            for (i = 0; i < flightModesMenuItems.length; i++) {
                flightModesMenu.removeItem(flightModesMenuItems[i])
            }

            // Очищуємо масив з пунктами меню
            flightModesMenuItems.length = 0

            // Додаємо нові пункти меню тільки з дозволених режимів
            for (i = 0; i < currentVehicle.flightModes.length; i++) {
                var mode = currentVehicle.flightModes[i]

                // Перевірка: якщо режим є в дозволеному списку - додаємо його в меню
                if (allowedModes.indexOf(mode) !== -1) {
                    var menuItem = flightModeMenuItemComponent.createObject(null, {
                        "text": mode
                    })

                    flightModesMenuItems.push(menuItem)

                    // Додаємо пункт у меню на позицію, залежно від поточного розміру масиву
                    flightModesMenu.insertItem(flightModesMenuItems.length - 1, menuItem)
                } else {
                    console.log("Flight mode ignored:", mode)
                }
            }

            // Якщо жоден режим не потрапив у меню
            if (flightModesMenuItems.length === 0) {
                console.warn("Warning: No valid flight modes available in allowedModes list.")
            }
        }
    }


    Component.onCompleted: _root.updateFlightModesMenu()

    Connections {
        target:                 QGroundControl.multiVehicleManager
        function onActiveVehicleChanged(activeVehicle) { _root.updateFlightModesMenu() }
    }

    MouseArea {
        id:                 mouseArea
        visible:            currentVehicle && currentVehicle.flightModeSetAvailable
        anchors.leftMargin: mouseAreaLeftMargin
        anchors.fill:       parent
        onClicked:          flightModesMenu.popup((_root.width - flightModesMenu.width) / 2, _root.height)
    }
}
