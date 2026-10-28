# NixOS Rice — Unit-3 / Hyprland

Персональная NixOS-конфигурация: Hyprland + Home Manager + Quickshell в стиле
Unit-3, Waybar, Kitty, Zsh/p10k и набор повседневных приложений.

Рассчитана в первую очередь на desktop с NVIDIA, но при замене
`hardware-configuration.nix` её можно использовать на другом железе.

Демонстрация работы: [YouTube — Unit-3 rice](https://youtu.be/4b-UcpTkHts).

## Основной функционал

### Рабочий стол

- **Hyprland** с обычным layout `dwindle`; `scrolling` (niri-подобные колонки)
  включается по `SUPER+SHIFT+L`.
- **Два монитора**: workspace 1–5 на `DP-1`, 6–10 на `DP-2`.
- Цикличная навигация по workspace (`SUPER+CTRL+↑/↓`), перенос окон между
  workspace и мониторами (`SUPER+SHIFT+...`).
- **hyprtasking** — визуальный обзор workspace и окон по `SUPER+O`:
  сетка, drag&drop, jump-метки, жесты тачпада.
- `SUPER+L` — выключение экрана (DPMS), без lockscreen.
- `SUPER+F1` — справка по основным хоткеям в стиле лаунчера.

### Quickshell

- Лаунчер приложений (`SUPER+D`).
- Панель управления (`SUPER+Tab`): звук, Wi-Fi, Bluetooth, яркость,
  медиа, быстрые действия.
- Выбор обоев (`SUPER+P`).
- Уведомления, VolumeBar, Companions.
- Справка `SUPER+F1`.
- Тема Unit-3: сепия, бумажная фактура, сетка, русские подписи.

### Waybar

- Часы по центру, календарь по клику (`gsimplecal`).
- Workspace, активное окно, tray, pomodoro, CPU/RAM, сеть, звук,
  раскладка, питание.

### Приложения и утилиты

- Терминал: **Kitty** + Maple Mono.
- Shell: **Zsh** + p10k; Neovim, Yazi, Nemo, fastfetch, bat, fzf, ripgrep.
- Браузер: **Zen Browser**.
- Связь: **Telegram**, **Vesktop**; медиа: VLC, Audacity и др.
- Скриншоты, буфер обмена (cliphist), управление питанием.

#### Vencord / Vesktop

- Локальная тема Unit-3 лежит в `main/themes/vencord/unit3.theme.css`
  и линкуется в `~/.config/Vencord/themes/` и `~/.config/vesktop/themes/`.
- Включение: **Settings → Themes → Local Themes → Unit-3**.
- При использовании этой темы рекомендуется включить в Vencord/Vesktop
  **светлую тему Discord** (**Settings → Appearance → Light**).
  На тёмной теме часть токенов может переопределяться, и цвета будут
  выглядеть иначе.
- После правок CSS достаточно обновить клиент через `Ctrl+R`.

### Система

- Nix flakes + Home Manager; всё ставится одной сборкой.
- **sops-nix** для секретов.
- Опционально: **pi-агент** (rootless Podman) и **B4** (Docker).
- Автоматическая очистка Nix (`nh clean`, раз в месяц, хранит 10 поколений).
- Локализация интерфейса на русском; `LC_TIME=ru_RU`.
- `install.sh` — интерактивный установщик для чистой NixOS.

## Установка на чистую NixOS

Подразумевается, что NixOS **уже установлен** и ты загрузился в него
(не live-ISO). Нужны интернет и flake-поддержка (в NixOS она есть).

1. Склонируй или скопируй репозиторий и перейди в него:

   ```bash
   git clone <repo-url> ~/nixos-config
   cd ~/nixos-config
   ```

2. Запусти установщик:

   ```bash
   sudo bash install.sh
   ```

   Он:

   - возьмёт `/etc/nixos/hardware-configuration.nix` текущей системы
     (или сгенерирует его);
   - спросит имя пользователя и подставит его в `flake.nix` и домашние пути;
   - предложит чекбоксами установить **pi-агент** и **B4**;
   - закомментирует/раскомментирует их импорты в `main/core/default.nix`;
   - сделает бэкап в `.installer-backup-*`;
   - предложит запустить `nixos-rebuild boot --flake "path:.#default"`.

3. Если используешь sops-секреты (GitHub/DeepSeek), до перезагрузки
   положи age-ключ в домашний каталог **нового** пользователя:

   ```bash
   sudo mkdir -p /home/<user>/.config/sops/age
   sudo cp /path/to/keys.txt /home/<user>/.config/sops/age/keys.txt
   sudo chown -R <user>:users /home/<user>/.config/sops
   sudo chmod 600 /home/<user>/.config/sops/age/keys.txt
   ```

   Ключ **не** входит в репозиторий. Если секреты не нужны — при запуске
   установщика не выбирай pi, а после установки удали `./soap.nix`
   (и `./pi.nix`, если не нужен) из `main/core/default.nix`.

4. Перезагрузи систему:

   ```bash
   sudo reboot
   ```

5. После входа задай пароль пользователю (если он ещё не задан):

   ```bash
   sudo passwd <имя>
   ```

6. Проверь:

   ```bash
   hyprctl plugin list   # должен быть hyprtasking
   ```

   Быстрые клавиши: `SUPER+D` — лаунчер, `SUPER+F1` — справка,
   `SUPER+O` — обзор workspace, `SUPER+Tab` — панель управления.

### Установка без install.sh

```bash
cp /etc/nixos/hardware-configuration.nix main/hardware-configuration.nix
# поменяй username в flake.nix
# замени /home/chu в main/core/b4-docker.nix и main/core/soap.nix
sudo nixos-rebuild boot --flake "path:.#default"
sudo reboot
```

`host`/`hostName` сейчас `chebupel`; на другой машине поменяй его в
`flake.nix` и `main/core/network.nix`.

> Почему `path:`: Git-флейк видит только tracked-файлы. Локальные
> `main/core/stoat.nix`, `main/home/git.nix` и
> `main/hardware-configuration.nix` специально ignored и в публичный Git
> не попадают — `path:` включает их в локальную сборку, но не в Git.

## Что не публикуется

Эти файлы/каталоги исключены через `.gitignore`:

- `main/core/stoat.nix` — **реальные секреты** Stoat/Revolt (VAPID private key,
  encryption key, MinIO/RabbitMQ пароли, LiveKit secret). Никогда не коммитить.
  Если файл когда-либо попадал в Git, архив или публикацию — **ротировать все
  ключи**.
- `main/home/git.nix` — личный git-конфиг (имя/email).
- `main/hardware-configuration.nix` — machine-specific; создаётся установщиком.
- `.pi/`, `*.jsonl` — сессии агента и история.
- `/result`, `/result-*`, `flake.lock.back`, `.installer-backup-*` — артефакты
  сборки и бэкапы.

`secrets/common.yaml` зашифрован sops/age. Приватный age-ключ
`~/.config/sops/age/keys.txt` не должен попадать в репозиторий.

## Структура

```
flake.nix                 # входная точка, username/host
install.sh                 # установщик для чистой NixOS
main/
├── core/                 # NixOS-модули (system, users, docker, pi, sops, ...)
├── home/                 # Home Manager (hyprland, waybar, quickshell, apps)
├── themes/               # темы Unit-3, GTK, Vencord и Zen
└── hardware-configuration.nix
secrets/                  # sops-зашифрованные секреты
```

## Благодарности

- **FROST-PHOENIX** — часть кода и идей взята из его проекта `nixos-config`.
- **samyns/Unit-3** — [github.com/samyns/Unit-3](https://github.com/samyns/Unit-3),
  лицензия MIT. Тема и часть конфигов лежат в `main/themes/unit3/`;
  при распространении сохраняй `main/themes/unit3/LICENSE`.
- **Hyprland**, **Quickshell**, **Home Manager**, **nixpkgs** и авторы
  пакетов, на которых всё держится.
- Изображение `files/forest_road.jpg` — MIT.

## Лицензии

Собственный код репозитория — см. `LICENSE`. Вендоренная тема Unit-3 —
`main/themes/unit3/LICENSE` (MIT). Изображение в `files/` — MIT.

## Дисклеймер

Конфигурация собиралась вручную и с помощью нейросети (LLM). Это не
официальный дистрибутив и не гарантия совместимости с любым железом:
проверяй конфиг перед применением, особенно разметку дисков, NVIDIA-драйверы
и секреты.

---

# NixOS Rice — Unit-3 / Hyprland (English)

> **Note:** This rice was made for personal use only. There are no plans to
translate it into English; this English section is a one-off courtesy duplicate
for friends and may lag behind the Russian original.

Personal NixOS configuration: Hyprland + Home Manager + Quickshell in the
Unit-3 style, Waybar, Kitty, Zsh/p10k, and a set of everyday applications.

Primarily aimed at an NVIDIA desktop, but with a different
`hardware-configuration.nix` it can be used on other hardware.

Demo: [YouTube — Unit-3 rice](https://youtu.be/4b-UcpTkHts).

## Main features

### Desktop

- **Hyprland** with the regular `dwindle` layout; `scrolling` (niri-like
  columns) is enabled with `SUPER+SHIFT+L`.
- **Two monitors**: workspaces 1–5 on `DP-1`, 6–10 on `DP-2`.
- Cyclic workspace navigation (`SUPER+CTRL+↑/↓`), moving windows between
  workspaces and monitors (`SUPER+SHIFT+...`).
- **hyprtasking** — visual overview of workspaces and windows via `SUPER+O`:
  grid, drag & drop, jump labels, touchpad gestures.
- `SUPER+L` — turn off the display (DPMS), no lockscreen.
- `SUPER+F1` — help for the main keybinds in the launcher style.

### Quickshell

- Application launcher (`SUPER+D`).
- Control panel (`SUPER+Tab`): volume, Wi-Fi, Bluetooth, brightness, media,
  quick actions.
- Wallpaper picker (`SUPER+P`).
- Notifications, VolumeBar, Companions.
- Help (`SUPER+F1`).
- Unit-3 theme: sepia, paper texture, grid, Russian labels.

### Waybar

- Centered clock, calendar on click (`gsimplecal`).
- Workspaces, active window, tray, pomodoro, CPU/RAM, network, sound,
  layout, power.

### Applications and utilities

- Terminal: **Kitty** + Maple Mono.
- Shell: **Zsh** + p10k; Neovim, Yazi, Nemo, fastfetch, bat, fzf, ripgrep.
- Browser: **Zen Browser**.
- Communication: **Telegram**, **Vesktop**; media: VLC, Audacity, etc.
- Screenshots, clipboard (cliphist), power management.

#### Vencord / Vesktop

- The local Unit-3 theme lives in `main/themes/vencord/unit3.theme.css`
  and is linked into `~/.config/Vencord/themes/` and
  `~/.config/vesktop/themes/`.
- Enable it in **Settings → Themes → Local Themes → Unit-3**.
- When using this theme, it is recommended to enable the **light Discord
  theme** (**Settings → Appearance → Light**). On the dark theme, some tokens
  may be overridden and the colors may look different.
- After CSS changes, reload the client with `Ctrl+R`.

### System

- Nix flakes + Home Manager; everything is installed in one build.
- **sops-nix** for secrets.
- Optional: **pi agent** (rootless Podman) and **B4** (Docker).
- Automatic Nix cleanup (`nh clean`, monthly, keeps 10 generations).
- Russian UI localization; `LC_TIME=ru_RU`.
- `install.sh` — interactive installer for a clean NixOS.

## Installing on a clean NixOS

This assumes NixOS is **already installed** and you have booted into it
(not a live ISO). Internet access and flake support are required (NixOS has both).

1. Clone or copy the repository and change into it:

   ```bash
   git clone <repo-url> ~/nixos-config
   cd ~/nixos-config
   ```

2. Run the installer:

   ```bash
   sudo bash install.sh
   ```

   It will:

   - take `/etc/nixos/hardware-configuration.nix` from the current system
     (or generate it);
   - ask for the username and substitute it into `flake.nix` and home paths;
   - offer checkboxes to install the **pi agent** and **B4**;
   - comment out/uncomment their imports in `main/core/default.nix`;
   - create a backup in `.installer-backup-*`;
   - offer to run `nixos-rebuild boot --flake "path:.#default"`.

3. If you use sops secrets (GitHub/DeepSeek), before rebooting place the age
   key in the **new** user's home directory:

   ```bash
   sudo mkdir -p /home/<user>/.config/sops/age
   sudo cp /path/to/keys.txt /home/<user>/.config/sops/age/keys.txt
   sudo chown -R <user>:users /home/<user>/.config/sops
   sudo chmod 600 /home/<user>/.config/sops/age/keys.txt
   ```

   The key is **not** included in the repository. If you do not need secrets,
   do not select pi in the installer and remove `./soap.nix` (and `./pi.nix`
   if not needed) from `main/core/default.nix` after installation.

4. Reboot the system:

   ```bash
   sudo reboot
   ```

5. After logging in, set the user password (if not set yet):

   ```bash
   sudo passwd <user>
   ```

6. Check:

   ```bash
   hyprctl plugin list   # should be hyprtasking
   ```

   Keybinds: `SUPER+D` — launcher, `SUPER+F1` — help,
   `SUPER+O` — workspace overview, `SUPER+Tab` — control panel.

### Installing without install.sh

```bash
cp /etc/nixos/hardware-configuration.nix main/hardware-configuration.nix
# change the username in flake.nix
# replace /home/chu in main/core/b4-docker.nix and main/core/soap.nix
sudo nixos-rebuild boot --flake "path:.#default"
sudo reboot
```

`host`/`hostName` is currently `chebupel`; on another machine, change it in
`flake.nix` and `main/core/network.nix`.

> Why `path:`: a Git flake only sees tracked files. The local
> `main/core/stoat.nix`, `main/home/git.nix`, and
> `main/hardware-configuration.nix` are intentionally ignored and are not
> published to Git; `path:` includes them in the local build but not in Git.

## What is not published

These files/directories are excluded via `.gitignore`:

- `main/core/stoat.nix` — **real secrets** for Stoat/Revolt (VAPID private key,
  encryption key, MinIO/RabbitMQ passwords, LiveKit secret). Never commit it.
  If the file has ever ended up in Git, an archive, or a publication —
  **rotate all keys**.
- `main/home/git.nix` — personal Git config (name/email).
- `main/hardware-configuration.nix` — machine-specific; created by the installer.
- `.pi/`, `*.jsonl` — agent sessions and history.
- `/result`, `/result-*`, `flake.lock.back`, `.installer-backup-*` — build
  artifacts and backups.

`secrets/common.yaml` is encrypted with sops/age. The private age key
`~/.config/sops/age/keys.txt` must not end up in the repository.

## Structure

```text
flake.nix                 # entry point, username/host
install.sh                # installer for a clean NixOS
main/
├── core/                 # NixOS modules (system, users, docker, pi, sops, ...)
├── home/                 # Home Manager (hyprland, waybar, quickshell, apps)
├── themes/               # Unit-3, GTK, Vencord and Zen themes
└── hardware-configuration.nix
secrets/                  # sops-encrypted secrets
```

## Credits

- **FROST-PHOENIX** — some of the code and ideas are taken from his
  `nixos-config` project.
- **samyns/Unit-3** — [github.com/samyns/Unit-3](https://github.com/samyns/Unit-3),
  MIT license. The theme and some configs live in `main/themes/unit3/`;
  keep `main/themes/unit3/LICENSE` when redistributing.
- **Hyprland**, **Quickshell**, **Home Manager**, **nixpkgs**, and the authors
  of the packages everything relies on.
- The image `files/forest_road.jpg` — MIT.

## Licenses

The repository's own code — see `LICENSE`. The vendored Unit-3 theme —
`main/themes/unit3/LICENSE` (MIT). The image in `files/` — MIT.

## Disclaimer

The configuration was assembled manually and with the help of an LLM. It is
not an official distribution and does not guarantee compatibility with any
hardware: review the config before applying, especially the disk layout,
NVIDIA drivers, and secrets.
