{ pkgs, ... }:
let
  hyprtasking = pkgs.hyprlandPlugins.hyprtasking.overrideAttrs (old: {
    # hyprtasking builds against Hyprland's installed headers.
    # mkHyprlandPlugin only passes the `out` output; include `dev` as well.
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.hyprland.dev ];
  });
in
{
  home.packages = with pkgs; [
    awww
    mpvpaper
    grimblast
    hyprpicker
    grim
    slurp
    wl-clip-persist
    cliphist
    wf-recorder
    glib
    wayland
    direnv
    tesseract
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    configType = "hyprlang";
    plugins = [ hyprtasking ];

    xwayland = {
      enable = true;
      # hidpi = true;
    };
    systemd.enable = true;
  };
}
