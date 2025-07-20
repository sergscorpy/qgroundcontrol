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

    if (profileList.isEmpty()) {
        // Create default profile if none stored
        QVariantList items;
        for (int i = 1; i <= 4; ++i) {
            QVariantMap item;
            item["buttonName"] = QStringLiteral("Drop%1").arg(i);
            item["servo"]      = i;
            item["pwmOpen"]   = 1000;
            item["pwmTrimm"]  = 1900;
            item["pwmClose"]  = 2350;
            items.append(item);
        }

        QVariantMap profile;
        profile["name"]  = QStringLiteral("Vampir");
        profile["items"] = items;
        profileList.append(profile);

        // Save default profile and activate it
        saveButtonProfiles(profileList);
        if (activeProfile()) {
            activeProfile()->setRawValue(0);
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
