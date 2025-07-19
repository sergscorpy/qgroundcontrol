#pragma once
#include "SettingsGroup.h"

class ButtonsSettings : public SettingsGroup
{
    Q_OBJECT
public:
    ButtonsSettings(QObject* parent = nullptr);
    DEFINE_SETTING_NAME_GROUP()
    DEFINE_SETTINGFACT(activeProfile)
    DEFINE_SETTINGFACT(profiles)

    Q_INVOKABLE QVariantList loadButtonProfiles();
    Q_INVOKABLE void saveButtonProfiles(const QVariantList& profileList);

    static const QString profilesSettingsRoot();
};
