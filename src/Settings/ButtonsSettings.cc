#include "ButtonsSettings.h"
#include <QQmlEngine>
#include <QtQml>
#include <QSettings>
#include <QJsonDocument>

DECLARE_SETTINGGROUP(Buttons, "Buttons")
{
    qmlRegisterUncreatableType<ButtonsSettings>("QGroundControl.SettingsManager", 1, 0, "ButtonsSettings", "Reference only");
}

DECLARE_SETTINGSFACT(ButtonsSettings, activeProfile)
DECLARE_SETTINGSFACT(ButtonsSettings, profiles)

const QString ButtonsSettings::profilesSettingsRoot()
{
    return QStringLiteral("ButtonProfiles");
}

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

    if (!profileList.isEmpty()) {
        return profileList;
    }

    QSettings settings;
    settings.beginGroup(_settingsGroup);
    QString root = profilesSettingsRoot();

    if (settings.contains(root + "/count")) {
        int count = settings.value(root + "/count").toInt();
        for (int i = 0; i < count; ++i) {
            QString pRoot = root + QString("/Profile%1").arg(i);
            QString name = settings.value(pRoot + "/name").toString();
            QByteArray itemsJson = settings.value(pRoot + "/items").toByteArray();
            QVariantList items;
            QJsonDocument doc = QJsonDocument::fromJson(itemsJson);
            if (doc.isArray()) {
                items = doc.toVariant().toList();
            }
            QVariantMap profile;
            profile["name"] = name;
            profile["items"] = items;
            profileList.append(profile);
        }
    } else {
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

    settings.endGroup();
    if (profiles()) {
        QJsonDocument doc = QJsonDocument::fromVariant(profileList);
        profiles()->setRawValue(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
    }
    return profileList;
}

void ButtonsSettings::saveButtonProfiles(const QVariantList& profileList)
{
    QSettings settings;
    settings.beginGroup(_settingsGroup);
    QString root = profilesSettingsRoot();
    settings.remove(root);
    int idx = 0;
    for (const QVariant& profileVar : profileList) {
        QVariantMap profile = profileVar.toMap();
        QString pRoot = root + QString("/Profile%1").arg(idx++);
        settings.setValue(pRoot + "/name", profile.value("name"));
        QVariantList items = profile.value("items").toList();
        QJsonDocument doc = QJsonDocument::fromVariant(items);
        settings.setValue(pRoot + "/items", doc.toJson(QJsonDocument::Compact));
    }
    settings.setValue(root + "/count", idx);
    settings.endGroup();

    if (profiles()) {
        QJsonDocument doc = QJsonDocument::fromVariant(profileList);
        profiles()->setRawValue(QString::fromUtf8(doc.toJson(QJsonDocument::Compact)));
    }
}
