import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0
import QGroundControl.FactSystem    1.0

Rectangle {
    id:                 buttonRoot
    color:              qgcPal.window
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    property int _currentSelection: -1
    property var  _profileModels: []
    property Fact _profilesFact: QGroundControl.settingsManager.buttonsSettings.profiles

    QGCPalette {
        id:                 qgcPal
        colorGroupEnabled:  enabled
    }

    ListModel {
        id: buttonModel
    }

    function addProfile(name) {
        buttonModel.append({ name: name })
        _profileModels.push(Qt.createQmlObject('import QtQuick 2.0; ListModel {}', buttonRoot))
    }

    function saveProfiles() {
        var profiles = []
        for (var i=0; i<buttonModel.count; i++) {
            var items = []
            var model = _profileModels[i]
            for (var j=0; j<model.count; j++) {
                items.push(model.get(j))
            }
            profiles.push({ name: buttonModel.get(i).name, items: items })
        }
        _profilesFact.rawValue = JSON.stringify(profiles)
    }

    function loadProfiles() {
        try {
            var data = JSON.parse(_profilesFact.rawValue)
            for (var i=0; i<data.length; i++) {
                addProfile(data[i].name)
                for (var j=0; j<data[i].items.length; j++) {
                    _profileModels[i].append(data[i].items[j])
                }
            }
        } catch(e) {
            addProfile(qsTr("Button 1"))
            addProfile(qsTr("Button 2"))
        }
    }

    Component.onCompleted: {
        if(_profilesFact.rawValue === "" || _profilesFact.rawValue === undefined) {
            addProfile(qsTr("Button 1"))
            addProfile(qsTr("Button 2"))
            saveProfiles()
        } else {
            loadProfiles()
        }
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
            enabled:    _currentSelection >= 0
            onClicked: {
                if(_currentSelection >= 0) {
                    buttonModel.remove(_currentSelection)
                    _profileModels.splice(_currentSelection, 1)
                    _currentSelection = -1
                    saveProfiles()
                }
            }
        }
        QGCButton {
            text:       qsTr("Edit")
            enabled:    _currentSelection >= 0
            onClicked: {
                if(_currentSelection >= 0) {
                    editorLoader.profileIndex = _currentSelection
                    editorLoader.sourceComponent = profileEditorComponent
                }
            }
        }
        QGCButton {
            text:       qsTr("Add")
            onClicked: mainWindow.showPopupDialogFromComponent(addProfileDialog)
        }
        QGCButton {
            text:       qsTr("Activate")
            enabled: false
        }
        QGCButton {
            text:       qsTr("Deactivate")
            enabled: false
        }
    }

    Loader {
        id:             editorLoader
        anchors.fill:   parent
        visible:        sourceComponent ? true : false
        property int profileIndex: -1
    }

    Component {
        id: profileEditorComponent
        ButtonProfileEditor {
            profileName: buttonModel.get(editorLoader.profileIndex).name
            profileModel: _profileModels[editorLoader.profileIndex]
            onDone: {
                editorLoader.sourceComponent = null
                saveProfiles()
            }
            onProfileChanged: saveProfiles()
        }
    }

    Component {
        id: addProfileDialog
        QGCPopupDialog {
            id: popupDialog
            title: qsTr("New Profile")
            buttons: StandardButton.Ok | StandardButton.Cancel

            function accept() {
                if(nameField.text.trim() !== "") {
                    buttonRoot.addProfile(nameField.text.trim())
                    saveProfiles()
                    hideDialog()
                }
            }

            ColumnLayout {
                width: ScreenTools.defaultFontPixelWidth * 30
                spacing: ScreenTools.defaultFontPixelHeight

                QGCLabel { text: qsTr("Profile Name") }
                QGCTextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter name")
                }
            }
        }
    }
}
