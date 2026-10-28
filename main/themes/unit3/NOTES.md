# Unit-3 (vendored) — integration notes

Upstream: https://github.com/samyns/Unit-3 — **MIT**, Copyright (c) 2026 samyns.
Keep `LICENSE` when publishing.

> Upstream targets Hyprland 0.54/0.55 and legacy hyprlang (works until ~0.57).
> Our nixpkgs has Hyprland **0.56.2** — works, but expect a deprecation notice.
> Home-manager already supports `configType = "lua"` for the future migration.

> **`hypr/` is reference only.** The live config is generated from
> `main/home/hyprland/*.nix` into `~/.config/hypr/hyprland.conf`.
> Add binds in `main/home/hyprland/binds.nix`, not in `hypr/`.

## Layout

```
main/themes/unit3/
├── LICENSE
├── UPSTREAM_README.md
├── hypr/                   # reference raw configs (hyprland.conf, hyprlock.conf, lock.sh)
├── pam/qs-lock             # PAM service for the Quickshell lockscreen (L3)
├── quickshell/             # QML shell, widgets, scripts, assets
├── upstream-packages/      # Arch package lists (reference only)
└── waybar/                 # config.jsonc, style.css, scripts/
```

This directory is the source of truth: `main/home/quickshell.nix` **copies** it
to `~/.config/quickshell` on activation (writable, so generated videos work).
Edit here, then rebuild.

## L1 — done (Waybar + Hyprland visuals)

- `main/home/waybar/{settings,style,scripts}.nix` — Unit-3 bar + pomodoro scripts.
- `main/home/hyprland/{settings,binds,windowrules}.nix` — Unit-3 visuals/binds.
- `main/home/fonts.nix` + `main/pkgs/share-tech-mono.nix` — Share Tech Mono +
  Noto CJK. Terminal stays kitty + Maple Mono.

## L2 — done (Quickshell menus)

- `main/home/quickshell.nix` — `quickshell` (+ `qs` symlink), `python3`,
  `pulseaudio` (pactl), `gtk4-layer-shell`; activation copy of this directory.
- Autostart: `qs` (main shell: Notifications + Menu) and
  `qs -p widgets/VolumeBar.qml` (standalone). `swaync` is no longer started.
- Binds: `SUPER+D` app menu, `SUPER+P` wallpaper picker, `SUPER+E` nemo.
- `shell.qml`: ControlCenter / Player / Companions remain commented (L3).
- NixOS patches:
  - `list-apps.sh` scans XDG_DATA_DIRS + `/run/current-system/sw` + per-user profile.
  - `WallpaperPicker.qml` — QtMultimedia/video transitions removed for L2;
    wallpaper dir is `~/Pictures/wallpapers/others`.
  - `wallpaper.sh` — toggle + uses `~` (not `$HOME`): `HOME` may be unset in
    the environment used by `hyprctl dispatch exec`.
  - `Menu.qml` footer: FILES → nemo, LOCK → hyprlock.
  - `ext_last_fr.py` — `$HOME` instead of `/home/samyns`.
  - `qshare.py` / `pixel_wave.py` / `pixel-wave-close-video.py` — NixOS hints.
  - File modes normalized to 644/755.

## L3 — current scope (ControlCenter + Companions)

- **ControlCenter**: loaded in the main shell (`shell.qml`: `ControlCenter {}`);
  `qs ipc call ctrl toggle` only sees targets in the main instance.
  A separate `qs -p ControlCenter.qml` instance has its own IPC namespace and
  breaks `ctrl.sh` (`Target not found`).
  Installed deps: `bluez` (bluetoothctl), `yazi`, `kdeconnect`,
  `cloudflared`, `qrencode`, `python3` with `qrcode`/`pillow`, `pactl`
  (`pulseaudio`), `kitty` (yazi picker). `nmcli` comes from NetworkManager.
- **Companions**: enabled in `shell.qml`.
- **Player**: intentionally skipped (no local music). The Player block stays
  commented; the playerctl plumbing in `shell.qml` is harmless.
- **Quickshell lockscreen / QtMultimedia / wallpaper video transitions**:
  intentionally skipped. `SUPER+L` runs the user's `lock` script (DPMS toggle);
  lid close/open does DPMS off/on.
- `hyprlock` still starts at boot and the Menu footer `LOCK` still calls it.
  Remove those if you want no lock screen at all.

## Upstream deps (reference)

quickshell, awww, pamtester, hyprland/hyprlock/hypridle, waybar, qt6-wayland,
qt6-multimedia-ffmpeg, gtk4-layer-shell, kitty, yazi, pipewire/wireplumber,
playerctl, polkit-kde-agent, kdeconnect, brightnessctl, grim/slurp/satty,
hyprshot, wl-clipboard, udiskie, networkmanager, fonts (noto, jetbrains),
fish/starship, python (cairo, numpy, pillow, opencv, qrcode), qrencode,
cloudflared, xdg-utils.
