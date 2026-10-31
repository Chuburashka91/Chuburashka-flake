#!/usr/bin/env bash
# btop over a translucent Unit-3 paper background.
# Kitty applies the opacity to the background only; text stays opaque.
# Override the opacity with BTOP_OPACITY if 0.70 is not the right amount.

set -u

opacity="${BTOP_OPACITY:-0.70}"

exec kitty \
  --override background=#d6cfb5 \
  --override foreground=#2e2a1f \
  --override background_opacity="$opacity" \
  --title btop \
  btop -c "$HOME/.config/btop/btop-paper.conf" "$@"
