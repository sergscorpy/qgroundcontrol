#ifndef JOYSTICKHANDLER_H
#define JOYSTICKHANDLER_H

#include <QObject>
#ifdef __android__
#include "JoystickAndroid.h"

#include "InputActionDispatcher.h"

class JoystickHandler : public QObject
{
    Q_OBJECT

public:
    JoystickHandler();
    ~JoystickHandler();

private slots:
    void onButtonPressed(int buttonId, bool pressed);
    void onAxisMoved(int axisId, int value);

private:
    JoystickAndroid* _joystickAndroid;
    void initializeJoystick();
    QList<JoystickAndroid*> _connectedJoysticks;
    InputActionDispatcher* _dispatcher;
};
#endif
#endif // JOYSTICKHANDLER_H

