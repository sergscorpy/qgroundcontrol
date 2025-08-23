#include "VehicleLockStatusFactGroup.h"
#include "Vehicle.h"
#include <cstring>

const char* VehicleLockStatusFactGroup::_chan1FactName = "chan1";
const char* VehicleLockStatusFactGroup::_chan2FactName = "chan2";
const char* VehicleLockStatusFactGroup::_chan3FactName = "chan3";
const char* VehicleLockStatusFactGroup::_chan4FactName = "chan4";
const char* VehicleLockStatusFactGroup::_chan5FactName = "chan5";
const char* VehicleLockStatusFactGroup::_chan6FactName = "chan6";
const char* VehicleLockStatusFactGroup::_chan7FactName = "chan7";
const char* VehicleLockStatusFactGroup::_chan8FactName = "chan8";

VehicleLockStatusFactGroup::VehicleLockStatusFactGroup(QObject* parent)
    : FactGroup(1000, ":/json/Vehicle/LockStatusFact.json", parent)
    , _chan1Fact(0, _chan1FactName, FactMetaData::valueTypeBool)
    , _chan2Fact(0, _chan2FactName, FactMetaData::valueTypeBool)
    , _chan3Fact(0, _chan3FactName, FactMetaData::valueTypeBool)
    , _chan4Fact(0, _chan4FactName, FactMetaData::valueTypeBool)
    , _chan5Fact(0, _chan5FactName, FactMetaData::valueTypeBool)
    , _chan6Fact(0, _chan6FactName, FactMetaData::valueTypeBool)
    , _chan7Fact(0, _chan7FactName, FactMetaData::valueTypeBool)
    , _chan8Fact(0, _chan8FactName, FactMetaData::valueTypeBool)
{
    _addFact(&_chan1Fact, _chan1FactName);
    _addFact(&_chan2Fact, _chan2FactName);
    _addFact(&_chan3Fact, _chan3FactName);
    _addFact(&_chan4Fact, _chan4FactName);
    _addFact(&_chan5Fact, _chan5FactName);
    _addFact(&_chan6Fact, _chan6FactName);
    _addFact(&_chan7Fact, _chan7FactName);
    _addFact(&_chan8Fact, _chan8FactName);

    for (int i=0; i<8; ++i) {
        getFact(QString("chan%1").arg(i+1))->setRawValue(false);
    }
}

void VehicleLockStatusFactGroup::handleMessage(Vehicle* /*vehicle*/, mavlink_message_t& message)
{
    if (message.msgid == MAVLINK_MSG_ID_NAMED_VALUE_INT) {
        _handleNamedValueInt(message);
    }
}

void VehicleLockStatusFactGroup::_handleNamedValueInt(mavlink_message_t& message)
{
    mavlink_named_value_int_t val;
    mavlink_msg_named_value_int_decode(&message, &val);
    if (strncmp(val.name, "LOCKED", MAVLINK_MSG_NAMED_VALUE_INT_FIELD_NAME_LEN) == 0) {
        uint32_t mask = static_cast<uint32_t>(val.value);
        for (int i=0; i<8; ++i) {
            Fact* fact = getFact(QString("chan%1").arg(i+1));
            if (fact) {
                bool locked = (mask & (1 << i)) != 0;
                fact->setRawValue(locked);
            }
        }
        _setTelemetryAvailable(true);
    }
}
