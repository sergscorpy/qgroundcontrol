import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

Rectangle {
    id: editorRoot
    color: qgcPal.window
    anchors.fill: parent

    property string profileName
    property var    profileModel

    signal done()
    signal profileChanged()

    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    Column {
        id: mainColumn
        anchors.margins: ScreenTools.defaultFontPixelWidth
        anchors.fill: parent
        spacing: ScreenTools.defaultFontPixelHeight / 2

        QGCLabel { text: qsTr("Profile: %1").arg(profileName); font.bold: true }

        Repeater {
            id: itemRepeater
            model: profileModel
            delegate: Row {
                id: rowItem
                spacing: ScreenTools.defaultFontPixelWidth
                property int idx: index

                QGCButton {
                    text: model.buttonName
                    enabled: false
                }
                QGCComboBox {
                    id: servoCombo
                    model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16] //servo index 1..16
                    onActivated: {
                        profileModel.setProperty(rowItem.idx, "servo", index + 1)
                        profileChanged()
                    }
                    Component.onCompleted: currentIndex = rowItem.model.servo - 1
                }
                QGCTextField {
                    width: ScreenTools.defaultFontPixelWidth * 8
                    text: model.pwmOpen
                    onEditingFinished: {
                        profileModel.setProperty(idx, "pwmOpen", parseInt(text))
                        profileChanged()
                    }
                }
                QGCTextField {
                    width: ScreenTools.defaultFontPixelWidth * 8
                    text: model.pwmTrimm
                    onEditingFinished: {
                        profileModel.setProperty(idx, "pwmTrimm", parseInt(text))
                        profileChanged()
                    }
                }
                QGCTextField {
                    width: ScreenTools.defaultFontPixelWidth * 8
                    text: model.pwmClose
                    onEditingFinished: {
                        profileModel.setProperty(idx, "pwmClose", parseInt(text))
                        profileChanged()
                    }
                }
                QGCButton {
                    text: qsTr("Delete")
                    onClicked: {
                        profileModel.remove(idx)
                        profileChanged()
                    }
                }
            }
        }

        QGCButton {
            text: qsTr("Create")
            width: ScreenTools.defaultFontPixelWidth * 10
            onClicked: {
                profileModel.append({ buttonName: "Drop" + (profileModel.count + 1), servo: 1, pwmOpen: 1000, pwmTrimm: 1500, pwmClose: 2000 })
                profileChanged()
            }
        }

        QGCButton {
            text: qsTr("Close")
            width: ScreenTools.defaultFontPixelWidth * 10
            onClicked: done()
        }
    }
}
