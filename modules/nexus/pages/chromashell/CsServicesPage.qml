import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components.controls
import qs.modules.nexus.common

PageBase {
    id: root

    // Lyrics backends, ordered to match LyricsBackend::Backend (Auto, Local, LRCLIB, NetEase)
    readonly property list<MenuItem> lyricsItems: [
        MenuItem {
            text: "Auto"
        },
        MenuItem {
            text: "Local"
        },
        MenuItem {
            text: "LRCLIB"
        },
        MenuItem {
            text: "NetEase"
        }
    ]

    // GPU options + the config string each maps to (see Gpu::parseType)
    readonly property list<MenuItem> gpuItems: [
        MenuItem {
            text: qsTr("Auto")
        },
        MenuItem {
            text: "NVIDIA"
        },
        MenuItem {
            text: qsTr("Generic")
        },
        MenuItem {
            text: qsTr("None")
        }
    ]
    readonly property list<string> gpuValues: ["", "NVIDIA", "GENERIC", "None"]

    function gpuKeyToIndex(key: string): int {
        const u = (key ?? "").trim().toUpperCase();
        if (u === "")
            return 0; // Auto
        if (u === "NVIDIA")
            return 1;
        if (u === "GENERIC")
            return 2;
        return 3; // None
    }

    title: qsTr("Services")
    isSubPage: true

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: root.cappedWidth
        spacing: Tokens.spacing.extraSmall / 2

        SectionHeader {
            first: true
            text: qsTr("Weather & units")
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Weather location")
            subtext: qsTr("City name or lat,long — empty for auto detection")
            value: GlobalConfig.services.weatherLocation
            onEdited: v => GlobalConfig.services.weatherLocation = v
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Fahrenheit")
            subtext: qsTr("Use Fahrenheit for weather temperatures")
            checked: GlobalConfig.services.useFahrenheit
            onToggled: GlobalConfig.services.useFahrenheit = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            text: qsTr("Fahrenheit for performance")
            subtext: qsTr("Use Fahrenheit for CPU/GPU temperatures")
            checked: GlobalConfig.services.useFahrenheitPerformance
            onToggled: GlobalConfig.services.useFahrenheitPerformance = checked
        }

        ToggleRow {
            Layout.fillWidth: true
            last: true
            text: qsTr("12-hour clock")
            subtext: qsTr("Use a 12-hour clock format")
            checked: GlobalConfig.services.useTwelveHourClock
            onToggled: GlobalConfig.services.useTwelveHourClock = checked
        }

        SectionHeader {
            text: qsTr("Theming & visuals")
        }

        ToggleRow {
            Layout.fillWidth: true
            first: true
            text: qsTr("Smart colour scheme")
            subtext: qsTr("Derive theme mode and variant from the wallpaper")
            checked: GlobalConfig.services.smartScheme
            onToggled: GlobalConfig.services.smartScheme = checked
        }

        SelectRow {
            Layout.fillWidth: true
            label: qsTr("GPU")
            subtext: qsTr("Override for GPU type")
            menuItems: root.gpuItems
            active: root.gpuItems[root.gpuKeyToIndex(GlobalConfig.services.gpuType)]
            onSelected: item => GlobalConfig.services.gpuType = root.gpuValues[root.gpuItems.indexOf(item)]
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Visualiser bars")
            subtext: qsTr("Number of bars in the audio visualisers")
            value: GlobalConfig.services.visualiserBars
            from: 10
            to: 120
            stepSize: 2
            onMoved: v => GlobalConfig.services.visualiserBars = Math.round(v)
        }

        SectionHeader {
            text: qsTr("Audio & brightness")
        }

        StepperRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Volume step")
            subtext: qsTr("Fraction the volume changes per scroll")
            value: GlobalConfig.services.audioIncrement
            from: 0.01
            to: 0.5
            stepSize: 0.01
            onMoved: v => GlobalConfig.services.audioIncrement = v
        }

        StepperRow {
            Layout.fillWidth: true
            label: qsTr("Brightness step")
            subtext: qsTr("Fraction the brightness changes per scroll")
            value: GlobalConfig.services.brightnessIncrement
            from: 0.01
            to: 0.5
            stepSize: 0.01
            onMoved: v => GlobalConfig.services.brightnessIncrement = v
        }

        StepperRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Max volume")
            subtext: qsTr("Upper limit for output volume (1.0 = 100%)")
            value: GlobalConfig.services.maxVolume
            from: 0.5
            to: 2
            stepSize: 0.05
            onMoved: v => GlobalConfig.services.maxVolume = v
        }

        SectionHeader {
            text: qsTr("Media")
        }

        CsTextFieldRow {
            Layout.fillWidth: true
            first: true
            label: qsTr("Default player")
            subtext: qsTr("Preferred media player when several are open")
            value: GlobalConfig.services.defaultPlayer
            onEdited: v => GlobalConfig.services.defaultPlayer = v
        }

        SelectRow {
            Layout.fillWidth: true
            label: qsTr("Lyrics backend")
            subtext: qsTr("Source used to fetch synced lyrics")
            menuItems: root.lyricsItems
            active: root.lyricsItems.find(i => i.text === GlobalConfig.services.lyricsBackend) ?? root.lyricsItems[0]
            onSelected: item => GlobalConfig.services.lyricsBackend = item.text
        }

        CsObjectListRow {
            Layout.fillWidth: true
            label: qsTr("Player aliases")
            subtext: qsTr("Rename players for display")
            values: GlobalConfig.services.playerAliases
            titleKey: "to"
            defaultEntry: ({
                    from: "",
                    to: ""
                })
            fields: [
                {
                    key: "from",
                    label: qsTr("From (identity)"),
                    type: "string"
                },
                {
                    key: "to",
                    label: qsTr("To (display name)"),
                    type: "string"
                }
            ]
            onEdited: v => GlobalConfig.services.playerAliases = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            label: qsTr("Cassette video players")
            subtext: qsTr("Player identities that force the cassette into video mode")
            values: GlobalConfig.services.cassetteVideoPlayers
            onEdited: v => GlobalConfig.services.cassetteVideoPlayers = v
        }

        CsStringListRow {
            Layout.fillWidth: true
            last: true
            label: qsTr("Cassette audio players")
            subtext: qsTr("Player identities that force the cassette into audio mode")
            values: GlobalConfig.services.cassetteAudioPlayers
            onEdited: v => GlobalConfig.services.cassetteAudioPlayers = v
        }
    }
}
