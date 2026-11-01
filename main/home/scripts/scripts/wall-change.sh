#!/usr/bin/env bash

# `awww` transitions allocate extra buffers. For GIFs that is both pointless
# (the animation itself is the effect) and the source of large temporary RSS
# spikes, so switch GIFs without a transition.
target="$(readlink -f -- "${1:-}" 2>/dev/null || printf '%s' "${1:-}")"
if [[ "${target,,}" == *.gif ]]; then
    awww img --transition-type=none "${1:-}" &
    exit 0
fi

animations=("outer" "center" "any" "wipe")
random_animation=${animations[RANDOM % ${#animations[@]}]}

if [[ "$random_animation" == "wipe" ]]; then
    awww img --transition-type="wipe" --transition-angle=135 "${1:-}" &
else
    awww img --transition-type="$random_animation" "${1:-}" &
fi
