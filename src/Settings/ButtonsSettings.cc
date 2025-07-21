#include "ButtonsSettings.h"
#include <QQmlEngine>
#include <QtQml>
#include <QJsonDocument>

DECLARE_SETTINGGROUP(Buttons, "Buttons")
{
    qmlRegisterUncreatableType<ButtonsSettings>("QGroundControl.SettingsManager", 1, 0, "ButtonsSettings", "Reference only");
}

DECLARE_SETTINGSFACT(ButtonsSettings, activeProfile)
DECLARE_SETTINGSFACT(ButtonsSettings, profiles)

QVariantList ButtonsSettings::loadButtonProfiles()
{
    QVariantList profileList;
    if (profiles()) {
        QString json = profiles()->rawValue().toString();
        QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
        if (doc.isArray()) {
            profileList = doc.toVariant().toList();
        }
    }

    return profileList;
}

void ButtonsSettings::saveButtonProfiles(const QVariantList& profileList)
{
    if (profiles()) {
        QJsonDocument doc = QJsonDocument::fromVariant(profileList);
        profiles()->setRawValue(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
    }
}
