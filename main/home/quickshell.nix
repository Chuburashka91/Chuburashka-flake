{ pkgs, lib, ... }:
let
  quickshellSrc = ../themes/unit3/quickshell;
  py = pkgs.python3.withPackages (ps: [ ps.qrcode ps.pillow ]);
in
{
  # Quickshell shell: app menu (SUPER+D), wallpaper picker (SUPER+P),
  # volume bar, notifications, ControlCenter (SUPER+Tab), Companions.
  # Player and the Quickshell lockscreen are intentionally not used.
  home.packages = with pkgs; [
    quickshell
    gtk4-layer-shell
    py             # python3 + qrcode/pillow for ControlCenter quickshare
    pulseaudio     # pactl for VolumeBar / ControlCenter audio
    yazi           # ControlCenter file picker
    cloudflared    # quickshare tunnel
    qrencode       # quickshare QR
    bluez          # bluetoothctl for ControlCenter
  ];

  # Copy (not symlink) so Unit-3 scripts can write generated files into
  # ~/.config/quickshell (the Nix store is read-only).
  # Copy in place instead of rm -rf: a running Quickshell must not see
  # shell.qml disappear during activation and fail its reload.
  home.activation.quickshellConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -e
    target="$HOME/.config/quickshell"
    src="${quickshellSrc}"

    if [ -n "$DRY_RUN_CMD" ]; then
      echo "would refresh $target from $src"
    else
      mkdir -p "$target"
      cp -r "$src"/. "$target"/
      chmod -R u+rwX "$target"
      chmod u+x "$target"/*.sh
    fi
  '';
}
