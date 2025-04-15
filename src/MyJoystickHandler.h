#ifndef MYJOYSTICKHANDLER_H
#define MYJOYSTICKHANDLER_H

#include <QObject>
#include "JoystickAndroid.h"

class MyJoystickHandler : public QObject
{
    Q_OBJECT

public:
    MyJoystickHandler();
    ~MyJoystickHandler();

private slots:
    void onButtonPressed(int buttonId, bool pressed);
    void onAxisMoved(int axisId, int value);
    QList<JoystickAndroid*> _connectedJoysticks;

private:
    JoystickAndroid* _joystickAndroid;
    void initializeJoystick();
};

#endif // MYJOYSTICKHANDLER_H
