/****************************************************************************
 *
 * (c) 2009-2024 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

#pragma once

#include <QObject>
#include <QTimer>

#include "MAVLinkProtocol.h"
#include "QGCMAVLink.h"
#include "LinkInterface.h"
#include "QGCLoggingCategory.h"
#include "Settings/SettingsManager.h"
#include "VideoSettings.h"

Q_DECLARE_LOGGING_CATEGORY(VideoStreamControlLog)

class VideoStreamControl : public QObject
{
    Q_OBJECT
public:
    VideoStreamControl();
    ~VideoStreamControl() override = default;

    Q_PROPERTY(bool settingInProgress READ settingInProgress NOTIFY settingInProgressChanged)
    bool settingInProgress() const { return _settingInProgress; }

signals:
    void settingInProgressChanged();
    void videoNeedsReset();

private slots:
    void _mavlinkMessageReceived(LinkInterface* link, mavlink_message_t message);
    void _settingInProgressTimeout();
    void _cameraIdChanged();

private:
    void _handleHeartbeatInfo(LinkInterface* link, mavlink_message_t& message);
    void _setCameraId();
    void _setCameraIdLockUi(bool lockUi);
    void _startVideoStreaming();
    void _setSettingInProgress(bool inProgress);

    int                 _systemId               = -1;
    LinkInterface*      _linkInterface          = nullptr;
    MAVLinkProtocol*    _mavlinkProtocol        = nullptr;
    VideoSettings*      _videoSettings          = nullptr;
    QTimer              _settingInProgressTimer;
    uint32_t            _cameraServiceUid       = 0;
    uint32_t            _cameraCount            = 0;
    uint32_t            _cameraIdSetting        = 0;
    bool                _settingInProgress      = false;
};
