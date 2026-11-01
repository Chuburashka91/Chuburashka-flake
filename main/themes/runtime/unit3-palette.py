#!/usr/bin/env python3
"""Render and switch the Unit-3 runtime palette.

State lives in ~/.config/unit3:
  palettes/<name>.toml   user-editable palette source
  templates/*.css        CSS templates copied from the repo on activation
  profiles/<name>/       rendered app CSS + qml.json
  active -> profiles/<name>
  style                  current palette name (for wallpaper scripts)

The templates keep the original Unit-3 literals. This script remaps those
literals to the selected palette, so every surface follows palette.toml.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tomllib
from pathlib import Path

HOME = Path(os.environ.get("HOME", str(Path.home())))
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config")) / "unit3"
PALETTES = CONFIG / "palettes"
TEMPLATES = CONFIG / "templates"
PROFILES = CONFIG / "profiles"
ACTIVE = CONFIG / "active"
STYLE = CONFIG / "style"
WALLPAPER_STATE = CONFIG / "wallpaper"

DEFAULT = "unit3"

# Original literal -> palette token. These are identities only; values live
# in palettes/*.toml.
COLOR_MAP: dict[str, str] = {
    "#d6cfb5": "paper",
    "#cbc4a9": "paper2",
    "#c2baa0": "paper3",
    "#b9b096": "paper4",
    "#ded7bf": "paperLight",
    "#f5f0e6": "selectionText",
    "#463f2e": "ink",
    "#2e2a1f": "inkStrong",
    "#7a7358": "inkSoft",
    "#9a9278": "inkMuted",
    "#6e2a2a": "accent",
    "#8a3a3a": "accentSoft",
    "#b85a5a": "accent200",
    "#a04a4a": "accent300",
    "#5a2222": "accent600",
    "#4a1a1a": "accent700",
    "#3a1414": "accent800",
    "#2e1010": "accent900",
    "#4f7a5a": "green",
    "#a07a2a": "gold",
    "#6B5A45": "lineStrong",
    "#242322": "inkStrong",
    "#000000": "spinText",
    "#b5443f": "btopAccent",
    "#c45a55": "btopAccentSoft",
    "#c4953a": "btopGold",
    "#6f9f73": "btopGreen",
    "#b9a98a": "btopPaperDim",
    "#8a8068": "btopInkSoft",
    "#f4ecd8": "btopBright",
    "#cbbd9f": "btopPaper4",
    "#c08a2a": "steamWarning",
    "#6e5216": "steamWarningText",
    "#3f6649": "steamSuccessText",
}

RGBA_MAP: dict[str, tuple[str, str]] = {
    "rgba(139, 115, 85, 0.3)": ("rubber", "0.3"),
    "rgba(139, 115, 85, 0.8)": ("rubber", "0.8"),
    "rgba(70, 63, 46, 0.05)": ("ink", "0.05"),
    "rgba(70, 63, 46, 0.06)": ("ink", "0.06"),
    "rgba(70, 63, 46, 0.08)": ("ink", "0.08"),
    "rgba(70, 63, 46, 0.12)": ("ink", "0.12"),
    "rgba(70, 63, 46, 0.14)": ("ink", "0.14"),
    "rgba(70, 63, 46, 0.18)": ("ink", "0.18"),
    "rgba(70, 63, 46, 0.25)": ("ink", "0.25"),
    "rgba(70, 63, 46, 0.35)": ("ink", "0.35"),
    "rgba(46, 42, 31, 0.25)": ("inkStrong", "0.25"),
    "rgba(46, 42, 31, 0.55)": ("inkStrong", "0.55"),
    "rgba(214, 207, 181, 0.4)": ("paper", "0.4"),
    "rgba(214, 207, 181, 0.96)": ("paper", "0.96"),
    "rgba(203, 196, 169, 0.96)": ("paper2", "0.96"),
    "rgba(194, 186, 160, 0.96)": ("paper3", "0.96"),
    "rgba(185, 176, 150, 0.96)": ("paper4", "0.96"),
    "rgba(110, 42, 42, 0.10)": ("accent", "0.10"),
    "rgba(110, 42, 42, 0.12)": ("accent", "0.12"),
    "rgba(110, 42, 42, 0.15)": ("accent", "0.15"),
    "rgba(110, 42, 42, 0.16)": ("accent", "0.16"),
    "rgba(79, 122, 90, 0.12)": ("green", "0.12"),
}

RADIUS_MAP = {
    "border-radius: 0": "radius",
    "--adw-button-radius: 0": "buttonRadius",
    "--adw-button-pill-radius: 0": "buttonRadius",
    "--adw-alert-dialog-button-radius: 0": "buttonRadius",
    "--adw-card-radius: 0": "radius",
    "--adw-checkbox-radius: 0": "radius",
    "--adw-dialog-radius: 0": "radius",
    "--adw-alert-dialog-radius: 0": "radius",
    "--adw-entry-radius: 0": "radius",
    "--adw-entry-small-radius: 0": "radius",
    "--adw-gameicon-radius: 0": "radius",
    "--adw-menu-radius: 0": "radius",
    "--adw-menu-item-radius: 0": "radius",
    "--radius-xs: 0": "radius",
    "--radius-sm: 0": "radius",
    "--radius-md: 0": "radius",
    "--radius-lg: 0": "radius",
    "--radius-xl: 0": "radius",
    "--radius-xxl: 0": "radius",
    "--radius-round: 0": "radius",
}

BUTTON_RULES = {
    "gtk.css": "button { border-radius: %s; }",
    "vencord.css": 'button, [role="button"] { border-radius: %s !important; }',
    "zenChrome.css": "button, toolbarbutton, .toolbarbutton-1 { border-radius: %s !important; }",
    "steam.css": "button { border-radius: %s !important; }",
}


def hex_to_rgb(value: str) -> str:
    h = value.lstrip("#")
    return f"{int(h[0:2], 16)}, {int(h[2:4], 16)}, {int(h[4:6], 16)}"


def rgb(palette: dict, token: str) -> str:
    return hex_to_rgb(palette[token])


def colorize(text: str, palette: dict) -> str:
    mapping: dict[str, str] = {}
    for literal, token in COLOR_MAP.items():
        mapping[literal] = palette[token]
    for literal, (token, alpha) in RGBA_MAP.items():
        mapping[literal] = f"rgba({rgb(palette, token)}, {alpha})"

    keys = list(mapping)
    sentinels = [f"@@U3_{i}@@" for i in range(len(keys))]
    for key, sentinel in zip(keys, sentinels):
        text = text.replace(key, sentinel)
    for sentinel, key in zip(sentinels, keys):
        text = text.replace(sentinel, mapping[key])
    return text


def radiusize(text: str, palette: dict) -> str:
    for literal, token in RADIUS_MAP.items():
        text = text.replace(literal, literal.rsplit(": 0", 1)[0] + ": " + palette[token])
    return text


def render_template(name: str, palette: dict) -> str:
    source = (TEMPLATES / name).read_text(encoding="utf-8")
    text = radiusize(colorize(source, palette), palette)
    # Vencord/Steam declare a light color-scheme; dark palettes need dark.
    text = text.replace("color-scheme: light", f"color-scheme: {palette['colorScheme']}")

    if name == "zenContent.css":
        text = text.replace(
            "  /* U3_BUTTON_RADIUS */",
            f"  button, .button {{ border-radius: {palette['buttonRadius']} !important; }}",
        )
    elif name in BUTTON_RULES:
        text += "\n" + BUTTON_RULES[name] % palette["buttonRadius"] + "\n"
    return text


def px(value: str) -> int:
    match = re.match(r"\s*(-?\d+)", str(value))
    return int(match.group(1)) if match else 0


def qml_palette(palette: dict) -> str:
    keys = [
        "paper", "paper2", "paper3", "paper4", "paperLight", "selectionText",
        "ink", "inkStrong", "inkSoft", "inkMuted", "accent", "accentSoft",
        "green", "gold", "danger", "black", "overlay",
    ]
    data = {key: palette[key] for key in keys}
    data.update({
        "name": palette["name"],
        "label": palette.get("label", palette["name"]),
        "radius": px(palette["radius"]),
        "buttonRadius": px(palette["buttonRadius"]),
    })
    return json.dumps(data, indent=2) + "\n"


def load_palettes() -> dict[str, dict]:
    result: dict[str, dict] = {}
    for path in sorted(PALETTES.glob("*.toml")):
        with path.open("rb") as handle:
            data = tomllib.load(handle)
        name = data.get("name", path.stem)
        data.setdefault("name", name)
        data.setdefault("label", name)
        data.setdefault("order", 100)
        result[name] = data
    return result


def ordered_names(palettes: dict[str, dict]) -> list[str]:
    return [name for name, _ in sorted(palettes.items(), key=lambda item: (item[1].get("order", 100), item[0]))]


def render(name: str, palette: dict) -> None:
    if not (TEMPLATES / "gtk.css").is_file():
        raise SystemExit(f"missing templates in {TEMPLATES}")

    profile = PROFILES / name
    tmp = PROFILES / f".{name}.tmp"
    if tmp.exists():
        shutil.rmtree(tmp)
    tmp.mkdir(parents=True)

    for filename in ("gtk.css", "vencord.css", "zenChrome.css", "zenContent.css", "steam.css", "btop.theme"):
        (tmp / filename).write_text(render_template(filename, palette), encoding="utf-8")
    (tmp / "qml.json").write_text(qml_palette(palette), encoding="utf-8")

    if profile.exists():
        shutil.rmtree(profile)
    tmp.rename(profile)

    link_tmp = CONFIG / ".active.tmp"
    if link_tmp.exists() or link_tmp.is_symlink():
        link_tmp.unlink()
    os.symlink(Path("profiles") / name, link_tmp)
    os.replace(link_tmp, ACTIVE)

    style_tmp = CONFIG / ".style.tmp"
    style_tmp.write_text(name + "\n", encoding="utf-8")
    os.replace(style_tmp, STYLE)

    # Steam reads the installed skin file, not ~/.config/AdwSteamGtk.
    skin = HOME / ".steam/steam/steamui/adwaita/custom.css"
    if skin.parent.is_dir():
        try:
            if skin.exists() or skin.is_symlink():
                skin.unlink()
            skin.symlink_to((ACTIVE / "steam.css").resolve())
        except OSError:
            pass

    # New processes inherit the style; running ones read the file.
    if shutil.which("hyprctl"):
        subprocess.run(["hyprctl", "setenv", "U3_STYLE", name], capture_output=True, check=False)

    # Visible confirmation for the keybind, but never during activation.
    has_wayland = bool(os.environ.get("WAYLAND_DISPLAY") or os.environ.get("HYPRLAND_INSTANCE_SIGNATURE"))
    if (
        has_wayland
        and os.environ.get("U3_PALETTE_SKIP_WALLPAPER") != "1"
        and shutil.which("notify-send")
    ):
        subprocess.run(
            ["notify-send", "-t", "1500", "Палитра", str(palette.get("label", name))],
            capture_output=True,
            check=False,
        )

    # The wallpaper is deliberately independent of the palette switch:
    # SUPER+SHIFT+P passes --wallpaper for "next style + random wallpaper";
    # the picker selects a file and remembers it explicitly.


def remember_wallpaper(path: str) -> int:
    """Persist the chosen wallpaper and point the legacy symlink at it."""
    image = Path(path).expanduser()
    if not image.is_absolute():
        image = (Path.cwd() / image).resolve()
    if not image.is_file():
        print(f"not a wallpaper file: {image}", file=sys.stderr)
        return 1
    CONFIG.mkdir(parents=True, exist_ok=True)
    WALLPAPER_STATE.write_text(str(image) + "\n", encoding="utf-8")
    link = HOME / "Pictures/wallpapers/wallpaper"
    if link.parent.is_dir():
        try:
            if link.exists() or link.is_symlink():
                link.unlink()
            link.symlink_to(image)
        except OSError:
            pass
    print(image)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(prog="unit3-palette")
    parser.add_argument("command", nargs="?", default="current",
                        choices=["list", "current", "set", "next", "render", "remember"])
    parser.add_argument("name", nargs="?")
    parser.add_argument("--wallpaper", "-w", action="store_true",
                        help="also pick a random wallpaper from the new style folder")
    args = parser.parse_args()

    if args.command == "remember":
        if not args.name:
            parser.error("remember requires a wallpaper path")
        return remember_wallpaper(args.name)

    palettes = load_palettes()
    names = ordered_names(palettes)
    if not names:
        print(f"no palettes in {PALETTES}", file=sys.stderr)
        return 1

    current = STYLE.read_text(encoding="utf-8").strip() if STYLE.exists() else DEFAULT
    if current not in palettes:
        current = names[0]

    if args.command == "list":
        for name in names:
            marker = "*" if name == current else " "
            print(f"{marker} {name}")
        return 0

    if args.command == "current":
        print(current)
        return 0

    if args.command == "next":
        target = names[(names.index(current) + 1) % len(names)]
    elif args.command == "set":
        if not args.name:
            parser.error("set requires a palette name")
        target = args.name
    else:  # render
        target = current

    if target not in palettes:
        print(f"unknown palette: {target} (available: {', '.join(names)})", file=sys.stderr)
        return 1

    render(target, palettes[target])
    if args.wallpaper and shutil.which("random-wallpaper"):
        subprocess.run(["random-wallpaper"], capture_output=True, check=False)
    print(target)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
