#!/usr/bin/env bash
# Create the 5 workspaces on DP-1 and 5 on DP-2, then focus 1 and 6.
set -euo pipefail

for ws in 1 2 3 4 5 6 7 8 9 10; do
  hyprctl dispatch workspace "$ws" >/dev/null 2>&1 || true
done
hyprctl dispatch workspace 6 >/dev/null 2>&1 || true
hyprctl dispatch workspace 1 >/dev/null 2>&1 || true
