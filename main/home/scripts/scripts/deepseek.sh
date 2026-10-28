#!/usr/bin/env bash
# deepseek rice|b4 — resume a pi session on DeepSeek.
#
# Installed into PATH by home-manager (main/home/scripts/scripts.nix).
# Run on the HOST against the rootless Podman container "pi-agent".
set -euo pipefail

CONTAINER="${PI_CONTAINER:-pi-agent}"
RICE_SESSION="${DEEPSEEK_RICE_SESSION:-/workspace/workspace/rice/.pi/rice-session.jsonl}"
B4_SESSION="${DEEPSEEK_B4_SESSION:-/workspace/workspace/rice/.pi/b4-session.jsonl}"
MODEL="${DEEPSEEK_MODEL:-deepseek-v4-flash}"
PROVIDER="${DEEPSEEK_PROVIDER:-deepseek}"

run_pi() {
  podman exec -it "$CONTAINER" pi "$@"
}

session=""
model="$MODEL"
case "${1:-}" in
  rice)
    session="$RICE_SESSION"
    model="${DEEPSEEK_RICE_MODEL:-$MODEL}"
    shift
    ;;
  b4)
    session="$B4_SESSION"
    model="${DEEPSEEK_B4_MODEL:-$MODEL}"
    shift
    ;;
esac

if [[ -n "$session" ]]; then
  if podman exec "$CONTAINER" test -f "$session"; then
    run_pi --provider "$PROVIDER" --model "$model" --session "$session" "$@"
  else
    echo "deepseek: session not found: $session" >&2
    echo "deepseek: starting a fresh session instead" >&2
    run_pi --provider "$PROVIDER" --model "$model" "$@"
  fi
else
  run_pi --provider "$PROVIDER" --model "$model" "$@"
fi
