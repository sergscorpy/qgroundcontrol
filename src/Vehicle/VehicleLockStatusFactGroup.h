#pragma once

#include "FactGroup.h"

class VehicleLockStatusFactGroup : public FactGroup
{
    Q_OBJECT

public:
    VehicleLockStatusFactGroup(QObject* parent = nullptr);

    Q_PROPERTY(Fact* chan1 READ _chan1 CONSTANT)
    Q_PROPERTY(Fact* chan2 READ _chan2 CONSTANT)
    Q_PROPERTY(Fact* chan3 READ _chan3 CONSTANT)
    Q_PROPERTY(Fact* chan4 READ _chan4 CONSTANT)
    Q_PROPERTY(Fact* chan5 READ _chan5 CONSTANT)
    Q_PROPERTY(Fact* chan6 READ _chan6 CONSTANT)
    Q_PROPERTY(Fact* chan7 READ _chan7 CONSTANT)
    Q_PROPERTY(Fact* chan8 READ _chan8 CONSTANT)

    Fact* _chan1() { return &_chan1Fact; }
    Fact* _chan2() { return &_chan2Fact; }
    Fact* _chan3() { return &_chan3Fact; }
    Fact* _chan4() { return &_chan4Fact; }
    Fact* _chan5() { return &_chan5Fact; }
    Fact* _chan6() { return &_chan6Fact; }
    Fact* _chan7() { return &_chan7Fact; }
    Fact* _chan8() { return &_chan8Fact; }

    // FactGroup overrides
    void handleMessage(Vehicle* vehicle, mavlink_message_t& message) override;

private:
    void _handleNamedValueInt(mavlink_message_t& message);

    static const char* _chan1FactName;
    static const char* _chan2FactName;
    static const char* _chan3FactName;
    static const char* _chan4FactName;
    static const char* _chan5FactName;
    static const char* _chan6FactName;
    static const char* _chan7FactName;
    static const char* _chan8FactName;

    Fact _chan1Fact;
    Fact _chan2Fact;
    Fact _chan3Fact;
    Fact _chan4Fact;
    Fact _chan5Fact;
    Fact _chan6Fact;
    Fact _chan7Fact;
    Fact _chan8Fact;
};
