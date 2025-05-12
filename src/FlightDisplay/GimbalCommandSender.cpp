// GimbalCommandSender.cpp
#include "GimbalCommandSender.h"
#include <QDebug>
#include <QtEndian>
#include <QTimer>
#include "TemplateManager.h"
#include "QGCApplication.h"

GimbalCommandSender::GimbalCommandSender(QObject *parent)
    : QObject(parent),
    udpSocket(new QUdpSocket(this)),
    gimbalIp(QHostAddress("192.168.144.25")),
    gimbalPort(37260)
{
    udpSocket->bind(QHostAddress::AnyIPv4, 15000);
    connect(udpSocket, &QUdpSocket::readyRead, this, &GimbalCommandSender::onReadyRead);
}

double GimbalCommandSender::pitchCamAngle() const {
    return _pitchCamAngle;
}

bool GimbalCommandSender::gimbalCommandInProgress() const {
    return _gimbalCommandInProgress;
}

bool GimbalCommandSender::cameraCommandInProgress() const {
    return _cameraCommandInProgress;
}

int GimbalCommandSender::gimbalMode() const {
    return _gimbalMode;
}

void GimbalCommandSender::setGimbalCommandInProgress(bool inProgress) {
    if (_gimbalCommandInProgress != inProgress) {
        _gimbalCommandInProgress = inProgress;
        emit gimbalCommandInProgressChanged();
    }
}

void GimbalCommandSender::setCameraCommandInProgress(bool inProgress) {
    if (_cameraCommandInProgress != inProgress) {
        _cameraCommandInProgress = inProgress;
        emit cameraCommandInProgressChanged();
    }
}

void GimbalCommandSender::setGimbalMode(int mode) {
    if (_gimbalMode != mode) {
        _gimbalMode = mode;
        emit gimbalModeChanged();
    }
}

void GimbalCommandSender::sendCommand(const QByteArray& raw)
{
    udpSocket->writeDatagram(raw, gimbalIp, gimbalPort);
}

void GimbalCommandSender::sendPitchDown()
{
    QByteArray raw = QByteArray::fromHex("556601040000000e0000ffa6");
    quint16 crc = crc16(raw);
    raw.append(static_cast<char>((crc >> 8) & 0xFF));
    raw.append(static_cast<char>(crc & 0xFF));
    qDebug() << "[SEND] Pitch -90°:" << raw.toHex(' ').toUpper();
    sendCommand(raw);
}

void GimbalCommandSender::changeColorSchema()
{
    qgcApp()->toolbox()->templateManager()->sendActionPacket("color_scheme");
}

void GimbalCommandSender::sendPitchCenter()
{
    QByteArray raw = QByteArray::fromHex("556601010000000801D112");
    qDebug() << "[SEND] Gimbal Center:" << raw.toHex(' ').toUpper();
    sendCommand(raw);
}

void GimbalCommandSender::sendRebootCamera()
{
    QByteArray raw = QByteArray::fromHex("55660102000000800100");
    quint16 crc = crc16(raw);
    raw.append(static_cast<char>((crc >> 8) & 0xFF));
    raw.append(static_cast<char>(crc & 0xFF));
    qDebug() << "[SEND] Reboot Camera:" << raw.toHex(' ').toUpper();
    setCameraCommandInProgress(true);
    sendCommand(raw);
    QTimer::singleShot(10000, this, [this]() { setCameraCommandInProgress(false); });
}

void GimbalCommandSender::sendRebootGimbal()
{
    QByteArray raw = QByteArray::fromHex("55660102000000800001");
    quint16 crc = crc16(raw);
    raw.append(static_cast<char>((crc >> 8) & 0xFF));
    raw.append(static_cast<char>(crc & 0xFF));
    qDebug() << "[SEND] Reboot Gimbal:" << raw.toHex(' ').toUpper();
    setGimbalCommandInProgress(true);
    sendCommand(raw);
    QTimer::singleShot(10000, this, [this]() { setGimbalCommandInProgress(false); });
}

void GimbalCommandSender::activateFPVMode()
{
    QByteArray raw = QByteArray::fromHex("556601010000000c05");
    quint16 crc = crc16(raw);
    raw.append(static_cast<char>((crc >> 8) & 0xFF));
    raw.append(static_cast<char>(crc & 0xFF));
    qDebug() << "[SEND] Set FPV Mode:" << raw.toHex(' ').toUpper();
    sendCommand(raw);

    QTimer::singleShot(1000, this, &GimbalCommandSender::requestGimbalMode);
}

void GimbalCommandSender::activateAimMode()
{
    QByteArray raw = QByteArray::fromHex("556601010000000c04");
    quint16 crc = crc16(raw);
    raw.append(static_cast<char>((crc >> 8) & 0xFF));
    raw.append(static_cast<char>(crc & 0xFF));
    qDebug() << "[SEND] Set Follow Mode:" << raw.toHex(' ').toUpper();
    sendCommand(raw);

    QTimer::singleShot(1000, this, &GimbalCommandSender::requestGimbalMode);
}

void GimbalCommandSender::requestGimbalMode()
{
    QByteArray raw = QByteArray::fromHex("55660100000000195D57");
    qDebug() << "[SEND] Request Gimbal Mode:" << raw.toHex(' ').toUpper();
    sendCommand(raw);
}

void GimbalCommandSender::onReadyRead()
{
    while (udpSocket->hasPendingDatagrams()) {
        QByteArray datagram;
        datagram.resize(int(udpSocket->pendingDatagramSize()));
        udpSocket->readDatagram(datagram.data(), datagram.size());

        qDebug() << "[RECV] Raw:" << datagram.toHex(' ').toUpper();

        if (datagram.size() > 7) {
            quint8 cmdId = quint8(datagram.at(7));
            qDebug() << "[RECV] CMD_ID:" << QString("0x%1").arg(cmdId, 2, 16, QLatin1Char('0')).toUpper();

            if (cmdId == 0x19 && datagram.size() >= 9) {
                quint8 mode = quint8(datagram.at(8));
                qDebug() << "[GIMBAL MODE - CMD 0x19] Mode:" << mode;
                setGimbalMode(mode);
            }
        }
    }
}

quint16 GimbalCommandSender::crc16(const QByteArray& command)
{
    const quint8* data = reinterpret_cast<const quint8*>(command.constData());
    int length = command.length();
    uint16_t crc = 0x0000;

    while (length-- > 0) {
        uint8_t temp = (crc >> 8) & 0xFF;
        crc = (crc << 8) ^ crc16_tab[(*data++) ^ temp];
    }

    return (crc >> 8) | (crc << 8);
}

const uint16_t GimbalCommandSender::crc16_tab[256] = {
    0x0,0x1021,0x2042,0x3063,0x4084,0x50a5,0x60c6,0x70e7,
    0x8108,0x9129,0xa14a,0xb16b,0xc18c,0xd1ad,0xe1ce,0xf1ef,
    0x1231,0x210,0x3273,0x2252,0x52b5,0x4294,0x72f7,0x62d6,
    0x9339,0x8318,0xb37b,0xa35a,0xd3bd,0xc39c,0xf3ff,0xe3de,
    0x2462,0x3443,0x420,0x1401,0x64e6,0x74c7,0x44a4,0x5485,
    0xa56a,0xb54b,0x8528,0x9509,0xe5ee,0xf5cf,0xc5ac,0xd58d,
    0x3653,0x2672,0x1611,0x630,0x76d7,0x66f6,0x5695,0x46b4,
    0xb75b,0xa77a,0x9719,0x8738,0xf7df,0xe7fe,0xd79d,0xc7bc,
    0x48c4,0x58e5,0x6886,0x78a7,0x840,0x1861,0x2802,0x3823,
    0xc9cc,0xd9ed,0xe98e,0xf9af,0x8948,0x9969,0xa90a,0xb92b,
    0x5af5,0x4ad4,0x7ab7,0x6a96,0x1a71,0xa50,0x3a33,0x2a12,
    0xdbfd,0xcbdc,0xfbbf,0xeb9e,0x9b79,0x8b58,0xbb3b,0xab1a,
    0x6ca6,0x7c87,0x4ce4,0x5cc5,0x2c22,0x3c03,0xc60,0x1c41,
    0xedae,0xfd8f,0xcdec,0xddcd,0xad2a,0xbd0b,0x8d68,0x9d49,
    0x7e97,0x6eb6,0x5ed5,0x4ef4,0x3e13,0x2e32,0x1e51,0xe70,
    0xff9f,0xefbe,0xdfdd,0xcffc,0xbf1b,0xaf3a,0x9f59,0x8f78,
    0x9188,0x81a9,0xb1ca,0xa1eb,0xd10c,0xc12d,0xf14e,0xe16f,
    0x1080,0xa1,0x30c2,0x20e3,0x5004,0x4025,0x7046,0x6067,
    0x83b9,0x9398,0xa3fb,0xb3da,0xc33d,0xd31c,0xe37f,0xf35e,
    0x2b1,0x1290,0x22f3,0x32d2,0x4235,0x5214,0x6277,0x7256,
    0xb5ea,0xa5cb,0x95a8,0x8589,0xf56e,0xe54f,0xd52c,0xc50d,
    0x34e2,0x24c3,0x14a0,0x481,0x7466,0x6447,0x5424,0x4405,
    0xa7db,0xb7fa,0x8799,0x97b8,0xe75f,0xe7fe,0xd79d,0xc7bc,
    0x26d3,0x36f2,0x691,0x16b0,0x6657,0x7676,0x4615,0x5634,
    0xd94c,0xc96d,0xf90e,0xe92f,0x99c8,0x89e9,0xb98a,0xa9ab,
    0x5844,0x4865,0x7806,0x6827,0x18c0,0x8e1,0x3882,0x28a3,
    0xcb7d,0xdb5c,0xeb3f,0xfb1e,0x8bf9,0x9bd8,0xabbb,0xbb9a,
    0x4a75,0x5a54,0x6a37,0x7a16,0xaf1,0x1ad0,0x2ab3,0x3a92,
    0xfd2e,0xed0f,0xdd6c,0xcd4d,0xbdaa,0xad8b,0x9de8,0x8dc9,
    0x7c26,0x6c07,0x5c64,0x4c45,0x3ca2,0x2c83,0x1ce0,0xcc1,
    0xef1f,0xff3e,0xcf5d,0xdf7c,0xaf9b,0xbfba,0x8fd9,0x9ff8,
    0x6e17,0x7e36,0x4e55,0x5e74,0x2e93,0x3eb2,0xed1,0x1ef0
};
