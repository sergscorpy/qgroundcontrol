/****************************************************************************
 *
 * (c) 2009-2023 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#include "VehicleServoOutputFactGroup.h"
#include "Vehicle.h"

const char* VehicleServoOutputFactGroup::_servo1FactName  = "servo1";
const char* VehicleServoOutputFactGroup::_servo2FactName  = "servo2";
const char* VehicleServoOutputFactGroup::_servo3FactName  = "servo3";
const char* VehicleServoOutputFactGroup::_servo4FactName  = "servo4";
const char* VehicleServoOutputFactGroup::_servo5FactName  = "servo5";
const char* VehicleServoOutputFactGroup::_servo6FactName  = "servo6";
const char* VehicleServoOutputFactGroup::_servo7FactName  = "servo7";
const char* VehicleServoOutputFactGroup::_servo8FactName  = "servo8";
const char* VehicleServoOutputFactGroup::_servo9FactName  = "servo9";
const char* VehicleServoOutputFactGroup::_servo10FactName = "servo10";
const char* VehicleServoOutputFactGroup::_servo11FactName = "servo11";
const char* VehicleServoOutputFactGroup::_servo12FactName = "servo12";
const char* VehicleServoOutputFactGroup::_servo13FactName = "servo13";
const char* VehicleServoOutputFactGroup::_servo14FactName = "servo14";
const char* VehicleServoOutputFactGroup::_servo15FactName = "servo15";
const char* VehicleServoOutputFactGroup::_servo16FactName = "servo16";
const char* VehicleServoOutputFactGroup::_servo17FactName = "servo17";
const char* VehicleServoOutputFactGroup::_servo18FactName = "servo18";
const char* VehicleServoOutputFactGroup::_servo19FactName = "servo19";
const char* VehicleServoOutputFactGroup::_servo20FactName = "servo20";
const char* VehicleServoOutputFactGroup::_servo21FactName = "servo21";
const char* VehicleServoOutputFactGroup::_servo22FactName = "servo22";
const char* VehicleServoOutputFactGroup::_servo23FactName = "servo23";
const char* VehicleServoOutputFactGroup::_servo24FactName = "servo24";
const char* VehicleServoOutputFactGroup::_servo25FactName = "servo25";
const char* VehicleServoOutputFactGroup::_servo26FactName = "servo26";
const char* VehicleServoOutputFactGroup::_servo27FactName = "servo27";
const char* VehicleServoOutputFactGroup::_servo28FactName = "servo28";
const char* VehicleServoOutputFactGroup::_servo29FactName = "servo29";
const char* VehicleServoOutputFactGroup::_servo30FactName = "servo30";
const char* VehicleServoOutputFactGroup::_servo31FactName = "servo31";
const char* VehicleServoOutputFactGroup::_servo32FactName = "servo32";

VehicleServoOutputFactGroup::VehicleServoOutputFactGroup(QObject* parent)
    : FactGroup(1000, ":/json/Vehicle/ServoOutputFact.json", parent)
    , _servo1Fact (0, _servo1FactName,  FactMetaData::valueTypeFloat)
    , _servo2Fact (0, _servo2FactName,  FactMetaData::valueTypeFloat)
    , _servo3Fact (0, _servo3FactName,  FactMetaData::valueTypeFloat)
    , _servo4Fact (0, _servo4FactName,  FactMetaData::valueTypeFloat)
    , _servo5Fact (0, _servo5FactName,  FactMetaData::valueTypeFloat)
    , _servo6Fact (0, _servo6FactName,  FactMetaData::valueTypeFloat)
    , _servo7Fact (0, _servo7FactName,  FactMetaData::valueTypeFloat)
    , _servo8Fact (0, _servo8FactName,  FactMetaData::valueTypeFloat)
    , _servo9Fact (0, _servo9FactName,  FactMetaData::valueTypeFloat)
    , _servo10Fact(0, _servo10FactName, FactMetaData::valueTypeFloat)
    , _servo11Fact(0, _servo11FactName, FactMetaData::valueTypeFloat)
    , _servo12Fact(0, _servo12FactName, FactMetaData::valueTypeFloat)
    , _servo13Fact(0, _servo13FactName, FactMetaData::valueTypeFloat)
    , _servo14Fact(0, _servo14FactName, FactMetaData::valueTypeFloat)
    , _servo15Fact(0, _servo15FactName, FactMetaData::valueTypeFloat)
    , _servo16Fact(0, _servo16FactName, FactMetaData::valueTypeFloat)
    , _servo17Fact(0, _servo17FactName, FactMetaData::valueTypeFloat)
    , _servo18Fact(0, _servo18FactName, FactMetaData::valueTypeFloat)
    , _servo19Fact(0, _servo19FactName, FactMetaData::valueTypeFloat)
    , _servo20Fact(0, _servo20FactName, FactMetaData::valueTypeFloat)
    , _servo21Fact(0, _servo21FactName, FactMetaData::valueTypeFloat)
    , _servo22Fact(0, _servo22FactName, FactMetaData::valueTypeFloat)
    , _servo23Fact(0, _servo23FactName, FactMetaData::valueTypeFloat)
    , _servo24Fact(0, _servo24FactName, FactMetaData::valueTypeFloat)
    , _servo25Fact(0, _servo25FactName, FactMetaData::valueTypeFloat)
    , _servo26Fact(0, _servo26FactName, FactMetaData::valueTypeFloat)
    , _servo27Fact(0, _servo27FactName, FactMetaData::valueTypeFloat)
    , _servo28Fact(0, _servo28FactName, FactMetaData::valueTypeFloat)
    , _servo29Fact(0, _servo29FactName, FactMetaData::valueTypeFloat)
    , _servo30Fact(0, _servo30FactName, FactMetaData::valueTypeFloat)
    , _servo31Fact(0, _servo31FactName, FactMetaData::valueTypeFloat)
    , _servo32Fact(0, _servo32FactName, FactMetaData::valueTypeFloat)
{
    _addFact(&_servo1Fact,  _servo1FactName);
    _addFact(&_servo2Fact,  _servo2FactName);
    _addFact(&_servo3Fact,  _servo3FactName);
    _addFact(&_servo4Fact,  _servo4FactName);
    _addFact(&_servo5Fact,  _servo5FactName);
    _addFact(&_servo6Fact,  _servo6FactName);
    _addFact(&_servo7Fact,  _servo7FactName);
    _addFact(&_servo8Fact,  _servo8FactName);
    _addFact(&_servo9Fact,  _servo9FactName);
    _addFact(&_servo10Fact, _servo10FactName);
    _addFact(&_servo11Fact, _servo11FactName);
    _addFact(&_servo12Fact, _servo12FactName);
    _addFact(&_servo13Fact, _servo13FactName);
    _addFact(&_servo14Fact, _servo14FactName);
    _addFact(&_servo15Fact, _servo15FactName);
    _addFact(&_servo16Fact, _servo16FactName);
    _addFact(&_servo17Fact, _servo17FactName);
    _addFact(&_servo18Fact, _servo18FactName);
    _addFact(&_servo19Fact, _servo19FactName);
    _addFact(&_servo20Fact, _servo20FactName);
    _addFact(&_servo21Fact, _servo21FactName);
    _addFact(&_servo22Fact, _servo22FactName);
    _addFact(&_servo23Fact, _servo23FactName);
    _addFact(&_servo24Fact, _servo24FactName);
    _addFact(&_servo25Fact, _servo25FactName);
    _addFact(&_servo26Fact, _servo26FactName);
    _addFact(&_servo27Fact, _servo27FactName);
    _addFact(&_servo28Fact, _servo28FactName);
    _addFact(&_servo29Fact, _servo29FactName);
    _addFact(&_servo30Fact, _servo30FactName);
    _addFact(&_servo31Fact, _servo31FactName);
    _addFact(&_servo32Fact, _servo32FactName);

    for (int i=0; i<32; ++i) {
        getFact(QString("servo%1").arg(i+1))->setRawValue(qQNaN());
    }
}

void VehicleServoOutputFactGroup::handleMessage(Vehicle* /*vehicle*/, mavlink_message_t& message)
{
    switch (message.msgid) {
    case MAVLINK_MSG_ID_SERVO_OUTPUT_RAW:
        _handleServoOutputRaw(message);
        break;
    case MAVLINK_MSG_ID_ACTUATOR_OUTPUT_STATUS:
        _handleActuatorOutputStatus(message);
        break;
    default:
        break;
    }
}

void VehicleServoOutputFactGroup::_handleServoOutputRaw(mavlink_message_t& message)
{
    mavlink_servo_output_raw_t out;
    mavlink_msg_servo_output_raw_decode(&message, &out);

    uint16_t values[8] = { out.servo1_raw, out.servo2_raw, out.servo3_raw, out.servo4_raw,
                          out.servo5_raw, out.servo6_raw, out.servo7_raw, out.servo8_raw };
    int offset = out.port * 8;
    for (int i=0; i<8 && (offset + i) < 32; ++i) {
        Fact* fact = getFact(QString("servo%1").arg(offset + i + 1));
        if (fact) {
            uint16_t v = values[i];
            fact->setRawValue(v == UINT16_MAX ? qQNaN() : static_cast<float>(v));
        }
    }
    _setTelemetryAvailable(true);
}

void VehicleServoOutputFactGroup::_handleActuatorOutputStatus(mavlink_message_t& message)
{
    mavlink_actuator_output_status_t status;
    mavlink_msg_actuator_output_status_decode(&message, &status);

    for (int i=0; i<32; ++i) {
        Fact* fact = getFact(QString("servo%1").arg(i+1));
        if (fact) {
            float value = status.actuator[i];
            bool active = (status.active & (1 << i)) != 0;
            fact->setRawValue(active ? value : qQNaN());
        }
    }
    _setTelemetryAvailable(true);
}
