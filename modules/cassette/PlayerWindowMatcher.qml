pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Mpris
import Caelestia.Config
import qs.services

// Detects whether the active MPRIS player is playing video (heuristic) and
// matches it to a Hyprland toplevel whose window can be captured.
Item {
    id: root

    property MprisPlayer player: Players.active

    // Bumped periodically so toplevel-title-only changes re-trigger the bindings
    property int revision: 0

    readonly property list<string> videoExtensions: ["mkv", "mp4", "webm", "avi", "mov", "m4v", "wmv", "flv", "ts", "mpg", "mpeg"]

    readonly property bool forcedVideo: identityIn(GlobalConfig.services.cassetteVideoPlayers)
    readonly property bool forcedAudio: identityIn(GlobalConfig.services.cassetteAudioPlayers)
    readonly property bool wantsVideo: !forcedAudio && (forcedVideo || urlIsVideo())

    // URL-heuristic matches (browsers) additionally require a title match,
    // since the class alone can't distinguish browser windows
    readonly property var toplevel: {
        revision;
        return wantsVideo ? findToplevel(!forcedVideo) : null;
    }
    readonly property bool videoMode: wantsVideo && toplevel !== null

    function identityIn(list: var): bool {
        const id = (player?.identity ?? "").toLowerCase();
        const de = (player?.desktopEntry ?? "").toLowerCase();
        return (list ?? []).some(e => {
            const s = String(e).toLowerCase();
            return (id && (id.includes(s) || s.includes(id))) || (de && (de.includes(s) || s.includes(de)));
        });
    }

    function urlIsVideo(): bool {
        const url = String(player?.metadata["xesam:url"] ?? "").toLowerCase();
        if (!url)
            return false;
        if (url.includes("music.youtube.com"))
            return false;
        if (url.includes("youtube.com/watch") || url.includes("youtu.be/"))
            return true;
        const ext = url.split(/[?#]/)[0].split(".").pop();
        return videoExtensions.includes(ext);
    }

    function findToplevel(requireTitle: bool): var {
        if (!player)
            return null;
        const names = [player.identity, player.desktopEntry].filter(s => !!s).map(s => s.toLowerCase());
        const title = (player.trackTitle ?? "").toLowerCase();
        const titleOk = t => title.length > 3 && (t.title ?? "").toLowerCase().includes(title);
        const classOk = t => {
            const cls = (t.lastIpcObject?.class ?? "").toLowerCase();
            const icls = (t.lastIpcObject?.initialClass ?? "").toLowerCase();
            return names.some(n => (cls && (cls.includes(n) || n.includes(cls))) || (icls && icls.includes(n)));
        };
        const candidates = Hypr.toplevels.values.filter(t => requireTitle ? (classOk(t) && titleOk(t)) : (classOk(t) || titleOk(t)));
        return candidates.find(titleOk) ?? candidates[0] ?? null;
    }

    Timer {
        interval: 2000
        repeat: true
        running: root.wantsVideo
        onTriggered: root.revision++
    }
}
