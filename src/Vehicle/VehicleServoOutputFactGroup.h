/****************************************************************************
 *
 * (c) 2009-2023 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include "FactGroup.h"
#include "QGCMAVLink.h"

class Vehicle;

class VehicleServoOutputFactGroup : public FactGroup
{
    Q_OBJECT

public:
    VehicleServoOutputFactGroup(QObject* parent = nullptr);

    Q_PROPERTY(Fact* servo1  READ servo1 CONSTANT)
    Q_PROPERTY(Fact* servo2  READ servo2 CONSTANT)
    Q_PROPERTY(Fact* servo3  READ servo3 CONSTANT)
    Q_PROPERTY(Fact* servo4  READ servo4 CONSTANT)
    Q_PROPERTY(Fact* servo5  READ servo5 CONSTANT)
    Q_PROPERTY(Fact* servo6  READ servo6 CONSTANT)
    Q_PROPERTY(Fact* servo7  READ servo7 CONSTANT)
    Q_PROPERTY(Fact* servo8  READ servo8 CONSTANT)
    Q_PROPERTY(Fact* servo9  READ servo9 CONSTANT)
    Q_PROPERTY(Fact* servo10 READ servo10 CONSTANT)
    Q_PROPERTY(Fact* servo11 READ servo11 CONSTANT)
    Q_PROPERTY(Fact* servo12 READ servo12 CONSTANT)
    Q_PROPERTY(Fact* servo13 READ servo13 CONSTANT)
    Q_PROPERTY(Fact* servo14 READ servo14 CONSTANT)
    Q_PROPERTY(Fact* servo15 READ servo15 CONSTANT)
    Q_PROPERTY(Fact* servo16 READ servo16 CONSTANT)

    Fact* servo1 () { return &_servo1Fact; }
    Fact* servo2 () { return &_servo2Fact; }
    Fact* servo3 () { return &_servo3Fact; }
    Fact* servo4 () { return &_servo4Fact; }
    Fact* servo5 () { return &_servo5Fact; }
    Fact* servo6 () { return &_servo6Fact; }
    Fact* servo7 () { return &_servo7Fact; }
    Fact* servo8 () { return &_servo8Fact; }
    Fact* servo9 () { return &_servo9Fact; }
    Fact* servo10() { return &_servo10Fact; }
    Fact* servo11() { return &_servo11Fact; }
    Fact* servo12() { return &_servo12Fact; }
    Fact* servo13() { return &_servo13Fact; }
    Fact* servo14() { return &_servo14Fact; }
    Fact* servo15() { return &_servo15Fact; }
    Fact* servo16() { return &_servo16Fact; }

    // Overrides from FactGroup
    void handleMessage(Vehicle* vehicle, mavlink_message_t& message) override;

    static const char* _servo1FactName;
    static const char* _servo2FactName;
    static const char* _servo3FactName;
    static const char* _servo4FactName;
    static const char* _servo5FactName;
    static const char* _servo6FactName;
    static const char* _servo7FactName;
    static const char* _servo8FactName;
    static const char* _servo9FactName;
    static const char* _servo10FactName;
    static const char* _servo11FactName;
    static const char* _servo12FactName;
    static const char* _servo13FactName;
    static const char* _servo14FactName;
    static const char* _servo15FactName;
    static const char* _servo16FactName;

private:
    void _handleServoOutputRaw(mavlink_message_t& message);
    void _handleActuatorOutputStatus(mavlink_message_t& message);

    Fact _servo1Fact;
    Fact _servo2Fact;
    Fact _servo3Fact;
    Fact _servo4Fact;
    Fact _servo5Fact;
    Fact _servo6Fact;
    Fact _servo7Fact;
    Fact _servo8Fact;
    Fact _servo9Fact;
    Fact _servo10Fact;
    Fact _servo11Fact;
    Fact _servo12Fact;
    Fact _servo13Fact;
    Fact _servo14Fact;
    Fact _servo15Fact;
    Fact _servo16Fact;
};
