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

const QString ButtonsSettings::profilesSettingsRoot()
{
    return QStringLiteral("ButtonProfiles");
}

QVariantList ButtonsSettings::loadButtonProfiles()
{
    QVariantList profiles;
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
            profiles.append(profile);
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
        profiles.append(profile);

        // Save default profile and activate it
        saveButtonProfiles(profiles);
        if (activeProfile()) {
            activeProfile()->setRawValue(0);
        }
    }

    settings.endGroup();
    return profiles;
}

void ButtonsSettings::saveButtonProfiles(const QVariantList& profiles)
{
    QSettings settings;
    settings.beginGroup(_settingsGroup);
    QString root = profilesSettingsRoot();
    settings.remove(root);
    int idx = 0;
    for (const QVariant& profileVar : profiles) {
        QVariantMap profile = profileVar.toMap();
        QString pRoot = root + QString("/Profile%1").arg(idx++);
        settings.setValue(pRoot + "/name", profile.value("name"));
        QVariantList items = profile.value("items").toList();
        QJsonDocument doc = QJsonDocument::fromVariant(items);
        settings.setValue(pRoot + "/items", doc.toJson(QJsonDocument::Compact));
    }
    settings.setValue(root + "/count", idx);
    settings.endGroup();
}
