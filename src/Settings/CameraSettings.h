#pragma once

#include "SettingsGroup.h"

class CameraSettings : public SettingsGroup
{
    Q_OBJECT
public:
    CameraSettings(QObject* parent = nullptr);

    DEFINE_SETTING_NAME_GROUP()

    DEFINE_SETTINGFACT(cameraType)
};
