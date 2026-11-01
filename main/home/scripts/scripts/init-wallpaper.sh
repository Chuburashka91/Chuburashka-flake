#!/usr/bin/env bash

# Start awww daemon if not running
if ! pgrep -x awww-daemon > /dev/null; then
    awww-daemon --no-cache &

    # Wait until the daemon is ready
    while ! awww query > /dev/null 2>&1; do
        sleep 0.1
    done
fi

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/unit3"
style_file="$config_dir/style"
style="$(cat "$style_file" 2>/dev/null || echo unit3)"
case "$style" in
    unit3|gaming|space|mimimi) ;;
    *) style=unit3 ;;
esac

wallpaper_path="$HOME/Pictures/wallpapers"
style_dir="$wallpaper_path/$style"
[ -d "$style_dir" ] || style_dir="$wallpaper_path/others"

# Prefer the exact wallpaper remembered at the last switch/logout.
saved="$(cat "$config_dir/wallpaper" 2>/dev/null || true)"
chosen=""
if [[ -n "$saved" && -f "$saved" && "$saved" == "$style_dir/"* ]]; then
    chosen="$saved"
fi

current="$(readlink "$wallpaper_path/wallpaper" 2>/dev/null || true)"
if [[ -z "$chosen" && -n "$current" && -f "$current" && "$current" == "$style_dir/"* ]]; then
    chosen="$current"
fi

if [[ -z "$chosen" ]]; then
    mapfile -t wallpapers < <(find "$style_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort)
    if [ "${#wallpapers[@]}" -gt 0 ]; then
        chosen="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
    fi
fi

if [[ -n "$chosen" ]]; then
    ln -sfn "$chosen" "$wallpaper_path/wallpaper"
    mkdir -p "$config_dir"
    printf '%s\n' "$chosen" > "$config_dir/wallpaper"
fi

# Set wallpaper
awww img -t none "$wallpaper_path/wallpaper" &
