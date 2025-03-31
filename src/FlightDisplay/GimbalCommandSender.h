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
    Q_PROPERTY(bool commandInProgress READ commandInProgress NOTIFY commandInProgressChanged)

public:
    explicit GimbalCommandSender(QObject *parent = nullptr);

    Q_INVOKABLE void sendPitchDown();
    Q_INVOKABLE void sendPitchCenter();
    Q_INVOKABLE void sendReadPositionCommand();
    Q_INVOKABLE void startAutoUpdate();
    Q_INVOKABLE void stopAutoUpdate();
    Q_INVOKABLE void sendRebootCamera();
    Q_INVOKABLE void sendRebootGimbal();

    double pitchCamAngle() const;
    bool commandInProgress() const;

signals:
    void pitchCamAngleChanged();
    void commandInProgressChanged();

private slots:
    void onReadyRead();
    void onUpdateTimerTimeout();

private:
    void sendCommand(const QByteArray& raw);
    void setCommandInProgress(bool inProgress);

    QUdpSocket* udpSocket;
    QHostAddress gimbalIp;
    quint16 gimbalPort;

    QTimer updateTimer;
    double _pitchCamAngle = 0.0;
    bool _commandInProgress = false;

    quint16 crc16(const QByteArray& command);
    static const uint16_t crc16_tab[256];
};
