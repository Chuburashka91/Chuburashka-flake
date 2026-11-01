pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Runtime palette for the Quickshell surfaces that opt in (ControlCenter and
// Help). The switcher writes ~/.config/unit3/{style,active/qml.json}; the
// style file is watched so a palette change reloads the JSON.
Item {
    id: root
    visible: false

    readonly property string home: Quickshell.env("HOME") || ""
    property var paletteData: ({})

    readonly property color paper: paletteData.paper || "#d6cfb5"
    readonly property color paper2: paletteData.paper2 || "#cbc4a9"
    readonly property color paper3: paletteData.paper3 || "#c2baa0"
    readonly property color paper4: paletteData.paper4 || "#b9b096"
    readonly property color paperLight: paletteData.paperLight || "#ded7bf"
    readonly property color selectionText: paletteData.selectionText || "#f5f0e6"
    readonly property color overlay: paletteData.overlay || Qt.rgba(184/255, 175/255, 147/255, 0.55)

    readonly property color ink: paletteData.ink || "#463f2e"
    readonly property color inkStrong: paletteData.inkStrong || "#2e2a1f"
    readonly property color inkSoft: paletteData.inkSoft || "#7a7358"
    readonly property color inkMuted: paletteData.inkMuted || "#9a9278"

    readonly property color accent: paletteData.accent || "#6e2a2a"
    readonly property color accentSoft: paletteData.accentSoft || "#8a3a3a"
    readonly property color green: paletteData.green || "#4f7a5a"
    readonly property color gold: paletteData.gold || "#a07a2a"
    readonly property color danger: paletteData.danger || "#8a3a3a"
    readonly property color black: paletteData.black || "#000000"

    readonly property color lineSoft: Qt.rgba(ink.r, ink.g, ink.b, 0.25)
    readonly property color lineVsoft: Qt.rgba(ink.r, ink.g, ink.b, 0.12)

    readonly property int radius: paletteData.radius !== undefined ? paletteData.radius : 0
    readonly property int buttonRadius: paletteData.buttonRadius !== undefined ? paletteData.buttonRadius : 0

    readonly property string name: paletteData.name || "unit3"
    readonly property string label: paletteData.label || "Unit-3"

    function load() {
        try {
            root.paletteData = JSON.parse(paletteFile.text())
        } catch (e) {
            root.paletteData = ({})
        }
    }

    Component.onCompleted: load()

    FileView {
        id: styleWatch
        path: root.home + "/.config/unit3/style"
        watchChanges: true
        onFileChanged: paletteFile.reload()
    }

    FileView {
        id: paletteFile
        path: root.home + "/.config/unit3/active/qml.json"
        preload: true
        blockLoading: true
        watchChanges: true
        onLoaded: root.load()
        onFileChanged: root.load()
    }
}
