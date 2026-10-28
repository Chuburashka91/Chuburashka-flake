#!/usr/bin/env bash
# Toggle the ControlCenter (loaded in the main Quickshell instance).
pkill cloudflared 2>/dev/null || true
exec qs ipc call ctrl toggle
