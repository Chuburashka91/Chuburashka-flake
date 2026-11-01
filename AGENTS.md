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

- `label { color: inherit; }` fixes Colloid's hardcoded white labels.
- Menubar: paper background, dark text, rust hover/selected.
- Nemo selection:
  - `.nemo-canvas-item:selected`: `rgba(139, 115, 85, 0.8)` background,
    `#f5f0e6` text.
  - list/treeview selected: `@u3_accent` background, `@u3_paper` text, bold.
  - Nemo rubberband: transparent `rgba(139, 115, 85, 0.3)` with
    `#6B5A45` border.
- GIMP menus (resolved, verified 2026-11-01): items with hierarchy
  `menuitem > box.horizontal > label` inherited light grey from Colloid
  `common.css:285:18` (`color: #dcdcdc`). Targeted rules cover
  `menuitem > box.horizontal` / its label plus hover and disabled variants.
  Do not reintroduce the broad `menuitem box` block.
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

- Quickshell/QML widgets carry the paper colours inline (`#463f2e`, `#d6cfb5`,
  `#6e2a2a`). The old `quickshell/theme/Theme.qml` singleton (NieR colours,
  never imported by anything) was deleted during cleanup — do not recreate it.
- Waybar is intentionally the only dark surface: `rgba(11, 10, 9, 0.92)` in
  `main/home/waybar/style.nix`. It reads as a bar over the wallpaper.
- `main/home/swaync/style.css` still holds gruvbox colours, but `exec-once`
  never starts swaync.

### Application themes

- Vencord/Vesktop:
  - `main/themes/vencord/unit3.theme.css`
  - linked by `main/home/discord.nix` to Vencord and Vesktop local themes.
  - Enable in Vencord: Settings → Themes → Local Themes → Unit-3.
  - **Use the light Discord theme** with this local theme, otherwise some
    tokens are overridden. Reload with Ctrl+R after CSS changes.
- Zen Browser:
  - `main/themes/zen/userChrome.css`, `userContent.css`
  - loaded by `main/home/browser.nix`.
  - Profile path is currently `uf1assfh.Default Profile`.
  - Zen workspace themes are part of workspace state, not this CSS; a
    generated `chrome/zen-themes.css` can override colors. Use neutral
    workspace colors if a consistent Unit-3 look is wanted.
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
