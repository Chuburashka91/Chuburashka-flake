#!/usr/bin/env bash
# Atomically switch palette (if needed), remember the chosen image and apply it.
# Waits for awww instead of leaving a half-finished client behind when the
# picker closes. If the awww daemon died on a large image, restart it and
# retry once.
set -u

style="${1:-}"
file="${2:-}"
monitor="${3:-both}"

if [[ -z "$style" || -z "$file" || ! -f "$file" ]]; then
    echo "usage: wallpaper-apply <style> <image> [monitor|both]" >&2
    exit 2
fi

user="$(id -un)"
profile_bin="/etc/profiles/per-user/$user/bin"
palette_bin="$profile_bin/unit3-palette"
awww_bin="$profile_bin/awww"
awww_daemon_bin="$profile_bin/awww-daemon"
[[ -x "$palette_bin" ]] || palette_bin="$(command -v unit3-palette || true)"
[[ -x "$awww_bin" ]] || awww_bin="$(command -v awww || true)"
[[ -x "$awww_daemon_bin" ]] || awww_daemon_bin="$(command -v awww-daemon || true)"
[[ -x "$awww_bin" ]] || { echo "awww not found" >&2; exit 4; }

if [[ -n "$palette_bin" && "$("$palette_bin" current 2>/dev/null || true)" != "$style" ]]; then
    "$palette_bin" set "$style" >/dev/null 2>&1 || true
fi
[[ -n "$palette_bin" ]] && "$palette_bin" remember "$file" >/dev/null 2>&1 || true

ensure_daemon() {
    pgrep -x awww-daemon >/dev/null 2>&1 && return 0
    [[ -x "$awww_daemon_bin" ]] || return 1
    "$awww_daemon_bin" --no-cache >/dev/null 2>&1 &
    for _ in $(seq 1 50); do
        "$awww_bin" query >/dev/null 2>&1 && return 0
        sleep 0.1
    done
    return 1
}

apply_image() {
    if [[ -z "$monitor" || "$monitor" == "both" ]]; then
        timeout 30 "$awww_bin" img "$file"
    else
        timeout 30 "$awww_bin" img --outputs "$monitor" "$file"
    fi
}

verify_image() {
    sleep 0.25
    "$awww_bin" query 2>/dev/null | grep -qF "$file"
}

ensure_daemon || true
if ! apply_image || ! verify_image; then
    pkill -x awww-daemon >/dev/null 2>&1 || true
    sleep 0.4
    ensure_daemon || true
    apply_image
fi
