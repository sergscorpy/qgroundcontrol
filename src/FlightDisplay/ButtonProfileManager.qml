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
        if (profilesFact === undefined || activeProfileFact === undefined) {
            // Such checks prevent errors during early load when settings are not ready
            return
        }
        console.log("ButtonProfileManager: loading profiles", profilesFact ? profilesFact.rawValue : "<undefined>")
        try {
            profiles = JSON.parse(profilesFact.rawValue)
        } catch(e) {
            console.warn("ButtonProfileManager: failed to parse profiles", e)
            profiles = []
        }
        updateActiveProfile()
    }

    function saveProfiles() {
        var json = JSON.stringify(profiles)
        console.log("ButtonProfileManager: saving profiles", json)
        profilesFact.rawValue = json
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
        target: profilesFact ? profilesFact : _dummy
        ignoreUnknownSignals: true
        function onRawValueChanged() { loadProfiles() }
    }
    Connections {
        target: activeProfileFact ? activeProfileFact : _dummy
        ignoreUnknownSignals: true
        function onRawValueChanged() { updateActiveProfile() }
    }

    Component.onCompleted: loadProfiles()
}
