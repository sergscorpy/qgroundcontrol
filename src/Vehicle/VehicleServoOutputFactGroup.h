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
    Q_PROPERTY(Fact* servo17 READ servo17 CONSTANT)
    Q_PROPERTY(Fact* servo18 READ servo18 CONSTANT)
    Q_PROPERTY(Fact* servo19 READ servo19 CONSTANT)
    Q_PROPERTY(Fact* servo20 READ servo20 CONSTANT)
    Q_PROPERTY(Fact* servo21 READ servo21 CONSTANT)
    Q_PROPERTY(Fact* servo22 READ servo22 CONSTANT)
    Q_PROPERTY(Fact* servo23 READ servo23 CONSTANT)
    Q_PROPERTY(Fact* servo24 READ servo24 CONSTANT)
    Q_PROPERTY(Fact* servo25 READ servo25 CONSTANT)
    Q_PROPERTY(Fact* servo26 READ servo26 CONSTANT)
    Q_PROPERTY(Fact* servo27 READ servo27 CONSTANT)
    Q_PROPERTY(Fact* servo28 READ servo28 CONSTANT)
    Q_PROPERTY(Fact* servo29 READ servo29 CONSTANT)
    Q_PROPERTY(Fact* servo30 READ servo30 CONSTANT)
    Q_PROPERTY(Fact* servo31 READ servo31 CONSTANT)
    Q_PROPERTY(Fact* servo32 READ servo32 CONSTANT)

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
    Fact* servo17() { return &_servo17Fact; }
    Fact* servo18() { return &_servo18Fact; }
    Fact* servo19() { return &_servo19Fact; }
    Fact* servo20() { return &_servo20Fact; }
    Fact* servo21() { return &_servo21Fact; }
    Fact* servo22() { return &_servo22Fact; }
    Fact* servo23() { return &_servo23Fact; }
    Fact* servo24() { return &_servo24Fact; }
    Fact* servo25() { return &_servo25Fact; }
    Fact* servo26() { return &_servo26Fact; }
    Fact* servo27() { return &_servo27Fact; }
    Fact* servo28() { return &_servo28Fact; }
    Fact* servo29() { return &_servo29Fact; }
    Fact* servo30() { return &_servo30Fact; }
    Fact* servo31() { return &_servo31Fact; }
    Fact* servo32() { return &_servo32Fact; }

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
    static const char* _servo17FactName;
    static const char* _servo18FactName;
    static const char* _servo19FactName;
    static const char* _servo20FactName;
    static const char* _servo21FactName;
    static const char* _servo22FactName;
    static const char* _servo23FactName;
    static const char* _servo24FactName;
    static const char* _servo25FactName;
    static const char* _servo26FactName;
    static const char* _servo27FactName;
    static const char* _servo28FactName;
    static const char* _servo29FactName;
    static const char* _servo30FactName;
    static const char* _servo31FactName;
    static const char* _servo32FactName;

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
    Fact _servo17Fact;
    Fact _servo18Fact;
    Fact _servo19Fact;
    Fact _servo20Fact;
    Fact _servo21Fact;
    Fact _servo22Fact;
    Fact _servo23Fact;
    Fact _servo24Fact;
    Fact _servo25Fact;
    Fact _servo26Fact;
    Fact _servo27Fact;
    Fact _servo28Fact;
    Fact _servo29Fact;
    Fact _servo30Fact;
    Fact _servo31Fact;
    Fact _servo32Fact;
};
