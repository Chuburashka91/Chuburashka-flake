#!/usr/bin/env bash
# Unit-3 clipboard history picker (cliphist + rofi).

set -u

theme="${XDG_CONFIG_HOME:-$HOME/.config}/rofi/clipboard.rasi"

selected="$(cliphist list | head -n 200 | rofi -dmenu -i -no-custom -display-columns 2 -font "Maple Mono 12" -p "БУФЕР" -theme "$theme")" || exit 0

[[ -n "$selected" ]] || exit 0

printf '%s\n' "$selected" | cliphist decode | wl-copy
