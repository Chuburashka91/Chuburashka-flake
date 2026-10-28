#!/usr/bin/env bash
# Toggle Hyprland tiling for the ACTIVE workspace only:
# dwindle <-> scrolling. Other workspaces are untouched.
set -euo pipefail

ws_json="$(hyprctl activeworkspace -j)"
ws="$(jq -r '.name' <<<"$ws_json")"

# Named workspaces should have a name; fall back to the numeric id.
if [[ -z "$ws" || "$ws" == "null" ]]; then
  ws="$(jq -r '.id' <<<"$ws_json")"
fi

state_dir="${XDG_RUNTIME_DIR:-/tmp}/hypr-layout"
mkdir -p "$state_dir"
state_file="$state_dir/$ws"

# First toggle after login: inherit the global layout.
global="$(hyprctl getoption general:layout -j | jq -r '.str')"
current="$(cat "$state_file" 2>/dev/null || printf '%s' "$global")"

if [[ "$current" == "scrolling" ]]; then
  next="dwindle"
  label="Обычный (dwindle)"
else
  next="scrolling"
  label="Прокрутка (niri-style)"
fi

# Workspace rule with layout: applies only to this workspace.
hyprctl keyword workspace "$ws, layout:$next" >/dev/null
printf '%s\n' "$next" > "$state_file"

notify-send "Тайлинг workspace $ws" "$label" 2>/dev/null || true
