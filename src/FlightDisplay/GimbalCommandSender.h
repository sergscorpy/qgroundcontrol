// GimbalCommandSender.h
#pragma once

#include <QObject>
#include <QUdpSocket>
#include <QHostAddress>

class GimbalCommandSender : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double pitchCamAngle READ pitchCamAngle NOTIFY pitchCamAngleChanged)
    Q_PROPERTY(bool gimbalCommandInProgress READ gimbalCommandInProgress NOTIFY gimbalCommandInProgressChanged)
    Q_PROPERTY(bool cameraCommandInProgress READ cameraCommandInProgress NOTIFY cameraCommandInProgressChanged)

public:
    explicit GimbalCommandSender(QObject *parent = nullptr);

    Q_INVOKABLE void sendPitchDown();
    Q_INVOKABLE void sendPitchCenter();
    Q_INVOKABLE void sendRebootCamera();
    Q_INVOKABLE void sendRebootGimbal();
    Q_INVOKABLE void activateFPVMode();
    Q_INVOKABLE void activateAimMode();

    double pitchCamAngle() const;
    bool gimbalCommandInProgress() const;
    bool cameraCommandInProgress() const;

signals:
    void pitchCamAngleChanged();
    void gimbalCommandInProgressChanged();
    void cameraCommandInProgressChanged();

private slots:
    void onReadyRead();

private:
    void sendCommand(const QByteArray& raw);
    void setGimbalCommandInProgress(bool inProgress);
    void setCameraCommandInProgress(bool inProgress);

    QUdpSocket* udpSocket;
    QHostAddress gimbalIp;
    quint16 gimbalPort;

    double _pitchCamAngle = 0.0;
    bool _gimbalCommandInProgress = false;
    bool _cameraCommandInProgress = false;

    quint16 crc16(const QByteArray& command);
    static const uint16_t crc16_tab[256];
};
