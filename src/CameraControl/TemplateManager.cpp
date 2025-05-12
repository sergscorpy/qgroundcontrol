#include "TemplateManager.h"
#include <QFile>
#include <QJsonDocument>
#include <QDebug>
#include "SettingsManager.h"

TemplateManager::TemplateManager(QGCApplication* app, QGCToolbox* toolbox)
    : QGCTool(app, toolbox)
{
    _templateName = "CameraTemplate.json";
    _baseTemplatePath = ":/res/src/Settings/" + _templateName;

    QString downloadPath = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    QDir baseDir(downloadPath);
    baseDir.cdUp();
    QString configDirPath = baseDir.filePath("49KSConfigs");
    QDir().mkpath(configDirPath);
    _templatePath = configDirPath + "/" + _templateName;

    qDebug() << "[TemplateManager] Template path:" << _templatePath;

    if (!QFile::exists(_templatePath)) {
        if (!QFile::copy(_baseTemplatePath, _templatePath)) {
            qWarning() << "Failed to copy template from" << _baseTemplatePath << "to" << _templatePath;
        } else {
            qDebug() << "[TemplateManager] Template copied to" << _templatePath;
        }
    }
}

void TemplateManager::setToolbox(QGCToolbox* toolbox)
{
    QGCTool::setToolbox(toolbox);
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);

    _lastCameraType = _toolbox->settingsManager()->cameraSettings()->cameraType()->rawValue().toInt();

    connect(
        _toolbox->settingsManager()->cameraSettings()->cameraType(),
        &Fact::rawValueChanged,
        this,
        [this](const QVariant& newValue) {
            if (!newValue.isValid() || !newValue.canConvert<int>()) {
                qWarning() << "[TemplateManager] Invalid camera type value:" << newValue;
                return;
            }

            int id = newValue.toInt();
            if (id != _lastCameraType) {
                _lastCameraType = id;
                loadTemplate();
            }
        }
        );

    _keepaliveTimer.setInterval(500);
    _keepaliveTimer.setSingleShot(false);

    connect(&_keepaliveTimer, &QTimer::timeout, this, [this]() {
        QByteArray payload = getActionPayload("empty");

        if (!payload.isEmpty()) {
            _udpSocket.writeDatagram(payload, QHostAddress(_ip), _port);
        } else {
            qWarning() << "[TemplateManager] keep_alive action not found!";
        }
    });

    connect(&_watcher, &QFileSystemWatcher::fileChanged, this, &TemplateManager::onFileChanged);
    loadTemplate();
}

void TemplateManager::loadTemplate()
{
    QFile file(_templatePath);
    if (!file.exists()) {
        qWarning() << "Template file not found:" << _templatePath;
        return;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Failed to open template file:" << _templatePath;
        return;
    }

    const QByteArray data = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);
    if (error.error != QJsonParseError::NoError || !doc.isObject()) {
        qWarning() << "JSON parse error:" << error.errorString();
        return;
    }

    const QJsonObject rootObj = doc.object();

    if (!rootObj.contains("cameras") || !rootObj["cameras"].isArray()) {
        qWarning() << "Missing or invalid 'cameras' array in template file";
        return;
    }

    QJsonArray camerasArray = rootObj["cameras"].toArray();

    int selectedCameraId = static_cast<int>(
        _toolbox->settingsManager()->cameraSettings()->cameraType()->rawValue().toInt()
        );

    bool found = false;

    for (const QJsonValue& camVal : std::as_const(camerasArray)) {
        if (!camVal.isObject()) continue;

        const QJsonObject& camObj = camVal.toObject();
        int id = camObj.value("id").toInt(-1);

        if (id == selectedCameraId) {
            parseJson(camObj);
            found = true;
            break;
        }
    }

    if (!found) {
        qWarning() << "Camera with ID" << selectedCameraId << "not found in template file";
        _isActive = false;
        _ip = "127.0.0.1";
        _port = 0;
        _controls.clear();
        _ignoredControls.clear();
        _actions.clear();

        emit templateChanged();
        return;
    }

    bool requiresKeepalive = (selectedCameraId == 2);

    if (requiresKeepalive) {
        if (!_keepaliveTimer.isActive()) {
            _keepaliveTimer.start();
            qDebug() << "[TemplateManager] Keep-alive started for camera ID" << selectedCameraId;
        }
    } else {
        if (_keepaliveTimer.isActive()) {
            _keepaliveTimer.stop();
            qDebug() << "[TemplateManager] Keep-alive stopped";
        }
    }


    if (!_watcher.files().contains(_templatePath)) {
        _watcher.addPath(_templatePath);
    }

    emit templateChanged();
}

void TemplateManager::onFileChanged(const QString& path)
{
    qDebug() << "Template file changed, reloading...";
    loadTemplate();
}

void TemplateManager::parseJson(const QJsonObject& obj)
{
    _isActive = obj.value("is_active").toBool();
    _ip = obj.value("ip").toString("127.0.0.1");
    _port = static_cast<quint16>(obj.value("port").toInt(14550));

    _controls.clear();
    const QJsonArray controlsArray = obj.value("controls").toArray();
    for (const QJsonValue& val : controlsArray) {
        QJsonObject o = val.toObject();
        Control c;
        c.name = o["name"].toString();
        c.type = o["type"].toString();
        c.actions = o["actions"].toVariant().toStringList();
        c.isReversed = o["is_reversed"].toBool();
        _controls.append(c);
    }

    _ignoredControls = obj.value("ignored_controls").toVariant().toStringList();

    _actions.clear();
    const QJsonArray actionsArray = obj.value("actions").toArray();
    for (const QJsonValue& val : actionsArray) {
        QJsonObject o = val.toObject();
        Action a;
        a.name = o["name"].toString();
        a.body = o["body"].toString();
        _actions.append(a);
    }
}

QByteArray TemplateManager::getActionPayload(const QString& actionName) const {
    for (const Action& a : _actions) {
        if (a.name == actionName) {
            return QByteArray::fromHex(a.body.toUtf8());
        }
    }
    return {};
}

void TemplateManager::sendActionPacket(const QString& actionName)
{
    for (const Action& a : std::as_const(_actions)) {
        if (a.name == actionName) {
            QByteArray payload = QByteArray::fromHex(a.body.toUtf8());
            if (_udpSocket.writeDatagram(payload, QHostAddress(_ip), _port) < 0) {
               qWarning() << "[TemplateManager] Failed to send action" << actionName;
            }
            return;
        }
    }
    qWarning() << "[TemplateManager] Action not found:" << actionName;
}

bool TemplateManager::isActive() const { return _isActive; }
QList<Control> TemplateManager::controls() const { return _controls; }
QStringList TemplateManager::ignoredControls() const { return _ignoredControls; }
QList<Action> TemplateManager::actions() const { return _actions; }
