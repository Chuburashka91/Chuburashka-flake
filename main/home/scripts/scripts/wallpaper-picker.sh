#!/usr/bin/env bash

style_file="${XDG_CONFIG_HOME:-$HOME/.config}/unit3/style"
style="$(cat "$style_file" 2>/dev/null || echo unit3)"
case "$style" in
    unit3|gaming|space|mimimi) ;;
    *) style=unit3 ;;
esac

wallpaper_path=$HOME/Pictures/wallpapers
wallpapers_folder=$HOME/Pictures/wallpapers/$style
[ -d "$wallpapers_folder" ] || wallpapers_folder=$HOME/Pictures/wallpapers/others
wallpaper_name="$(find "$wallpapers_folder" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' 2>/dev/null | rofi -dmenu || pkill rofi)"

if [[ -n "$wallpaper_name" && -f "$wallpapers_folder/$wallpaper_name" ]]; then
    ln -sfn "$wallpapers_folder/$wallpaper_name" "$wallpaper_path/wallpaper"
    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/unit3"
    mkdir -p "$config_dir"
    printf '%s\n' "$wallpapers_folder/$wallpaper_name" > "$config_dir/wallpaper"
    wall-change "$wallpaper_path/wallpaper"
else
    exit 1
fi
