#ifndef JOYSTICKANDROID_H
#define JOYSTICKANDROID_H

#include "Joystick.h"
#include "Vehicle.h"
#include "MultiVehicleManager.h"

#include <jni.h>
#include <QtCore/private/qjni_p.h>
#include <QtCore/private/qjnihelpers_p.h>
#include <QtAndroidExtras/QtAndroidExtras>
#include <QtAndroidExtras/QAndroidJniObject>


class JoystickAndroid : public Joystick, public QtAndroidPrivate::GenericMotionEventListener, public QtAndroidPrivate::KeyEventListener
{
    Q_OBJECT
public:
    JoystickAndroid(const QString& name, int axisCount, int buttonCount, int id, MultiVehicleManager* multiVehicleManager);

    ~JoystickAndroid();

    static bool init(JoystickManager *manager);

    static void setNativeMethods();

    static QMap<QString, Joystick*> discover(MultiVehicleManager* _multiVehicleManager);

signals:
    void buttonPressed(int buttonId, bool pressed);
    void axisMoved(int axisId, int value);

private:
    bool handleKeyEvent(jobject event);
    bool handleGenericMotionEvent(jobject event);

    virtual bool _open          ();
    virtual void _close         ();
    virtual bool _update        ();

    virtual bool _getButton     (int i);
    virtual int  _getAxis       (int i);
    virtual bool _getHat        (int hat,int i);

    int *btnCode;
    int *axisCode;
    bool *btnValue;
    int *axisValue;

    static int * _androidBtnList; //list of all possible android buttons
    static int _androidBtnListCount;

    static int ACTION_DOWN, ACTION_UP;
    static QMutex m_mutex;

    int deviceId;
};

#endif // JOYSTICKANDROID_H
