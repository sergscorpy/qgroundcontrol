#ifndef INPUTACTIONDISPATCHER_H
#define INPUTACTIONDISPATCHER_H

#include <QObject>
#include <QUdpSocket>
#include <QMutex>
#include <QElapsedTimer>
#include <QTimer>
#include <QMap>
#include <QHash>

class InputActionDispatcher : public QObject
{
    Q_OBJECT
public:
    explicit InputActionDispatcher(QObject* parent = nullptr);

    void handleInput(const QString& name, int value = 0, bool isRepeat = false);

private:
    QUdpSocket _udpSocket;
    QMutex _mutex;

    QMap<QString, int> _buttonActionIndex;
    QMap<QString, int> _lastAxisValue;
    QHash<QString, qint64> _lastSendTimestamps;
    QTimer _repeatTimer;
    QElapsedTimer _timer;

    int _deadzone = 1000;
    int _sendIntervalMs = 50;
};

#endif // INPUTACTIONDISPATCHER_H
