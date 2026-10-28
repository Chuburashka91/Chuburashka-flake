#!/usr/bin/env bash
# Toggle gsimplecal and place it right under the centered Waybar clock.
set -euo pipefail

if pgrep -x gsimplecal >/dev/null; then
  pkill -x gsimplecal
  exit 0
fi

gsimplecal &

addr=""
for _ in $(seq 1 100); do
  addr=$(hyprctl clients -j | jq -r '
    .[] | select(
      ((.class // "") | ascii_downcase) == "gsimplecal"
      or (((.title // "") | ascii_downcase) | contains("gsimplecal"))
      or (((.title // "") | ascii_downcase) | contains("calendar"))
    ) | .address' | head -1)
  [ -n "$addr" ] && break
  sleep 0.02
done

[ -z "$addr" ] && exit 0

read -r w h < <(hyprctl clients -j | jq -r --arg a "$addr" '.[] | select(.address == $a) | "\(.size[0]) \(.size[1])"')
read -r mw mh < <(hyprctl monitors -j | jq -r '.[] | select(.focused) | "\(.width) \(.height)"' | head -1)

x=$(( (mw - w) / 2 ))
y=$(( 28 + 4 ))

hyprctl dispatch movewindowpixel exact "$x" "$y",address:"$addr" >/dev/null 2>&1 || {
  hyprctl dispatch focuswindow "address:$addr" >/dev/null 2>&1
  hyprctl dispatch moveactive exact "$x" "$y" >/dev/null 2>&1
}
