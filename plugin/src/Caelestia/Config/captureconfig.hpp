#pragma once

#include <qstring.h>
#include <qstringlist.h>

#include "settings/objectnode.hpp"
#include "common.hpp"

namespace caelestia::config {

using Qt::StringLiterals::operator""_s;

// Read by caelestia-cli (record/replay) as well; keep defaults in sync with utils/capture.py

class CaptureRecord : public settings::ObjectNode {
    CONFIG_NODE(CaptureRecord, settings::ObjectNode)

    // Shorter side cap in px, 0 = native; fps 0 = monitor refresh rate
    CONFIG_PROPERTY(int, resolution, 0)
    CONFIG_PROPERTY(int, fps, 0)
    // qp (constant quality), vbr or cbr (constant bitrate in kbps)
    CONFIG_PROPERTY(QString, bitrateMode, u"qp"_s)
    CONFIG_PROPERTY(QString, quality, u"very_high"_s)
    CONFIG_PROPERTY(int, bitrate, 40000)
};

class CaptureReplay : public settings::ObjectNode {
    CONFIG_NODE(CaptureReplay, settings::ObjectNode)

    CONFIG_PROPERTY(int, resolution, 0)
    CONFIG_PROPERTY(int, fps, 60)
    CONFIG_PROPERTY(QString, bitrateMode, u"cbr"_s)
    CONFIG_PROPERTY(QString, quality, u"very_high"_s)
    CONFIG_PROPERTY(int, bitrate, 15000)
    // Buffer length in seconds; storage: ram or disk
    CONFIG_PROPERTY(int, length, 60)
    CONFIG_PROPERTY(QString, storage, u"ram"_s)
    CONFIG_PROPERTY(bool, restartOnSave, false)
    // Empty = focused monitor when the buffer starts
    CONFIG_PROPERTY(QString, monitor, {})
};

class CaptureAudio : public settings::ObjectNode {
    CONFIG_NODE(CaptureAudio, settings::ObjectNode)

    CONFIG_PROPERTY(QString, codec, u"opus"_s)
    CONFIG_PROPERTY(int, bitrate, 128)
    // Extra first track mixing all others, for players that only play one
    CONFIG_PROPERTY(bool, mixTrack, true)
    // Per track: enabled, after the ChromaShell chains, recording volume (applied to the recorder's streams)
    CONFIG_PROPERTY(bool, system, true)
    CONFIG_PROPERTY(bool, systemPostFilter, false)
    CONFIG_PROPERTY(qreal, systemVolume, 1.0)
    CONFIG_PROPERTY(bool, chat, true)
    CONFIG_PROPERTY(bool, chatPostFilter, false)
    CONFIG_PROPERTY(qreal, chatVolume, 1.0)
    CONFIG_PROPERTY(bool, mic, true)
    CONFIG_PROPERTY(bool, micPostFilter, true)
    CONFIG_PROPERTY(qreal, micVolume, 1.0)
};

class CaptureAutostart : public settings::ObjectNode {
    CONFIG_NODE(CaptureAutostart, settings::ObjectNode)

    // Master switch, e.g. to pause automation during benchmarks
    CONFIG_PROPERTY(bool, enabled, true)
    CONFIG_PROPERTY(bool, onShellStart, false)
    CONFIG_PROPERTY(bool, onGameMode, false)
    // Window class regexes that start the buffer
    CONFIG_PROPERTY(QStringList, apps, {})
    CONFIG_PROPERTY(bool, stopWithApps, true)
};

class CaptureCleanup : public settings::ObjectNode {
    CONFIG_NODE(CaptureCleanup, settings::ObjectNode)

    // Applied to clips after each save; 0 = off
    CONFIG_PROPERTY(int, maxAgeDays, 0)
    CONFIG_PROPERTY(int, maxSizeGb, 0)
};

class CaptureConfig : public settings::ObjectNode {
    CONFIG_NODE(CaptureConfig, settings::ObjectNode)

    // gpu (NVENC/VA-API), vulkan (less VRAM, experimental) or cpu (H.264 only)
    CONFIG_PROPERTY(QString, encoder, u"gpu"_s)
    // Video codec from `caelestia replay codecs`, auto = recorder default (H.264 with Vulkan)
    CONFIG_PROPERTY(QString, codec, u"auto"_s)
    CONFIG_PROPERTY(QString, container, u"mkv"_s)
    CONFIG_PROPERTY(bool, cursor, true)
    CONFIG_PROPERTY(QString, framerateMode, u"vfr"_s)
    // Empty = $CAELESTIA_RECORDINGS_DIR / $CAELESTIA_CLIPS_DIR or ~/Videos/{Recordings,Clips}
    CONFIG_PROPERTY(QString, recordingsDir, {})
    CONFIG_PROPERTY(QString, clipsDir, {})
    CONFIG_PROPERTY(bool, appInFileName, true)
    CONFIG_PROPERTY(bool, clipSound, true)
    CONFIG_PROPERTY(bool, toasts, true)
    CONFIG_GLOBAL_SUBOBJECT(CaptureRecord, record)
    CONFIG_GLOBAL_SUBOBJECT(CaptureReplay, replay)
    CONFIG_GLOBAL_SUBOBJECT(CaptureAudio, audio)
    CONFIG_GLOBAL_SUBOBJECT(CaptureAutostart, autostart)
    CONFIG_GLOBAL_SUBOBJECT(CaptureCleanup, cleanup)
};

} // namespace caelestia::config
