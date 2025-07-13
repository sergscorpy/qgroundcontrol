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
    }
    return profiles;
}

void ButtonsSettings::saveButtonProfiles(const QVariantList& profiles)
{
    QSettings settings;
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
}
