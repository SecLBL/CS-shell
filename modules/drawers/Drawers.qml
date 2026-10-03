pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services

Variants {
    model: Screens.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        Exclusions {
            screen: scope.modelData
            bar: content.bar
        }

        ContentWindow {
            id: content

            screen: scope.modelData
        }

        GameBar {
            screen: scope.modelData
            visible: GameMode.slimShell
            implicitWidth: content.bar.exclusiveZone
        }

        GameLauncher {
            screen: scope.modelData
            screenState: content.screenState
        }
    }
}
