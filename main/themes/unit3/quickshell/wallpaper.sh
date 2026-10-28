#!/usr/bin/env bash
# Toggle the Quickshell wallpaper picker.
# Use ~ (not $HOME): the Hyprland exec environment does not always set HOME.
if pgrep -f "WallpaperPicker.qml" >/dev/null; then
  pkill -f "WallpaperPicker.qml"
  exit 0
fi
QT_MEDIA_BACKEND=ffmpeg qs -p ~/.config/quickshell/widgets/WallpaperPicker.qml
