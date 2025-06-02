#ifndef TEMPLATEMANAGER_H
#define TEMPLATEMANAGER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QJsonObject>
#include <QJsonArray>
#include <QStandardPaths>
#include "QGCApplication.h"

struct Control {
    QString name;
    QString type;
    QStringList actions;
    bool isReversed;
};

struct Action {
    QString name;
    QString body;
};

class TemplateManager : public QGCTool
{
    Q_OBJECT

public:
    TemplateManager(QGCApplication* app, QGCToolbox* toolbox);
    void setToolbox(QGCToolbox* toolbox) override;
    bool isActive() const;
    QList<Control> controls() const;
    QStringList ignoredControls() const;
    QList<Action> actions() const;
    QString ip() const { return _ip; }
    quint16 port() const { return _port; }
    QByteArray getActionPayload(const QString &actionName) const;
    Q_INVOKABLE void sendActionPacket(const QString& actionName);
signals:
    void templateChanged();

private slots:
    void loadTemplate();
    void onFileChanged(const QString& path);

private:
    QString _templateName;
    QString _baseTemplatePath;
    QString _templatePath;
    qint16 _lastCameraType;

    QTimer _keepaliveTimer;
    QTimer _resolutionTimer;
    QUdpSocket _udpSocket;

    QString _ip = "127.0.0.1";
    quint16 _port = 14550;

    QFileSystemWatcher _watcher;

    bool _isActive = false;
    QList<Control> _controls;
    QStringList _ignoredControls;
    QList<Action> _actions;

    void parseJson(const QJsonObject& obj);
};

#endif // TEMPLATEMANAGER_H
