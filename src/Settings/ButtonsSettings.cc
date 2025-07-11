#include "ButtonsSettings.h"
#include <QQmlEngine>
#include <QtQml>

DECLARE_SETTINGGROUP(Buttons, "Buttons")
{
    qmlRegisterUncreatableType<ButtonsSettings>("QGroundControl.SettingsManager", 1, 0, "ButtonsSettings", "Reference only");
}

DECLARE_SETTINGSFACT(ButtonsSettings, profiles)
DECLARE_SETTINGSFACT(ButtonsSettings, activeProfile)
