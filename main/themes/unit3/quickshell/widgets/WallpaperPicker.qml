import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../settings"

ShellRoot {
    id: root

    // ── État partagé ──
    property bool   revealing: false
    property bool   frozen:    false
    property bool   hiding:    false
    property bool   done:      false

    // ── Wallpapers ──
    property var    wallpapers:    []
    property int    currentIndex:  0
    // Chemin générique : $HOME/Pictures/wallpapers (ou XDG_PICTURES_DIR si défini)
    property string home:          Quickshell.env("HOME")
    property string xdgConfigHome: Quickshell.env("XDG_CONFIG_HOME") || (home + "/.config")
    property string xdgPictures:   Quickshell.env("XDG_PICTURES_DIR") || (home + "/Pictures")
    property var    styles:        ["unit3", "gaming", "space", "mimimi"]
    property string activeStyle:   "unit3"
    property int    styleIndex:    0
    property string styleName:     "unit3"
    property string wallpaperDir:  xdgPictures + "/wallpapers/" + styleName
    property string activeMonitor: ""   // nom du monitor actif (où est la souris)
    property string applyBin:      "/etc/profiles/per-user/" + (Quickshell.env("USER") || "") + "/bin/wallpaper-apply"
    property bool   closeAfterApply: false

    // ── Détecter le monitor actif ──
    Process {
        id: getMonitorProc
        command: ["sh","-c","hyprctl cursorpos -j | python3 -c \"\nimport sys,json,subprocess\npos=json.load(sys.stdin)\nmons=json.loads(subprocess.check_output(['hyprctl','monitors','-j']))\nfor m in mons:\n    x,y=m['x'],m['y']\n    w,h=m['width'],m['height']\n    if x<=pos['x']<x+w and y<=pos['y']<y+h:\n        print(m['name'])\n        break\n\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var n = this.text.trim()
                if (n !== "") root.activeMonitor = n
                root.revealing = true
            }
        }
    }

    // ── Lire le style courant, puis lister ses wallpapers ──
    Process {
        id: getStyleProc
        command: ["sh","-c","cat \"" + root.xdgConfigHome + "/unit3/style\" 2>/dev/null || echo unit3"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var s = this.text.trim()
                if (s !== "") {
                    root.activeStyle = s
                    root.styleName = s
                    root.styleIndex = Math.max(0, root.styles.indexOf(s))
                }
                listWallpapers.running = true
            }
        }
    }

    Process {
        id: listWallpapers
        command: ["sh","-c","ls -- \"" + root.wallpaperDir + "\" | grep -iE '\\.(jpg|jpeg|png|webp|gif)$'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var files = this.text.trim().split("\n").filter(function(f){ return f !== "" })
                root.wallpapers = files
                root.currentIndex = 0
            }
        }
    }

    // ── Changer de dossier de style (haut/bas) sans appliquer la palette ──
    function cycleStyle(dir) {
        var i = root.styles.indexOf(root.styleName)
        if (i < 0) i = 0
        var n = root.styles.length
        root.styleName = root.styles[((i + dir) % n + n) % n]
        root.currentIndex = 0
        root.wallpapers = []
        // wallpaperDir is a binding; restart the listing process for the new dir.
        listWallpapers.running = false
        listWallpapers.command = ["sh","-c","ls -- \"" + root.wallpaperDir + "\" | grep -iE '\\.(jpg|jpeg|png|webp|gif)$'"]
        listWallpapers.running = true
    }

    // ── Appliquer le wallpaper, et le style s'il vient d'un autre dossier ──
    // The picker stays open until the helper finishes. Closing immediately
    // could kill `unit3-palette set`/`awww img` halfway through, which is what
    // left the awww daemon stuck on some (large) mimimi images.
    function applyWallpaper(idx, monitor) {
        if (root.wallpapers.length === 0) return
        var file = root.wallpaperDir + "/" + root.wallpapers[idx]
        if (root.styleName !== root.activeStyle) root.activeStyle = root.styleName
        root.closeAfterApply = true
        applyProc.command = [root.applyBin, root.styleName, file, monitor || "both"]
        applyProc.running = true
    }

    Process {
        id: applyProc
        command: ["sh","-c","echo noop"]
        running: false
        onRunningChanged: {
            if (!running && root.closeAfterApply) {
                root.closeAfterApply = false
                root.doClose()
            }
        }
    }

    // ── Gestion du curseur Hyprland ──
    // Le curseur natif Hyprland reste visible en permanence : on ne touche
    // ni à cursor:invisible avant ni à la fermeture.

    // Horloge
    property string clockFull: "--:--:--"
    Timer {
        interval:1000;running:true;repeat:true
        onTriggered:{
            var d=new Date(),p=function(x){return String(x).padStart(2,"0")}
            root.clockFull=p(d.getHours())+":"+p(d.getMinutes())+":"+p(d.getSeconds())
        }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            required property var modelData
            screen: modelData
            anchors.top:true;anchors.left:true;anchors.right:true;anchors.bottom:true
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            implicitWidth: modelData.width; implicitHeight: modelData.height
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: (root.frozen && !root.hiding && !root.done
                                          && modelData.name === root.activeMonitor)
                ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            property bool isPrimary: modelData.name === root.activeMonitor
            property bool isActive:  modelData.name === root.activeMonitor

            Timer { id: hideFadeTimer; interval:250; repeat:false
                onTriggered: { root.done = true; exitTimer.restart() }
            }
            Timer { id:exitTimer; interval:50; repeat:false
                onTriggered: Qt.quit()
            }
            Rectangle { anchors.fill:parent; color:"black"; z:10; visible:root.done }

            // ── UI — seulement sur l'écran actif ──
            Item {
                anchors.fill: parent
                visible: !root.done && isActive
                z: 2

                property real uiOp: (root.frozen || root.revealing) ? 1 : 0
                Behavior on uiOp { NumberAnimation { duration:400 } }

                // Scroll souris sur toute la surface
                MouseArea {
                    anchors.fill: parent
                    onWheel: function(e) {
                        root.navigate(e.angleDelta.y < 0 ? 1 : -1)
                    }
                }

                // Coins déco
                Item {
                    anchors{top:parent.top;left:parent.left;topMargin:28;leftMargin:30}
                    z:5; opacity:parent.uiOp
                    Column { spacing:2
                        Row { spacing:5
                            Rectangle { width:5;height:5;radius:3;color:U3Palette.accent
                                anchors.verticalCenter:parent.verticalCenter
                                SequentialAnimation on opacity { running:root.frozen; loops:Animation.Infinite
                                    NumberAnimation{to:0.3;duration:900} NumberAnimation{to:1;duration:900} }
                            }
                            Text{text:"ВЫБОР ОБОЕВ · "+root.styleName.toUpperCase();font.family:"Share Tech Mono";font.pixelSize:9;font.letterSpacing:2;color:U3Palette.ink}
                        }
                        Text{text:"УЗЕЛ · "+root.activeMonitor;font.family:"Share Tech Mono";font.pixelSize:9;font.letterSpacing:2;color:U3Palette.ink}
                    }
                }
                Item {
                    anchors{top:parent.top;right:parent.right;topMargin:28;rightMargin:30}
                    z:5; opacity:parent.uiOp
                    Text{text:root.clockFull;font.family:"Share Tech Mono";font.pixelSize:9;font.letterSpacing:2;color:U3Palette.ink}
                }
                Item {
                    anchors{bottom:parent.bottom;left:parent.left;bottomMargin:28;leftMargin:30}
                    z:5; opacity:parent.uiOp
                    Text{text:"←→ ОБОИ  ·  ↑↓ СТИЛЬ  ·  ESC — ВЫХОД";font.family:"Share Tech Mono";font.pixelSize:9;font.letterSpacing:2;color:U3Palette.ink}
                }

                // ── Boutons apply — toujours visibles ──
                Item {
                    id: applyPanel
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 60
                    width: 420
                    height: applyCol.implicitHeight + 48
                    z: 7
                    opacity: root.frozen ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration:300 } }

                    Rectangle {
                        anchors.fill: parent
                        radius: U3Palette.radius
                        color: U3Palette.paper
                        border.color: U3Palette.ink; border.width: 1

                        Repeater { model:22; Rectangle{x:index*20;y:0;width:1;height:parent.height;color:Qt.rgba(U3Palette.ink.r, U3Palette.ink.g, U3Palette.ink.b, 0.06)} }

                        Column {
                            id: applyCol
                            width: 348
                            anchors{top:parent.top;topMargin:20;horizontalCenter:parent.horizontalCenter}
                            spacing: 10

                            Text {
                                text: "ПРИМЕНИТЬ ОБОИ"
                                font.family:"Share Tech Mono";font.pixelSize:10;font.letterSpacing:3
                                color:U3Palette.ink;anchors.horizontalCenter:parent.horizontalCenter
                            }
                            Rectangle { width:parent.width;height:1;color:Qt.rgba(U3Palette.ink.r, U3Palette.ink.g, U3Palette.ink.b, 0.22) }

                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 12

                                // Bouton écran actif
                                Item { width:162; height:42
                                    Rectangle { anchors.fill:parent;radius:U3Palette.radius;color:"transparent";border.color:U3Palette.ink;border.width:1 }
                                    Rectangle { id:fill1;anchors.left:parent.left;anchors.top:parent.top;anchors.bottom:parent.bottom;color:U3Palette.ink;width:0
                                        Behavior on width{NumberAnimation{duration:220}} }
                                    Text { anchors.centerIn:parent
                                        text:"ЭТОТ ЭКРАН"
                                        font.family:"Share Tech Mono";font.pixelSize:10;font.letterSpacing:2
                                        color:ma1.containsMouse?U3Palette.paper:U3Palette.ink
                                        Behavior on color{ColorAnimation{duration:200}} }
                                    MouseArea { id:ma1;anchors.fill:parent;hoverEnabled:true
                                        onEntered:fill1.width=parent.width;onExited:fill1.width=0
                                        onClicked:{ root.applyWallpaper(root.currentIndex, root.activeMonitor) } }
                                }

                                // Bouton les deux écrans
                                Item { width:162; height:42
                                    Rectangle { anchors.fill:parent;radius:U3Palette.radius;color:"transparent";border.color:U3Palette.ink;border.width:1 }
                                    Rectangle { id:fill2;anchors.left:parent.left;anchors.top:parent.top;anchors.bottom:parent.bottom;color:U3Palette.ink;width:0
                                        Behavior on width{NumberAnimation{duration:220}} }
                                    Text { anchors.centerIn:parent
                                        text:"ВСЕ ЭКРАНЫ"
                                        font.family:"Share Tech Mono";font.pixelSize:10;font.letterSpacing:2
                                        color:ma2.containsMouse?U3Palette.paper:U3Palette.ink
                                        Behavior on color{ColorAnimation{duration:200}} }
                                    MouseArea { id:ma2;anchors.fill:parent;hoverEnabled:true
                                        onEntered:fill2.width=parent.width;onExited:fill2.width=0
                                        onClicked:{ root.applyWallpaper(root.currentIndex, "both") } }
                                }
                            }
                        }
                    }
                }

                // ── Carrousel ──
                // ── Carrousel ──
                Item {
                    id: carousel
                    anchors.top: parent.top
                    anchors.topMargin: 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: parent.height - 220
                    z: 6
                    opacity: root.frozen ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration:300 } }

                    focus: root.frozen && isActive
                    Keys.onEscapePressed: root.doClose()
                    Keys.onLeftPressed:   root.navigate(-1)
                    Keys.onRightPressed:  root.navigate(1)
                    Keys.onUpPressed:     root.cycleStyle(-1)
                    Keys.onDownPressed:   root.cycleStyle(1)
                    Keys.onReturnPressed:  { root.applyWallpaper(root.currentIndex, "both") }
                    Keys.onSpacePressed:  { root.applyWallpaper(root.currentIndex, "both") }
                    readonly property int n: root.wallpapers.length

                    // Dimensions de base (taille de la vignette centrale à pleine échelle)
                    readonly property int baseW: 800
                    readonly property int baseH: 500
                    // Ligne de base commune : toutes les vignettes ont leur bas aligné ici
                    readonly property int baselineY: height / 2 + baseH / 2

                    // Échelles par distance (slot) au centre
                    readonly property real scaleCenter: 1.0
                    readonly property real scaleNear:   0.54   // ~280/520
                    readonly property real scaleFar:    0.35   // ~180/520

                    // Espacements X (demi-axes entre centres de vignettes) par slot
                    readonly property int offsetNear: 280
                    readonly property int offsetFar:  576

                    // Une vignette par wallpaper. Chaque vignette choisit sa place
                    // en fonction de l'offset signé vers currentIndex (chemin le plus
                    // court sur la boucle). Position, scale et opacity sont animées
                    // -> le zoom est smooth et part du bas (transformOrigin: Bottom).
                    Repeater {
                        model: root.wallpapers

                        Item {
                            id: thumb
                            property int wIdx: index
                            // Offset signé (-n/2 .. n/2) = chemin le plus court vers currentIndex
                            property int rawDelta: carousel.n > 0 ? (wIdx - root.currentIndex) : 0
                            property int delta: {
                                if (carousel.n === 0) return 0
                                var d = rawDelta
                                var half = carousel.n / 2
                                if (d >  half) d -= carousel.n
                                if (d < -half) d += carousel.n
                                return d
                            }
                            property int absDelta: Math.abs(delta)

                            // Position X et échelle dérivées du slot
                            property real targetScale:
                                  absDelta === 0 ? carousel.scaleCenter
                                : absDelta === 1 ? carousel.scaleNear
                                :                  carousel.scaleFar
                            property real targetOpacity:
                                  absDelta === 0 ? 1.0
                                : absDelta === 1 ? 0.65
                                : absDelta === 2 ? 0.3
                                :                  0.0
                            property int targetOffsetX:
                                  absDelta === 0 ? 0
                                : absDelta === 1 ? (delta > 0 ?  carousel.offsetNear : -carousel.offsetNear)
                                :                  (delta > 0 ?  carousel.offsetFar  : -carousel.offsetFar)

                            width: carousel.baseW
                            height: carousel.baseH
                            x: carousel.width/2 + targetOffsetX - carousel.baseW/2
                            y: carousel.baselineY - carousel.baseH
                            scale: targetScale
                            opacity: targetOpacity
                            z: absDelta === 0 ? 10 : (3 - absDelta)
                            visible: absDelta <= 2
                            transformOrigin: Item.Bottom

                            // Animations fluides — le scale part du bas grâce au transformOrigin
                            Behavior on x       { NumberAnimation { duration:320; easing.type:Easing.OutCubic } }
                            Behavior on scale   { NumberAnimation { duration:320; easing.type:Easing.OutCubic } }
                            Behavior on opacity { NumberAnimation { duration:320; easing.type:Easing.OutCubic } }

                            Rectangle {
                                anchors.fill: parent
                                radius: U3Palette.radius
                                color: U3Palette.black
                                border.color: thumb.absDelta === 0 ? U3Palette.inkSoft : U3Palette.ink
                                border.width: thumb.absDelta === 0 ? 2 : 1
                                Behavior on border.color { ColorAnimation { duration:260 } }

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: "file://" + encodeURI(root.wallpaperDir + "/" + root.wallpapers[thumb.wIdx])
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                }

                                // Bandeau avec le nom, visible seulement sur la vignette centrale
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 24
                                    color: Qt.rgba(U3Palette.black.r, U3Palette.black.g, U3Palette.black.b, 0.6)
                                    opacity: thumb.absDelta === 0 ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration:200 } }
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.wallpapers[thumb.wIdx]
                                        font.family: "Share Tech Mono"
                                        font.pixelSize: 8
                                        color: U3Palette.inkSoft
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                // Clic sur une voisine -> on navigue vers elle
                                onClicked: if (thumb.delta !== 0) root.navigate(thumb.delta)
                                onWheel: function(e) { root.navigate(e.angleDelta.y < 0 ? 1 : -1) }
                            }
                        }
                    }
                }
            }

            // ── Connexions état ──
            Connections {
                target: root
                function onRevealingChanged() {
                    if (root.revealing) {
                        root.frozen = true
                        panelOpenTimer.restart()
                    }
                }
                function onHidingChanged() {
                    if (root.hiding) {
                        if (isPrimary) hideFadeTimer.restart()
                    }
                }
            }
            Timer { id:panelOpenTimer; interval:100; repeat:false; onTriggered: carousel.focus=true }
        }
    }

    // ── Navigation ──
    function navigate(dir) {
        var n = root.wallpapers.length
        if (n === 0) return
        root.currentIndex = ((root.currentIndex + dir) % n + n) % n
    }

    function doClose() {
        root.hiding = true
    }
}
