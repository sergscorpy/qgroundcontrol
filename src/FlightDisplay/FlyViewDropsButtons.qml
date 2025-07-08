import QtQuick                  2.12
import QtQuick.Controls         2.4
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12
import QtQuick.Shapes           1.12

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1
import QtGraphicalEffects       1.0

import QGroundControl               1.0
import QGroundControl.Airspace      1.0
import QGroundControl.Airmap        1.0
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
    id: dropsButtons
    anchors.topMargin: _scrToolsUnit * 0
    anchors.rightMargin: _scrToolsUnit * 30


    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _servoOutput:  _activeVehicle ? _activeVehicle.servoOutput : null
    property real _scrToolsUnit: ScreenTools.defaultFontPixelWidth

    Column {
        spacing: 2
        Repeater {
            model: 32
            delegate: QGCLabel {
                property var servoFact: _servoOutput ? _servoOutput["servo" + (index + 1)] : null
                text: qsTr("Servo %1: ").arg(index + 1) + (servoFact ? servoFact.valueString + " " + servoFact.units : qsTr("N/A"))
            }
        }
    }
}
