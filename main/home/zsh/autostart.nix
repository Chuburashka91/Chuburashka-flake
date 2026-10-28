{ ... }:
{
  # Boot straight into Hyprland on tty1 (getty autologin).
  # hyprlock is started by Hyprland's exec-once and is the actual lock screen.
  # Other TTYs (tty2+) still give a normal shell for recovery.
  programs.zsh.profileExtra = ''
    if [[ -z "$WAYLAND_DISPLAY" && "$(tty)" == "/dev/tty1" ]]; then
      if [[ -z "$XDG_RUNTIME_DIR" ]]; then
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
      fi
      if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
        mkdir -p "$XDG_RUNTIME_DIR"
        chmod 700 "$XDG_RUNTIME_DIR"
      fi

      if command -v start-hyprland >/dev/null 2>&1; then
        exec start-hyprland
      else
        exec Hyprland
      fi
    fi
  '';
}
