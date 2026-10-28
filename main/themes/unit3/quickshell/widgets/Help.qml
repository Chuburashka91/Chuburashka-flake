import QtQuick

Item {
    id: root

    readonly property int lw: 1200
    readonly property int lh: 620
    property real screenW: 1920
    property real screenH: 1080

    property bool helpOpen: false

    implicitWidth: screenW
    implicitHeight: screenH

    // Palette — как в Menu.qml
    readonly property color paper:     "#d6cfb5"
    readonly property color ink:       "#463f2e"
    readonly property color inkStrong: "#2e2a1f"
    readonly property color inkSoft:   "#7a7358"
    readonly property color lineSoft:  Qt.rgba(70/255,63/255,46/255,0.25)
    readonly property color lineVsoft: Qt.rgba(70/255,63/255,46/255,0.12)
    readonly property color accent:    "#6e2a2a"

    readonly property var leftSections: [
        {
            title: "ЗАПУСК",
            items: [
                { keys: "SUPER + T", desc: "Терминал" },
                { keys: "SUPER + Enter", desc: "Терминал" },
                { keys: "SUPER + D", desc: "Лаунчер" },
                { keys: "SUPER + E", desc: "Файлы" },
                { keys: "SUPER + B", desc: "Браузер" },
                { keys: "SUPER + P", desc: "Обои" },
                { keys: "SUPER + Tab", desc: "Панель управления" },
                { keys: "SUPER + F1", desc: "Справка" }
            ]
        },
        {
            title: "СИСТЕМА",
            items: [
                { keys: "SUPER + L", desc: "Выключить экран (DPMS)" },
                { keys: "SUPER + Shift + L", desc: "Layout: scrolling / dwindle" },
                { keys: "SUPER + S", desc: "Специальное пространство" },
                { keys: "SUPER + Shift + S", desc: "Перенести в специальное" },
                { keys: "SUPER + Esc", desc: "Выход из Hyprland" }
            ]
        }
    ]

    readonly property var middleSections: [
        {
            title: "ОКНА",
            items: [
                { keys: "SUPER + Q", desc: "Закрыть окно" },
                { keys: "SUPER + F", desc: "Полный экран" },
                { keys: "SUPER + Shift + F", desc: "Полный экран (1)" },
                { keys: "SUPER + V", desc: "Плавающее окно" },
                { keys: "SUPER + ←↑↓→", desc: "Фокус" },
                { keys: "ALT + Tab", desc: "Следующее окно" },
                { keys: "ALT + Shift + Tab", desc: "Предыдущее окно" },
                { keys: "SUPER + ALT + ←↑↓→", desc: "Двигать окно" }
            ]
        },
        {
            title: "МЫШЬ",
            items: [
                { keys: "SUPER + ЛКМ + drag", desc: "Переместить окно" },
                { keys: "SUPER + ПКМ + drag", desc: "Изменить размер" }
            ]
        },
        {
            title: "СКРИНШОТЫ",
            items: [
                { keys: "Print", desc: "Сохранить скриншот" },
                { keys: "ALT + Shift + S", desc: "Скриншот в буфер" }
            ]
        }
    ]

    readonly property var rightSections: [
        {
            title: "РАБОЧИЕ ПРОСТРАНСТВА",
            items: [
                { keys: "SUPER + CTRL + ↑/↓", desc: "Прошлое / следующее (по кругу)" },
                { keys: "SUPER + CTRL + ←/→", desc: "Пространство на другом мониторе" },
                { keys: "SUPER + Shift + ↑/↓", desc: "Перенести окно" },
                { keys: "SUPER + Shift + ←/→", desc: "Перенести на другой монитор" },
                { keys: "ALT + 1…0", desc: "Перейти на пространство 1–10" },
                { keys: "SUPER + Shift + 1…0", desc: "Перенести окно на 1–10" },
                { keys: "SUPER + колесо", desc: "Прокрутка пространств" }
            ]
        },
        {
            title: "ОБЗОР",
            items: [
                { keys: "SUPER + O", desc: "Открыть / закрыть обзор" },
                { keys: "ПКМ", desc: "Перейти в пространство" },
                { keys: "ЛКМ + drag", desc: "Перетащить окно" },
                { keys: "1…9, 0, a…z", desc: "Jump-метки" },
                { keys: "Escape", desc: "Закрыть обзор" }
            ]
        }
    ]

    function openHelp() {
        if (helpOpen) return
        helpOpen = true
        focusTimer.restart()
    }

    function closeHelp() {
        if (!helpOpen) return
        helpOpen = false
        focusTimer.stop()
    }

    Timer {
        id: focusTimer
        interval: 60
        repeat: false
        running: false
        onTriggered: keyRoot.forceActiveFocus()
    }

    // ── Затемнение ──
    Rectangle {
        anchors.fill: parent
        color: root.helpOpen ? Qt.rgba(184/255,175/255,147/255,0.55) : "transparent"
        Behavior on color { ColorAnimation { duration: 180 } }

        MouseArea {
            anchors.fill: parent
            enabled: root.helpOpen
            onClicked: root.closeHelp()
        }
    }

    // ── Панель ──
    Rectangle {
        id: panel
        x: (root.screenW - root.lw) / 2
        y: (root.screenH - root.lh) / 2
        width: root.lw
        height: root.lh
        color: root.paper
        border.color: root.ink
        border.width: 1
        opacity: root.helpOpen ? 1 : 0
        scale: root.helpOpen ? 1 : 0.985
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 160 } }
        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Поглотить клики внутри панели
        MouseArea {
            anchors.fill: parent
            onClicked: keyRoot.forceActiveFocus()
        }

        // Мелкая сетка
        Repeater {
            model: Math.floor(root.lw / 20) + 1
            Rectangle { x: index * 20; y: 0; width: 1; height: root.lh; color: root.lineVsoft }
        }
        Repeater {
            model: Math.floor(root.lh / 20) + 1
            Rectangle { x: 0; y: index * 20; width: root.lw; height: 1; color: root.lineVsoft }
        }

        FocusScope {
            id: keyRoot
            anchors.fill: parent
            focus: root.helpOpen

            Keys.onEscapePressed: root.closeHelp()
            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_F1) {
                    root.closeHelp()
                    event.accepted = true
                }
            }
        }

        // ── Шапка ──
        Item {
            id: header
            width: parent.width
            height: 52

            Row {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                          leftMargin: 28; rightMargin: 28 }
                Row {
                    spacing: 14
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: "НЕЙР-СИСТЕМА"; font.pixelSize: 11; font.letterSpacing: 3.5; font.weight: Font.Medium; color: root.inkStrong }
                    Rectangle { width: 24; height: 1; color: root.inkSoft; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: "СПРАВКА"; font.pixelSize: 10; font.letterSpacing: 2; color: root.inkSoft }
                }
                Item { width: parent.width - 400; height: 1 }
                Row {
                    spacing: 14
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: "SUPER + F1"; font.pixelSize: 9; font.letterSpacing: 1.5; color: root.inkSoft }
                    Text { text: "·"; font.pixelSize: 9; color: root.inkSoft }
                    Text { text: "ESC"; font.pixelSize: 9; font.letterSpacing: 1.5; color: root.inkSoft }
                }
            }

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.lineSoft }
        }

        // ── Тело ──
        Item {
            id: body
            anchors {
                top: header.bottom; bottom: footer.top
                left: parent.left; right: parent.right
                leftMargin: 28; rightMargin: 28
                topMargin: 16; bottomMargin: 12
            }

            Row {
                anchors.fill: parent
                spacing: 26

                Column {
                    width: (parent.width - 52) / 3
                    spacing: 16
                    Repeater {
                        model: root.leftSections
                        delegate: Column {
                            width: parent.width
                            spacing: 7
                            Text { text: modelData.title; font.pixelSize: 10; font.letterSpacing: 2.5; font.weight: Font.Medium; color: root.accent }
                            Rectangle { width: 24; height: 1; color: root.accent; opacity: 0.7 }
                            Repeater {
                                model: modelData.items
                                delegate: Item {
                                    width: parent.width
                                    height: 23
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        spacing: 10
                                        Rectangle {
                                            width: 150; height: 19
                                            color: "transparent"; border.color: root.lineSoft; border.width: 1
                                            Text { anchors.centerIn: parent; text: modelData.keys; font.pixelSize: 9; font.letterSpacing: 0.5; color: root.ink }
                                        }
                                        Text {
                                            width: parent.width - 160
                                            text: modelData.desc
                                            font.pixelSize: 10
                                            color: root.inkStrong
                                            elide: Text.ElideRight
                                        }
                                    }
                                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.lineVsoft; opacity: 0.7 }
                                }
                            }
                        }
                    }
                }

                Column {
                    width: (parent.width - 52) / 3
                    spacing: 16
                    Repeater {
                        model: root.middleSections
                        delegate: Column {
                            width: parent.width
                            spacing: 7
                            Text { text: modelData.title; font.pixelSize: 10; font.letterSpacing: 2.5; font.weight: Font.Medium; color: root.accent }
                            Rectangle { width: 24; height: 1; color: root.accent; opacity: 0.7 }
                            Repeater {
                                model: modelData.items
                                delegate: Item {
                                    width: parent.width
                                    height: 23
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        spacing: 10
                                        Rectangle {
                                            width: 150; height: 19
                                            color: "transparent"; border.color: root.lineSoft; border.width: 1
                                            Text { anchors.centerIn: parent; text: modelData.keys; font.pixelSize: 9; font.letterSpacing: 0.5; color: root.ink }
                                        }
                                        Text {
                                            width: parent.width - 160
                                            text: modelData.desc
                                            font.pixelSize: 10
                                            color: root.inkStrong
                                            elide: Text.ElideRight
                                        }
                                    }
                                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.lineVsoft; opacity: 0.7 }
                                }
                            }
                        }
                    }
                }

                Column {
                    width: (parent.width - 52) / 3
                    spacing: 16
                    Repeater {
                        model: root.rightSections
                        delegate: Column {
                            width: parent.width
                            spacing: 7
                            Text { text: modelData.title; font.pixelSize: 10; font.letterSpacing: 2.5; font.weight: Font.Medium; color: root.accent }
                            Rectangle { width: 24; height: 1; color: root.accent; opacity: 0.7 }
                            Repeater {
                                model: modelData.items
                                delegate: Item {
                                    width: parent.width
                                    height: 23
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width
                                        spacing: 10
                                        Rectangle {
                                            width: 150; height: 19
                                            color: "transparent"; border.color: root.lineSoft; border.width: 1
                                            Text { anchors.centerIn: parent; text: modelData.keys; font.pixelSize: 9; font.letterSpacing: 0.5; color: root.ink }
                                        }
                                        Text {
                                            width: parent.width - 160
                                            text: modelData.desc
                                            font.pixelSize: 10
                                            color: root.inkStrong
                                            elide: Text.ElideRight
                                        }
                                    }
                                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: root.lineVsoft; opacity: 0.7 }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ── Низ ──
        Item {
            id: footer
            anchors.bottom: parent.bottom
            width: parent.width
            height: 40

            Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: root.lineSoft }

            Row {
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
                          leftMargin: 28; rightMargin: 28 }
                Text { text: "ОСНОВНЫЕ ГОРЯЧИЕ КЛАВИШИ"; font.pixelSize: 9; font.letterSpacing: 2.5; color: root.inkSoft }
                Item { width: parent.width - 320; height: 1 }
                Row {
                    spacing: 14
                    Repeater {
                        model: [["F1", "СПРАВКА"], ["ESC", "ЗАКРЫТЬ"], ["КЛИК", "ВНЕ"]]
                        Row {
                            spacing: 5
                            Rectangle {
                                width: kbdT.implicitWidth + 8; height: 16
                                color: "transparent"; border.color: root.lineSoft; border.width: 1
                                Text { id: kbdT; anchors.centerIn: parent; text: modelData[0]; font.pixelSize: 9; font.letterSpacing: 1; color: root.ink }
                            }
                            Text { text: modelData[1]; anchors.verticalCenter: parent.verticalCenter; font.pixelSize: 9; font.letterSpacing: 2; color: root.inkSoft }
                        }
                    }
                }
            }
        }
    }
}
