#include "GimbalCommandSender.h"
#include <QDebug>
#include <QtEndian>

GimbalCommandSender::GimbalCommandSender(QObject *parent)
    : QObject(parent),
    udpSocket(new QUdpSocket(this)),
    gimbalIp(QHostAddress("192.168.144.25")),
    gimbalPort(37260)
{
    udpSocket->bind(QHostAddress::AnyIPv4, 15000);
    connect(udpSocket, &QUdpSocket::readyRead, this, &GimbalCommandSender::onReadyRead);

    connect(&updateTimer, &QTimer::timeout, this, &GimbalCommandSender::onUpdateTimerTimeout);
    updateTimer.setInterval(1000); // 1 секунда
    updateTimer.start();
    qDebug() << "[TIMER] Auto update started on creation.";
}

double GimbalCommandSender::pitchCamAngle() const {
    return _pitchCamAngle;
}

void GimbalCommandSender::sendPitchDown()
{
    QByteArray raw = QByteArray::fromHex("556601040000000e0000ffa6");
    quint16 crc = crc16(raw);
    raw.append(static_cast<char>((crc >> 8) & 0xFF));
    raw.append(static_cast<char>(crc & 0xFF));
    //qDebug() << Qt::hex << raw.toHex();
    qDebug() << "[SEND] Pitch -90°:" << raw.toHex(' ').toUpper();
    udpSocket->writeDatagram(raw, gimbalIp, gimbalPort);
}

void GimbalCommandSender::sendPitchCenter()
{
    QByteArray raw = QByteArray::fromHex("556601010000000801D112");
    qDebug() << "[SEND] Gimbal Center:" << raw.toHex(' ').toUpper();
    udpSocket->writeDatagram(raw, gimbalIp, gimbalPort);
}

void GimbalCommandSender::sendReadPositionCommand()
{
    QByteArray raw = QByteArray::fromHex("556601000000000DE805");
    qDebug() << "[SEND] Request Gimbal Position:" << raw.toHex(' ').toUpper();
    udpSocket->writeDatagram(raw, gimbalIp, gimbalPort);
}

void GimbalCommandSender::startAutoUpdate()
{
    if (!updateTimer.isActive()) {
        updateTimer.start();
        qDebug() << "[TIMER] Auto update started.";
    }
}

void GimbalCommandSender::stopAutoUpdate()
{
    if (updateTimer.isActive()) {
        updateTimer.stop();
        qDebug() << "[TIMER] Auto update stopped.";
    }
}

void GimbalCommandSender::onUpdateTimerTimeout()
{
    sendReadPositionCommand();
}

void GimbalCommandSender::sendRebootCamera()
{
    QByteArray raw = QByteArray::fromHex("55660102000000800100");
    quint16 crc = crc16(raw);
    raw.append(static_cast<char>((crc >> 8) & 0xFF));
    raw.append(static_cast<char>(crc & 0xFF));
    qDebug() << "[SEND] Reboot Camera:" << raw.toHex(' ').toUpper();
    udpSocket->writeDatagram(raw, gimbalIp, gimbalPort);
}

void GimbalCommandSender::sendRebootGimbal()
{
    QByteArray raw = QByteArray::fromHex("55660102000000800001");
    quint16 crc = crc16(raw);
    raw.append(static_cast<char>((crc >> 8) & 0xFF));
    raw.append(static_cast<char>(crc & 0xFF));
    qDebug() << "[SEND] Reboot Gimbal:" << raw.toHex(' ').toUpper();
    udpSocket->writeDatagram(raw, gimbalIp, gimbalPort);
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

            // Обробка відповіді на запит положення гімбала (CMD_ID = 0x0D)
            if (cmdId == 0x0D && datagram.size() >= 21) {
                const uchar* data = reinterpret_cast<const uchar*>(datagram.constData() + 8);

                int16_t yaw   = qFromLittleEndian<int16_t>(data + 0);
                int16_t pitch = qFromLittleEndian<int16_t>(data + 2);
                int16_t roll  = qFromLittleEndian<int16_t>(data + 4);

                double newPitch = pitch / 10.0;

                if (!qFuzzyCompare(_pitchCamAngle, newPitch)) {
                    _pitchCamAngle = newPitch;
                    emit pitchCamAngleChanged();
                }

                qDebug() << "[GIMBAL POS - CMD 0x0D]"
                         << "Pitch:" << newPitch << "°"
                         << "Yaw:" << yaw / 10.0 << "°"
                         << "Roll:" << roll / 10.0 << "°";
            }
        }
    }
}

quint16 GimbalCommandSender::crc16(const QByteArray& command)
{
    int length = command.length();
    quint8* data = new quint8[length];
    quint8* original_data = data;

    memcpy(data, command.constData(), length);

    uint16_t crc, oldcrc16;
    uint8_t temp;

    crc = 0x0;

    // Копируем данные
    while (length-- != 0)
    {
        temp = (crc >> 8) & 0xff;
        oldcrc16 = crc16_tab[*data ^ temp];
        crc = (crc << 8) ^ oldcrc16;
        data++;
    }
    //crc=~crc; //??
    delete[] original_data;
    return(crc >> 8) | (crc << 8);
}
