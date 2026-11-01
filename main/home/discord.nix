{ pkgs, config, ... }:
let
  runtimeTheme = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/unit3/active/vencord.css";
in
{
  home.packages = with pkgs; [
    # webcord
    vesktop
  ];

  # Local Vencord theme in the Unit-3 launcher/help style.
  # Enable it in Vencord: Settings -> Themes -> Local Themes.
  xdg.configFile."Vencord/themes/unit3.theme.css" = {
    source = runtimeTheme;
    force = true;
  };

  # Vesktop also looks here for its own theme picker; harmless duplicate.
  xdg.configFile."vesktop/themes/unit3.theme.css" = {
    source = runtimeTheme;
    force = true;
  };
}
