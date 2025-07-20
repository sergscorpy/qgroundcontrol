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
        console.log("ButtonProfileManager: loadProfiles called")
        if (activeProfileFact === undefined || profilesFact === undefined) {
            // Such checks prevent errors during early load when settings are not ready
            console.log("ButtonProfileManager: Facts not ready for loading profiles")
            return
        }
        profiles = QGroundControl.settingsManager.buttonsSettings.loadButtonProfiles()
        console.log("ButtonProfileManager: loaded profiles", JSON.stringify(profiles))
        updateActiveProfile()
    }

    function saveProfiles() {
        console.log("ButtonProfileManager: saveProfiles called")
        console.log("ButtonProfileManager: profiles to save", JSON.stringify(profiles))
        QGroundControl.settingsManager.buttonsSettings.saveButtonProfiles(profiles)
        console.log("ButtonProfileManager: profiles saved")
        updateActiveProfile()
    }

    function updateActiveProfile() {
        console.log("ButtonProfileManager: updateActiveProfile called")
        if (activeProfileFact === undefined) {
            // Such checks prevent errors during early load when settings are not ready
            console.log("ButtonProfileManager: activeProfileFact undefined")
            return
        }
        var idx = parseInt(activeProfileFact.rawValue)
        console.log("ButtonProfileManager: update active profile index", idx)
        if (idx >= 0 && idx < profiles.length) {
            activeProfile = profiles[idx].items
            console.log("ButtonProfileManager: active profile set to", JSON.stringify(activeProfile))
        } else {
            activeProfile = []
            console.log("ButtonProfileManager: active profile cleared due to invalid index")
        }
    }

    Component.onCompleted: loadProfiles()

}
