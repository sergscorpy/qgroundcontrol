#include "MyJoystickHandler.h"
#include <QDebug>
#include "QGCApplication.h"

MyJoystickHandler::MyJoystickHandler()
    : _joystickAndroid(nullptr)
{
    initializeJoystick();
}

MyJoystickHandler::~MyJoystickHandler()
{
    for (auto it = _connectedJoysticks.constBegin(); it != _connectedJoysticks.constEnd(); ++it)
    {
        JoystickAndroid* joystick = *it;
        disconnect(joystick, &JoystickAndroid::axisMoved, this, &MyJoystickHandler::onAxisMoved);
        disconnect(joystick, &JoystickAndroid::buttonPressed, this, &MyJoystickHandler::onButtonPressed);
    }
    _connectedJoysticks.clear();
}

void MyJoystickHandler::initializeJoystick()
{
    QMap<QString, Joystick*> joysticks = JoystickAndroid::discover(qgcApp()->toolbox()->multiVehicleManager());

    for (auto it = joysticks.begin(); it != joysticks.end(); ++it) {
        JoystickAndroid* ja = dynamic_cast<JoystickAndroid*>(it.value());
        if (!ja) continue;

        connect(ja, &JoystickAndroid::axisMoved, this, &MyJoystickHandler::onAxisMoved);
        connect(ja, &JoystickAndroid::buttonPressed, this, &MyJoystickHandler::onButtonPressed);

        _connectedJoysticks.append(ja);
    }
}

void MyJoystickHandler::onButtonPressed(int buttonId, bool pressed)
{
    qDebug() << "Button" << buttonId << (pressed ? "pressed" : "released");

    // TODO ...
}

void MyJoystickHandler::onAxisMoved(int axisId, int value)
{
    qDebug() << "Axis" << axisId << "moved to" << value;

    // TODO ...
}
