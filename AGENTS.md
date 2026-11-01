# Handoff — NixOS Rice / Unit-3

This file is a handoff for another agent (DeepSeek Harness / DSH) or a future
session. The repository is the source of truth; this is the working context.

## Project

- Personal NixOS + Home Manager + Hyprland rice in the `Unit-3` style.
- Host repo: `/home/chu/agent-workspace/workspace/rice`
- Container repo: `/workspace/workspace/rice`
- Host user: `chu`; host: `chebupel`
- Hyprland 0.56.2, Quickshell 0.3.2, nixpkgs rev
  `3ec636362e1816bc2f0888fa0fa2c69f1bc9e504`.
- Main build command (on the host, not inside the container):

```bash
cd ~/agent-workspace/workspace/rice
sudo nixos-rebuild switch --flake "path:.#default"
```

`path:` is deliberate: local ignored files such as `main/core/stoat.nix`,
`main/home/git.nix` and `main/hardware-configuration.nix` must be visible to the
build but must not be published. Never replace it with a plain Git flake.

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
- **Open issue:** GIMP menu items with hierarchy
  `menuitem > box.horizontal > label` inherited light grey from Colloid
  `common.css:285:18` (`color: #dcdcdc`). Targeted rules were added for
  `menuitem > box.horizontal` / its label, plus hover and disabled variants.
  After rebuilding, fully restart GIMP and verify. Do not reintroduce the
  broad `menuitem box` block.
- GTK Inspector custom CSS is a `<data>` provider and can override the file.
  Use Pause/disable it when checking the real theme.
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

- All theme files are tracked in the current commit except
  `main/home/deepseek-harness.nix` (new wrapper).
- The DSH wrapper is `main/home/deepseek-harness.nix`, imported in
  `main/home/default.nix`. It is pinned to
  `@deepseek-ai/dsh@0.2.1-rc.5` and uses `npx` + Node 24; first run needs
  network. It is deliberately a wrapper, not a full offline Nix package.
- Check changes with:

```bash
git status --short
git diff -- main/themes/gtk/unit3.css
```

- Do not commit secrets or `hardware-configuration.nix`.
- New themes should be added to Git before publishing; `path:` only helps
  local builds.

## Immediate next steps

1. Rebuild on the host and fully restart GIMP.
2. Verify the GIMP `menuitem > box.horizontal > label` menu text is dark on
   paper, with rust hover/selected and grey disabled.
3. Verify Nemo selection and rubberband after the latest CSS edits.
4. If GIMP still fails, inspect in GTK Inspector:
   - `label`/`box` `Style Classes`;
   - `color` value and `Location`;
   - parent state (`:disabled`, `:hover`, `:selected`);
   - disable any `<data>` custom CSS first.
5. Check `AGENTS.md`/handoff updates if the architecture or binds change.

## DSH note

DeepSeek Harness is a separate agent harness, not a new model. It does not
inherit the current pi session history. The repo, git diff, README and this
file are the handoff; use them instead of relying on the old chat.
