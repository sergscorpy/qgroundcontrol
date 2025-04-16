#include "JoystickHandler.h"
#include <QDebug>
#include "QGCApplication.h"

JoystickHandler::JoystickHandler()
    : _joystickAndroid(nullptr)
{
    _dispatcher = new InputActionDispatcher(this);
    initializeJoystick();
}

JoystickHandler::~JoystickHandler()
{
    for (auto it = _connectedJoysticks.constBegin(); it != _connectedJoysticks.constEnd(); ++it)
    {
        JoystickAndroid* joystick = *it;
        disconnect(joystick, &JoystickAndroid::axisMoved, this, &JoystickHandler::onAxisMoved);
        disconnect(joystick, &JoystickAndroid::buttonPressed, this, &JoystickHandler::onButtonPressed);
    }
    _connectedJoysticks.clear();
}

void JoystickHandler::initializeJoystick()
{
    QMap<QString, Joystick*> joysticks = JoystickAndroid::discover(qgcApp()->toolbox()->multiVehicleManager());

    for (auto it = joysticks.begin(); it != joysticks.end(); ++it) {
        JoystickAndroid* ja = dynamic_cast<JoystickAndroid*>(it.value());
        if (!ja) continue;

        connect(ja, &JoystickAndroid::axisMoved, this, &JoystickHandler::onAxisMoved);
        connect(ja, &JoystickAndroid::buttonPressed, this, &JoystickHandler::onButtonPressed);

        _connectedJoysticks.append(ja);
    }
}

void JoystickHandler::onButtonPressed(int buttonId, bool pressed)
{
    if (pressed) {
        QString name = QString("Button_%1").arg(buttonId);
        _dispatcher->handleInput(name);
    }
}

void JoystickHandler::onAxisMoved(int axisId, int value)
{
    QString name = QString("Axis_%1").arg(axisId);
    _dispatcher->handleInput(name, value);
}
