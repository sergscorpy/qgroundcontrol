import QtQuick 2.12
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.4

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.FactSystem 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Vehicle 1.0

Item {
    id: aimOverlayRoot
    anchors.fill: parent

    property bool isAimEnabled: false
    property bool isA8mini: false
    property real rollAngle: 0
    property real pitchAngle: 0
    property real gimbalMode: 0
    property bool showCorrectionControls: QGroundControl.settingsManager.flyViewSettings.showCorrectionControls.value
    property real screenUnit: ScreenTools.defaultFontPixelWidth
    property real screenMargin: ScreenTools.defaultFontPixelWidth / 2
    property real platformScale: crosshairRoot.isAndroid ? customScale : 0.75 * customScale
    property Fact aimOverlayScale: QGroundControl.settingsManager.flyViewSettings.aimOverlayScale
    property real customScale: aimOverlayScale ? aimOverlayScale.value : 1

    property int  xc: width / 2
    property int  yc: height / 2

    // Параметри камери
    property real focalLengthEquiv: 21  // Еквівалентна фокусна відстань (мм)
    property real sensorSize: 1 / 1.7   // Розмір сенсора у дюймах (1/1.7")

    // Значення FOV, що залежить від вибору камери
    property var cameraFovValues: [
        81.0,    // FOV для SiYi A8 Mini
        160.0    // FOV для SiYi A2 Mini
    ]

    // Масив моделей камер
    property var cameraNames: [
        "SiYi A8 Mini",
        "SiYi A2 Mini"
    ]

    // Поточний індекс вибраної камери
    property int cameraIndex: 0

    // Значення FOV, що залежить від вибору камери
    property real fovInst: cameraFovValues[cameraIndex]

    // Обчислення реальних параметрів сенсора
    function calculateSensorSize(sensorInches) {
        var diagonalMM = 17.3 * sensorInches; // Емпіричний коефіцієнт
        var width = (4 / Math.sqrt(4 * 4 + 3 * 3)) * diagonalMM;
        var height = (3 / Math.sqrt(4 * 4 + 3 * 3)) * diagonalMM;
        var cropFactor = 43.3 / diagonalMM; // Full Frame = 43.3 мм
        return { width: width, height: height, cropFactor: cropFactor };
    }
    property var sensorData: calculateSensorSize(sensorSize)
    property real sensorWidth: sensorData.width
    property real sensorHeight: sensorData.height
    property real cropFactor: sensorData.cropFactor

    // Реальна фокусна відстань
    property real focalLengthReal: focalLengthEquiv / cropFactor

    // Обчислення кутів огляду камери
    property real fovX: 2 * Math.atan(sensorWidth / (2 * focalLengthReal)) * (180 / Math.PI)
    property real fovY: 2 * Math.atan(sensorHeight / (2 * focalLengthReal)) * (180 / Math.PI)

    // Вимкнення поправки по гіроскопу у випадку увімкнення камери в режим прицілювання (Follow Mod)
    property real aimOn: gimbalMode === 1 ? 0 : 1

    // Обчислення зміщення індикатора (оскільки, зображення з камери на екрані андроїда масштабується
    // по ширині екрана, а верх та низ обрізається, за точку відліку берем ширину екрана та
    // кут огляду по осі Х)
    property real dx: Math.tan((aimOn * rollAngle * aimCorrFovX.value + aimCorrAnglX.value) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)
    property real dy: Math.tan((aimOn * pitchAngle * aimCorrFovY.value + aimCorrAnglY.value) * Math.PI / 180) * (width / 2) / Math.tan(fovInst / 2 * Math.PI / 180)

    // Відключення донаведення при нахилі більше максимального кута
    // Значення задається в налаштуваннях
    property Fact _maxCorrectionAngle: QGroundControl.settingsManager.flyViewSettings.maxCorrectionAngle
    property real angleMax: _maxCorrectionAngle.value // Максимальний кут відстеження
    property bool rollPichMax: Math.abs(rollAngle) <= angleMax && Math.abs(pitchAngle) <= angleMax

    Image {
        id: crossHair1
        anchors.centerIn: parent
        source: "/qmlimages/crosshair_1.svg"
        mipmap: true
        height: parent.width * 0.33 * platformScale
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: true
    }

    Image {
        id: aim
        source: "/qmlimages/crosshair_2.svg"
        mipmap: true
        height: parent.width * 0.05 * platformScale
        sourceSize.height: height
        fillMode: Image.PreserveAspectCrop
        visible: isAimEnabled && rollPichMax && isA8mini

        // Переміщення від центру
        x: xc + dx - width / 2
        y: yc + dy - height / 2
    }

    Shape {
        id: connectionLine
        width: parent.width
        height: parent.height
        anchors.fill: parent
        visible: isAimEnabled && rollPichMax && isA8mini

        ShapePath {
            strokeWidth: 3
            strokeColor: "lightgreen"

            startX: xc
            startY: yc

            PathLine {
                x: aim.x + aim.width / 2
                y: aim.y + aim.height / 2
            }
        }
    }

    Item { // Блок налаштувань прицілу
        id: correctContainer
        anchors.fill: parent
        visible: showCorrectionControls

        Text {
            id: _fovInst
            text: "fovInst: " + fovInst
            font.pointSize: 16
            font.bold: false
            anchors.right: parent.right
            anchors.bottom:  _dAng.top
            anchors.margins: screenMargin
            color: "white"
            visible: false
        }

        Text {
            id: _dAng
            text: "Roll: " + rollAngle.toFixed(2) + "°, Pitch: " + pitchAngle.toFixed(2) + "°"
            font.pointSize: 16
            font.bold: false
            anchors.right: parent.right
            anchors.bottom:  _dx.top
            anchors.margins: screenMargin
            color: "white"
            visible: false
        }

        Text {
            id: _dx
            text: "dx: " + dx.toFixed(2) + "  dy: " + dy.toFixed(2)
            font.pointSize: 16
            font.bold: false
            anchors.right: parent.right
            anchors.bottom:  cameraSelector.top
            anchors.margins: screenMargin
            color: "white"
            visible: false
        }

        // ComboBox для вибору камери
        QGCComboBox {
            id: cameraSelector
            width: screenUnit * 25
            anchors.right: parent.right
            anchors.bottom:  aimCorrAnglX.top
            anchors.margins: screenMargin
            visible: false

            model: cameraNames
            currentIndex: cameraIndex

            onActivated: {
                cameraIndex = index
                fovInst = cameraFovValues[index]

                console.log("Selected camera:", cameraNames[index], "FOV:", fovInst)
            }
        }

        Column {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: screenMargin
            spacing: screenMargin

            FlyViewSpinBox {
                id: aimCorrAnglX

                minValue: -10
                maxValue: 10
                stepValue: 0.5
                value: 0
            }

            FlyViewSpinBox {
                id: aimCorrAnglY

                minValue: -10
                maxValue: 10
                stepValue: 0.5
                value: 0
            }

            FlyViewSpinBox {
                id: aimCorrFovX

                minValue: 0
                maxValue: 2
                stepValue: 0.05
                value: 0.8
                visible: false
            }

            FlyViewSpinBox {
                id: aimCorrFovY

                minValue: 0
                maxValue: 2
                stepValue: 0.05
                value: 0.8
                visible: false
            }
        }
    }
}
