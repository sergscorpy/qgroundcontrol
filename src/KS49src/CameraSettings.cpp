#include "CameraSettings.h"

#include <QQmlEngine>
#include <QtQml>

DECLARE_SETTINGGROUP(Camera, "Camera")
{
    qmlRegisterUncreatableType<CameraSettings>("QGroundControl.SettingsManager", 1, 0, "CameraSettings", "Reference only");
}

DECLARE_SETTINGSFACT(CameraSettings, cameraType)
