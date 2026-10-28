#!/usr/bin/env bash
# Move focus up/down inside the current monitor's 5-workspace stack.
set -euo pipefail

dir=${1:-down}
focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
case "$focused" in
  DP-1) base=1 ;;
  DP-2) base=6 ;;
  *)    base=1 ;;
esac

active=$(hyprctl monitors -j | jq -r --arg m "$focused" '.[] | select(.name == $m) | .activeWorkspace.id')
lvl=$((active - base + 1))
[ "$lvl" -lt 1 ] && lvl=1
[ "$lvl" -gt 5 ] && lvl=5

if [ "$dir" = "up" ]; then
  lvl=$((lvl - 1)); [ "$lvl" -lt 1 ] && lvl=5
else
  lvl=$((lvl + 1)); [ "$lvl" -gt 5 ] && lvl=1
fi

hyprctl dispatch workspace $((base + lvl - 1)) >/dev/null
