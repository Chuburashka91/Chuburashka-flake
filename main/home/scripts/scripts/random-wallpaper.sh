#!/usr/bin/env bash

style_file="${XDG_CONFIG_HOME:-$HOME/.config}/unit3/style"
style="$(cat "$style_file" 2>/dev/null || echo unit3)"
case "$style" in
    unit3|gaming|space|mimimi) ;;
    *) style=unit3 ;;
esac

wallpaper_path="$HOME/Pictures/wallpapers"
wallpapers_folder="$wallpaper_path/$style"
[ -d "$wallpapers_folder" ] || wallpapers_folder="$wallpaper_path/others"

current_wallpaper=$(readlink "$wallpaper_path/wallpaper" 2> /dev/null)
current_wallpaper_name="$(basename "$current_wallpaper")"

mapfile -t wallpaper_list < <(find "$wallpapers_folder" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) 2>/dev/null | sort)
wallpaper_count=${#wallpaper_list[@]}
[ "$wallpaper_count" -gt 0 ] || exit 0

# With a single wallpaper the old loop never terminated.
if [ "$wallpaper_count" -eq 1 ]; then
    wallpaper_name="${wallpaper_list[0]}"
else
    while true; do
        wallpaper_name="${wallpaper_list[RANDOM % wallpaper_count]}"

        if [[ "$(basename "$wallpaper_name")" != "$current_wallpaper_name" ]]; then
            break
        fi
    done
fi

ln -sfn "$wallpaper_name" "$wallpaper_path/wallpaper"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/unit3"
printf '%s\n' "$wallpaper_name" > "${XDG_CONFIG_HOME:-$HOME/.config}/unit3/wallpaper"
wall-change "$wallpaper_path/wallpaper" &
