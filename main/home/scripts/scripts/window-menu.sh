#!/usr/bin/env bash
set -euo pipefail

clients="$(hyprctl clients -j)"

mapfile -t rows < <(
  jq -r '.[] | [
    (if (.workspace.name // "") == "" then (.workspace.id | tostring) else .workspace.name end),
    .class,
    .title,
    .address
  ] | @tsv' <<<"$clients"
)

[ "${#rows[@]}" -eq 0 ] && exit 0

choice="$(printf '%s\n' "${rows[@]}" | rofi -dmenu -i -p "Окна" \
  -theme ~/.config/rofi/config.rasi -display-columns 1,2,3)" || exit 0

[ -z "$choice" ] && exit 0

address="$(awk -F'\t' '{print $NF}' <<<"$choice")"
hyprctl dispatch focuswindow "address:$address"
