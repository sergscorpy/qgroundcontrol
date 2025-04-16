#include "InputActionDispatcher.h"
#include "TemplateManager.h"
#include "QGCApplication.h"

#include <QHostAddress>

InputActionDispatcher::InputActionDispatcher(QObject* parent)
    : QObject(parent)
{
    _timer.start();

    connect(&_repeatTimer, &QTimer::timeout, this, [this]() {
        for (auto it = _lastAxisValue.begin(); it != _lastAxisValue.end(); ++it) {
            if (qAbs(it.value()) >= _deadzone) {
                handleInput(it.key(), it.value(), /*isRepeat*/ true);
            }
        }
    });

    _repeatTimer.setInterval(_sendIntervalMs);
    _repeatTimer.start();
}

void InputActionDispatcher::handleInput(const QString& name, int value, bool isRepeat)
{
    QMutexLocker locker(&_mutex);
    TemplateManager* tmpl = qgcApp()->toolbox()->templateManager();

    if (!tmpl || !tmpl->isActive()) return;
    if (tmpl->ignoredControls().contains(name)) return;

    const QList<Control>& controls = tmpl->controls();
    const QList<Action>& actions = tmpl->actions();

    for (const Control& c : controls) {
        if (c.name != name)
            continue;

        // ==== AXIS ====
        if (c.type == "axis") {
            if (c.actions.isEmpty()) return;

            if (qAbs(value) < _deadzone) {
                _lastAxisValue.remove(name);
                return;
            }

            _lastAxisValue[name] = value;

            if (!isRepeat) {
                qint64 now = _timer.elapsed();
                if (_lastSendTimestamps.contains(name) &&
                    now - _lastSendTimestamps[name] < _sendIntervalMs) {
                    return;
                }
                _lastSendTimestamps[name] = now;
            }

            int direction = (value > 0) ? 1 : ((value < 0) ? -1 : 0);
            if (direction == 0) return;

            if (c.isReversed)
                direction *= -1;

            int total = c.actions.size();
            int half = total / 2;
            if (half == 0) return;

            QList<QString> subset = (direction > 0)
                                        ? c.actions.mid(0, half)
                                        : c.actions.mid(half, half);

            float norm = static_cast<float>(qAbs(value) - _deadzone) / (32767.f - _deadzone);
            norm = qBound(0.f, norm, 1.f);

            int index = qMin(static_cast<int>(norm * subset.size()), subset.size() - 1);

            const QString& actionName = subset[index];

            for (const Action& a : actions) {
                if (a.name == actionName) {
                    QByteArray payload = QByteArray::fromHex(a.body.toUtf8());
                    _udpSocket.writeDatagram(payload, QHostAddress(tmpl->ip()), tmpl->port());
                    return;
                }
            }
        }

        // ==== BUTTON ====
        else if (c.type == "button") {
            if (isRepeat) return;
            if (c.actions.isEmpty()) return;

            int& index = _buttonActionIndex[name];
            const QString& actionName = c.actions[index % c.actions.size()];
            index++;

            for (const Action& a : actions) {
                if (a.name == actionName) {
                    QByteArray payload = QByteArray::fromHex(a.body.toUtf8());
                    _udpSocket.writeDatagram(payload, QHostAddress(tmpl->ip()), tmpl->port());
                    return;
                }
            }
        }
    }
}
