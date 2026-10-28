#!/usr/bin/env bash
# List .desktop entries for the Quickshell app menu.
# NixOS-aware: there is no /usr/share/applications, so scan XDG_DATA_DIRS,
# the system profile and the per-user profile as well.
set -u

dirs=()
dirs+=("${XDG_DATA_HOME:-$HOME/.local/share}/applications")
dirs+=(/run/current-system/sw/share/applications)
dirs+=("/etc/profiles/per-user/${USER}/share/applications")

IFS=: read -r -a xdg_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
for d in "${xdg_dirs[@]}"; do
  dirs+=("$d/applications")
done

{
  for d in "${dirs[@]}"; do
    [ -d "$d" ] || continue
    for f in "$d"/*.desktop; do
      [ -f "$f" ] || continue

      name=$(grep -m1 '^Name=' "$f" | cut -d= -f2-)
      exec=$(grep -m1 '^Exec=' "$f" | cut -d= -f2- | sed 's/ %[A-Za-z]//g')
      cats=$(grep -m1 '^Categories=' "$f" | cut -d= -f2-)
      nod=$(grep -m1 '^NoDisplay=' "$f" | cut -d= -f2-)
      hid=$(grep -m1 '^Hidden=' "$f" | cut -d= -f2-)

      [ "$nod" = "true" ] && continue
      [ "$hid" = "true" ] && continue
      [ -z "$name" ] && continue
      [ -z "$exec" ] && continue

      desktop=$(basename "$f" .desktop)
      echo "$name|$desktop|$cats|$exec"
    done
  done
} | sort -u
