# Handoff — NixOS Rice / Unit-3

This file is a handoff for another agent (DeepSeek Harness / DSH) or a future
session. The repository is the source of truth; this is the working context.

## Project

- Personal NixOS + Home Manager + Hyprland rice in the `Unit-3` style.
- Host repo: `/home/chu/agent-workspace/workspace/rice/repo`
- Container repo: `/workspace/workspace/rice/repo`
- Host user: `chu`; host: `chebupel`
- Hyprland 0.56.2, Quickshell 0.3.2, nixpkgs rev
  `3ec636362e1816bc2f0888fa0fa2c69f1bc9e504`.
- Main build command (on the host, not inside the container):

```bash
cd ~/agent-workspace/workspace/rice/repo
sudo nixos-rebuild switch --flake "path:.#default"
```

## Workspace layout

The DSH workspace root (`~/agent-workspace/workspace/rice`) is **not** the
repository. It was split so the agent has scratch space that Git cannot see:

- `repo/` — this Git repository (the flake, `main/`, themes). Every build,
  `git` and `nix` command runs from here.
- `.pi/` — pi agent state, deliberately kept at the workspace root because
  `main/core/pi.nix` mounts `${home}/agent-workspace/workspace/rice/.pi`.
  Never move it and never edit `pi.nix`.
- `.dsh/tmp/` — disposable scratch: render sandboxes, screenshots, the nix
  cache redirect. Safe to delete.
- `.dsh/skills/` — project skills (`<name>/SKILL.md`) loaded by DSH.

`path:.#default` is still relative to the repository, so it works unchanged
once you are in `repo/`.

`path:` is deliberate: local ignored files such as `main/core/stoat.nix`,
`main/home/git.nix` and `main/hardware-configuration.nix` must be visible to the
build but must not be published. Never replace it with a plain Git flake.

## Agent sandbox facts

- PID namespace is isolated: `ps`, `pgrep` and `pkill` see only the agent's own
  `bwrap` shell. Never conclude "the app is not running" from an empty
  `pgrep`; use `hyprctl clients -j` for windows, and ask the user to restart
  layer-shell apps (waybar, quickshell) or GTK apps.
- `/tmp` does not survive between tool calls; scratch goes to `.dsh/tmp`.
- `~/.cache/nix` is read-only in the sandbox: set
  `XDG_CACHE_HOME="$PWD/../.dsh/tmp/cache"` before any nix command.
- No root: `sudo` fails (`NoNewPrivs=1`), so `nixos-rebuild switch` is always
  the user's action.

## Hard constraints

- **Do not modify `main/core/pi.nix`.** The pi agent runs in rootless Podman
  with a persistent `.pi` mount.
- Never commit unencrypted secrets. `main/core/stoat.nix`,
  `main/home/git.nix`, `main/hardware-configuration.nix`, `.pi/` and `*.jsonl`
  are ignored.
- Do not run `nixos-rebuild` or nix builds inside the container; the user
  applies changes on the host.
- Do not add broad CSS such as `menuitem box { ... }` that applies to every
  menu box: it breaks the GIMP menu hierarchy and hover behavior.
- Keep terminal/window tiling normal; no kitty-specific window rules.

## Current UI state

### GTK / Nemo / GIMP

Main file: `main/themes/gtk/unit3.css`
Loaded by: `main/home/gtk.nix` via `gtk3.extraCss` and `gtk4.extraCss`.

Recent work:

- `label { color: inherit; }` stops Colloid's light label colour from winning on
  paper.
- Menubar: paper background, dark text, rust hover/selected.
- Nemo selection:
  - `.nemo-canvas-item:selected`: `rgba(139, 115, 85, 0.8)` background,
    `#f5f0e6` text.
  - list/treeview selected: `@u3_accent` background, `@u3_paper` text, bold.
  - Nemo rubberband: transparent `rgba(139, 115, 85, 0.3)` with
    `#6B5A45` border.
- GIMP menus (resolved, verified 2026-11-01): items with hierarchy
  `menuitem > box.horizontal > label` inherited Colloid's light label colour.
  Targeted rules cover `menuitem > box.horizontal` / its label plus hover and
  disabled variants. Do not reintroduce the broad `menuitem box` block. The
  old `common.css:285:18` / `#dcdcdc` citation is stale: no `common.css` exists
  in the installed Colloid build and `#dcdcdc` does not occur in it — check the
  winning provider in GTK Inspector.
- GTK Inspector custom CSS is a `<data>` provider and can override the file.
  Use Pause/disable it when checking the real theme.
- gsimplecal (`calendar` CSS node, GTK3): Colloid paints the day numbers
  cream `#fbf1c7` (`gtk-3.0/gtk.css:3309`) on our paper background. `unit3.css`
  now overrides `calendar`, `:selected`, `.header`, `.highlight`, `.button`,
  `:indeterminate`/`:disabled`. CSS is read at startup, so restart it after a
  rebuild (`pkill -x gsimplecal`). Verified with a headless GTK render
  (`.dsh/skills/gtk-style-probe`), not by eye.
- The GTK Inspector CSS editor was made readable with rules for
  `textview text`, `textview.view text` and `.sourceview text`.

### Hyprland

Key files:

- `main/home/hyprland/settings.nix`
- `main/home/hyprland/binds.nix`
- `main/home/hyprland/exec-once.nix`

Current important settings:

- `general.layout = "dwindle"`.
- `input.follow_mouse = 2`;
  `input.float_switch_override_focus = 0`.
  This keeps keyboard focus while allowing scroll under the cursor.
  `follow_mouse = 0` was wrong: it also disabled pointer focus for the
  hovered window.
- Per-workspace layout toggle: `layout-toggle.sh`, `SUPER+SHIFT+L`.
- Hyprtasking overview: `SUPER+O`.
- Current binds:
  - `SUPER+V` — clipboard history (`clipboard` script).
  - `SUPER+C` — toggle floating.
  - `SUPER+J` — `layoutmsg togglesplit`.
  - `SUPER+SHIFT+B` — `BTOP_OPACITY=0.85 btop-paper`.
  - `SUPER+SHIFT+S` — screenshot to clipboard.
  - `SUPER+ALT+S` — move window to special workspace.
  - `SUPER+F1` — Quickshell help.

### Quickshell

- Source: `main/themes/unit3/quickshell/`
- Copied to `~/.config/quickshell` by `main/home/quickshell.nix`.
- Activation now copies in place instead of `rm -rf` to avoid Quickshell
  seeing `shell.qml` disappear during a rebuild.
- After a rebuild, restart Quickshell once:

```bash
pkill -x quickshell || true
hyprctl dispatch exec 'qs'
hyprctl dispatch exec 'qs -p ~/.config/quickshell/widgets/VolumeBar.qml'
```

- Help: `widgets/Help.qml`; app menu; ControlCenter; wallpaper picker.
- VolumeBar is standalone, not part of the main shell.
- **Companions** (the NieR mascot widget) is **disabled**:
  `Settings.companionsEnabled = false` in
  `main/themes/unit3/quickshell/settings/Settings.qml`, and `shell.qml`
  instantiates it only behind that flag. The code stays — it is off, not dead.
  Whoever switches it on owns its look: it still uses the warm character
  accents (`#c87060`, `#c8a860`, `#c8b89a`), not the paper palette.

### Palette notes

The paper palette is the whole UI. Do not describe any surface as "dark NieR"
except the bar:

- Menu, ControlCenter, Help and WallpaperPicker use
  `settings/U3Palette.qml`; VolumeBar still carries inline colours. The old
  `quickshell/theme/Theme.qml` singleton (NieR colours, never imported) was
  deleted — do not recreate it.
- Waybar is intentionally the only dark surface: `rgba(11, 10, 9, 0.92)` in
  `main/home/waybar/style.nix`. It reads as a bar over the wallpaper.
- `main/home/swaync/style.css` still holds gruvbox colours, but `exec-once`
  never starts swaync.

### Runtime palettes (2026-11-02)

- **`main/themes/palettes/*.toml` are the palette sources.** Four themes:
  `unit3` (paper/ink/rust, square), `gaming` (black/red/blue, square),
  `space` (black/blue/violet, `radius = "10px"`), `mimimi` (soft pink /
  green / yellow, `radius = "20px"`).
- `main/themes/runtime/unit3-palette.py` renders the templates in
  `main/themes/{gtk,vencord,zen,steam,btop}` with the selected TOML into
  `~/.config/unit3/profiles/<name>/`, writes `qml.json`, switches the
  `~/.config/unit3/active` symlink and writes `~/.config/unit3/style`.
- `main/home/unit3-palette.nix` copies templates/script once per rebuild and
  seeds `~/.config/unit3/palettes/` only when a file is missing; the live
  editable copies are there. It runs the first/current render; **switching
  itself never invokes Nix**. The same module's `unit3Wallpapers` activation
  seeds `~/Pictures/wallpapers/{unit3,gaming,space,mimimi,others}` from
  `files/wallpapers/` (missing files only). `install.sh` does the same early
  when the target home already exists.
- `SUPER+ALT+P` → `unit3-palette next` (style only); `SUPER+SHIFT+P` →
  `unit3-palette next --wallpaper` (next style + random wallpaper from its
  folder). `unit3-palette set <name>`, `current`, `list`, `remember <file>`.
- `unit3-palette` is a profile wrapper with Python in its runtime PATH, so the
  Hyprland `exec` binds use its absolute `/etc/profiles/per-user/chu/bin/...`
  path. The wrapper survives a minimal session PATH.
- App integration: GTK imports `active/gtk.css`; Vencord and btop use
  `mkOutOfStoreSymlink` to the active profile; Zen chrome/userContent are
  symlinked by activation; Steam's `custom.css` and installed skin are
  symlinks. Quickshell `ControlCenter`, `Help`, `Menu` and `WallpaperPicker`
  read `active/qml.json` through `settings/U3Palette.qml`.
- Current style is also `~/.config/unit3/style` and the `U3_STYLE`
  environment variable (set via `hyprctl setenv`). Wallpaper scripts read the
  file and use `~/Pictures/wallpapers/<style>/`, falling back to `others`.
- The selected wallpaper is persisted in `~/.config/unit3/wallpaper` and
  restored by `init-wallpaper` at login together with `style`; it is not
  reset to a default image.
- Wallpaper picker (`SUPER+P`): scans `png/jpg/jpeg/webp/gif` (animated gifs
  are supported by awww). Left/right cycles the current style folder,
  up/down cycles style folders, and applying an image from another folder
  runs `wallpaper-apply` (which sets the palette first). The helper waits for
  `awww`, quotes paths passed as argv (spaces in user filenames are fine) and
  restarts the daemon once if it died mid-transition. The picker waits for
  the helper before closing. It is palette-aware too.
- Launcher (`SUPER+D`, `widgets/Menu.qml`) now uses the same `U3Palette`.
- A palette switch is mostly hot: GTK/Steam/btop need an app restart,
  Vencord/Zen need a reload/restart; Quickshell ControlCenter, Help, Menu and
  WallpaperPicker update via the watched style file.
- Not in this pass: Waybar (intentionally dark), rofi `.rasi`, VolumeBar and
  hyprlock.

### Application themes

- Vencord/Vesktop:
  - `main/themes/vencord/unit3.theme.css`
  - linked by `main/home/discord.nix` to Vencord and Vesktop local themes.
  - Enable in Vencord: Settings → Themes → Local Themes → Unit-3.
  - **Use the light Discord theme** with this local theme, otherwise some
    tokens are overridden. Reload with Ctrl+R after CSS changes.
  - Search/profile/button/badge text is now set explicitly with the
    `--u3-on-surface*` aliases, so those components no longer depend on the
    Vesktop light/dark setting. Dark islands (tooltip premium footer, avatar
    overflow) intentionally keep light text — do not flatten them with a
    global `* { color: ... }`.
  - Guild view: header name, channel names (including unread), boost card,
    message context menu and blurple “новое” badges are explicit too;
    `--brand-500…900` are rust so Discord's blurple no longer leaks.
- Zen Browser:
  - `main/themes/zen/userChrome.css`, `userContent.css`
  - loaded by `main/home/browser.nix`.
  - Profile path is currently `uf1assfh.Default Profile`.
  - Zen workspace themes are part of workspace state, not this CSS; a
    generated `chrome/zen-themes.css` can override colors. Use neutral
    workspace colors if a consistent Unit-3 look is wanted.
- Steam:
  - `main/themes/steam/unit3.css` — template for the Adwaita-for-Steam skin;
    `unit3-palette` renders the active palette to `active/steam.css`.
  - `main/home/gaming.nix` symlinks `~/.config/AdwSteamGtk/custom.css` to the
    active profile and applies the skin on rebuild. The installed skin's
    `custom.css` is also a symlink, so a runtime switch only needs a Steam
    restart.
  - The installer is skipped while Steam is running (`pgrep -x steam`): Steam
    rewrites `steamui/` on exit and the skin would silently vanish. Close Steam
    and rebuild to apply. A failure is reported on stderr but does not fail the
    activation — no Steam installed is not an error.
  - A Steam client update wipes the skin; the next rebuild puts it back.
  - AdwSteamGtk 0.8.0 passes `--custom-css` without a path; skin 4.4 needs one.
    `gaming.nix` patches that call until nixpkgs ships 0.9.1+. The GUI stays
    usable for a manual re-apply and for editing the CSS.
  - Chat window: the skin styles the layout but leaves Steam's dark-theme text
    (`.msgText` `#c1c6cf`, links `#6dcff6`) on paper. `unit3.css` forces
    `.chatHistory` to ink/rust; the dark `.chatEntry` input bar is intentionally
    left alone.
- btop:
  - `main/themes/btop/unit3.theme`
  - `main/home/btop.nix`
  - `btop` normal is opaque paper.
  - `btop-paper` opens a dedicated Kitty window with a translucent paper
    background; `BTOP_OPACITY=0.30` means 70% transparent, `0.85` is more
    opaque. Text stays opaque because Kitty opacity applies to the
    background.
- Rofi clipboard:
  - `main/home/rofi/clipboard.rasi`
  - `main/home/scripts/scripts/clipboard.sh`
  - `SUPER+V`; uses `cliphist`/`wl-copy`.

## Repository status / workflow

- Work happens on branch `dev`; `main` keeps the published state. Merge into
  `main` only after the user has reviewed the branch.
- Cleanup on `dev`: removed the dead `quickshell/theme/` singleton, the
  superseded `waybar/style.css` + `config.jsonc` copies and `flake.lock.back`,
  and fixed the stale `nh` flake path. Details in `main/themes/unit3/NOTES.md`.
- The DSH wrapper is `main/home/deepseek-harness.nix`, imported in
  `main/home/default.nix`. It is pinned to
  `@deepseek-ai/dsh@0.2.1-rc.5` and uses the official Node.js 24.21.0
  tarball from nodejs.org, installed verbatim (no `autoPatchelfHook`; that
  broke the binary in ld.so). The official unpatched Node passes
  `node-addon-require-builtin`; Nixpkgs Node's leaf frame pointer does not.
  First run still needs network for `npx`; this is a wrapper, not a full
  offline Nix package.
- Check changes with:

```bash
git status --short
git diff -- main/themes/gtk/unit3.css
```

- Do not commit secrets or `hardware-configuration.nix`.
- New themes should be added to Git before publishing; `path:` only helps
  local builds.

## Status

- GIMP, gsimplecal, Nemo and the browser checked on 2026-11-01 after the
  rebuild: paper theme, rust selection, dark menu text — all correct.
- No known open UI issues. The calendar override was verified with a headless
  GTK render before the rebuild; see `.dsh/skills/gtk-style-probe`.

## Working rules

- One file, one session: `unit3.css` and all GTK apps stay in the GTK thread.
- Shell work (Waybar, Quickshell, rofi) is a separate thread — different stack,
  different tools, different restart cycle.
- Anything that must survive a session goes into this file or a skill, never
  into the chat.
- Update this handoff when architecture, binds or the theme state change.

## DSH note

DeepSeek Harness is a separate agent harness, not a new model. It does not
inherit the current pi session history. The repo, git diff, README and this
file are the handoff; use them instead of relying on the old chat.
