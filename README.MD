# NixOS Rice — Unit-3 / Hyprland

Персональная NixOS-конфигурация: Hyprland + Home Manager + Quickshell в стиле
Unit-3, Waybar, Kitty, Zsh/p10k и набор повседневных приложений.

Рассчитана в первую очередь на desktop с NVIDIA, но при замене
`hardware-configuration.nix` её можно использовать на другом железе.

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
   - предложит запустить `nixos-rebuild boot --flake .#default`.

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
sudo nixos-rebuild boot --flake .#default
sudo reboot
```

`host`/`hostName` сейчас `chebupel`; на другой машине поменяй его в
`flake.nix` и `main/core/network.nix`.

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
├── themes/unit3/         # вендоренная тема Unit-3 (MIT)
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
