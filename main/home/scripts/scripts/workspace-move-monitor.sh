#!/usr/bin/env bash
# Move the active window to the active workspace of the monitor on the left/right.
set -euo pipefail

dir=${1:-right}
focused=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
fx=$(hyprctl monitors -j | jq -r --arg m "$focused" '.[] | select(.name == $m) | .x')

if [ "$dir" = "left" ]; then
  target=$(hyprctl monitors -j | jq -r --argjson fx "$fx" '[.[] | select(.x < $fx)] | sort_by(.x) | last | .name // empty')
else
  target=$(hyprctl monitors -j | jq -r --argjson fx "$fx" '[.[] | select(.x > $fx)] | sort_by(.x) | first | .name // empty')
fi

[ -z "$target" ] && exit 0

ws=$(hyprctl monitors -j | jq -r --arg m "$target" '.[] | select(.name == $m) | .activeWorkspace.id')
hyprctl dispatch movetoworkspace "$ws" >/dev/null
