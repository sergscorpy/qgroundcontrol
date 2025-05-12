// GimbalCommandSender.h
#pragma once

#include <QObject>
#include <QUdpSocket>
#include <QHostAddress>
#include <QTimer>

class GimbalCommandSender : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double pitchCamAngle READ pitchCamAngle NOTIFY pitchCamAngleChanged)
    Q_PROPERTY(bool gimbalCommandInProgress READ gimbalCommandInProgress NOTIFY gimbalCommandInProgressChanged)
    Q_PROPERTY(bool cameraCommandInProgress READ cameraCommandInProgress NOTIFY cameraCommandInProgressChanged)
    Q_PROPERTY(int gimbalMode READ gimbalMode NOTIFY gimbalModeChanged)

public:
    explicit GimbalCommandSender(QObject *parent = nullptr);

    Q_INVOKABLE void sendPitchDown();
    Q_INVOKABLE void sendPitchCenter();
    Q_INVOKABLE void sendRebootCamera();
    Q_INVOKABLE void sendRebootGimbal();
    Q_INVOKABLE void activateFPVMode();
    Q_INVOKABLE void activateAimMode();
    Q_INVOKABLE void requestGimbalMode();
    Q_INVOKABLE void changeColorSchema();

    double pitchCamAngle() const;
    bool gimbalCommandInProgress() const;
    bool cameraCommandInProgress() const;
    int gimbalMode() const;

signals:
    void pitchCamAngleChanged();
    void gimbalCommandInProgressChanged();
    void cameraCommandInProgressChanged();
    void gimbalModeChanged();

private slots:
    void onReadyRead();

private:
    void sendCommand(const QByteArray& raw);
    void setGimbalCommandInProgress(bool inProgress);
    void setCameraCommandInProgress(bool inProgress);
    void setGimbalMode(int mode);

    QUdpSocket* udpSocket;
    QHostAddress gimbalIp;
    quint16 gimbalPort;

    double _pitchCamAngle = 0.0;
    bool _gimbalCommandInProgress = false;
    bool _cameraCommandInProgress = false;
    int _gimbalMode = -1;

    quint16 crc16(const QByteArray& command);
    static const uint16_t crc16_tab[256];
};
