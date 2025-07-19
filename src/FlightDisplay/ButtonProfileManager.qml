pragma Singleton
import QtQuick 2.12
import QGroundControl 1.0
import QGroundControl.FactSystem 1.0

QtObject {
    property Fact activeProfileFact: QGroundControl.settingsManager.buttonsSettings.activeProfile
    property Fact profilesFact:      QGroundControl.settingsManager.buttonsSettings.profiles

    property var profiles: []
    property var activeProfile: []
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    function loadProfiles() {
        if (activeProfileFact === undefined || profilesFact === undefined) {
            // Such checks prevent errors during early load when settings are not ready
            return
        }
        profiles = QGroundControl.settingsManager.buttonsSettings.loadButtonProfiles()
        console.log("ButtonProfileManager: load buttonsprofile")
        updateActiveProfile()
    }

    function saveProfiles() {
        QGroundControl.settingsManager.buttonsSettings.saveButtonProfiles(profiles)
        console.log("ButtonProfileManager: save buttonsprofile")
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

    Component.onCompleted: loadProfiles()

}
