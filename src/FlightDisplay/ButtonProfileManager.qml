pragma Singleton
import QtQuick 2.12
import QGroundControl 1.0
import QGroundControl.FactSystem 1.0

QtObject {
    property Fact profilesFact: QGroundControl.settingsManager.buttonsSettings.profiles
    property Fact activeProfileFact: QGroundControl.settingsManager.buttonsSettings.activeProfile

    property var profiles: []
    property var activeProfile: []

    function loadProfiles() {
        try {
            profiles = JSON.parse(profilesFact.rawValue)
        } catch(e) {
            profiles = []
        }
        updateActiveProfile()
    }

    function saveProfiles() {
        profilesFact.rawValue = JSON.stringify(profiles)
        updateActiveProfile()
    }

    function updateActiveProfile() {
        var idx = parseInt(activeProfileFact.rawValue)
        if (idx >= 0 && idx < profiles.length) {
            activeProfile = profiles[idx].items
        } else {
            activeProfile = []
        }
    }

    Connections {
        target: profilesFact
        onValueChanged: loadProfiles()
    }
    Connections {
        target: activeProfileFact
        onValueChanged: updateActiveProfile()
    }

    Component.onCompleted: loadProfiles()
}
