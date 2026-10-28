{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    settings = {
      monitor = [ ",preferred,auto,auto" ];

      # 5 workspaces per monitor: DP-1 = 1..5, DP-2 = 6..10.
      workspace = [
        "1, monitor:DP-1, default:true"
        "2, monitor:DP-1"
        "3, monitor:DP-1"
        "4, monitor:DP-1"
        "5, monitor:DP-1"
        "6, monitor:DP-2, default:true"
        "7, monitor:DP-2"
        "8, monitor:DP-2"
        "9, monitor:DP-2"
        "10, monitor:DP-2"
      ];
    };

    extraConfig = ''
      # hyprlang noerror true
        source = ~/.config/hypr/monitors.conf
      # hyprlang noerror false
    '';
  };

  home.packages = with pkgs; [ nwg-displays ];
}
