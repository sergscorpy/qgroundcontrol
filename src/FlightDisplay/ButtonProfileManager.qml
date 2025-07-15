pragma Singleton
import QtQuick 2.12
import QGroundControl 1.0
import QGroundControl.FactSystem 1.0

QtObject {
    property Fact activeProfileFact: QGroundControl.settingsManager.buttonsSettings.activeProfile

    property var profiles: []
    property var activeProfile: []
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    function loadProfiles() {
        if (activeProfileFact === undefined) {
            // Such checks prevent errors during early load when settings are not ready
            return
        }
        profiles = QGroundControl.settingsManager.buttonsSettings.loadButtonProfiles()
        updateActiveProfile()
    }

    function saveProfiles() {
        QGroundControl.settingsManager.buttonsSettings.saveButtonProfiles(profiles)
        updateActiveProfile()
    }

    function updateActiveProfile() {
        if (activeProfileFact === undefined) {
            // Such checks prevent errors during early load when settings are not ready
            return
        }
        var idx = parseInt(activeProfileFact.rawValue)
        console.log("ButtonProfileManager: update active profile index", idx)
        if (idx >= 0 && idx < profiles.length) {
            activeProfile = profiles[idx].items
        } else {
            activeProfile = []
        }
    }

    QtObject {
        id: _dummy
    }
    Connections {
        target: activeProfileFact && _activeVehicle ? activeProfileFact : _dummy
        ignoreUnknownSignals: true
        function onRawValueChanged() { updateActiveProfile() }
    }

    Component.onCompleted: loadProfiles()
}
