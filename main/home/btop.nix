{ ... }:
{
  xdg.configFile."btop/themes/unit3.theme".source = ../themes/btop/unit3.theme;

  xdg.configFile."btop/btop.conf".text = ''
    # Unit-3 btop settings. The palette lives in themes/unit3.theme.
    color_theme = "unit3"
    theme_background = True
    truecolor = True
    rounded_corners = False
  '';

  # Transparent-paper variant used by the `btop-paper` launcher.
  # theme_background=False leaves the background to Kitty, where text stays
  # opaque while the background gets the requested opacity.
  xdg.configFile."btop/btop-paper.conf".text = ''
    color_theme = "unit3"
    theme_background = False
    truecolor = True
    rounded_corners = False
  '';
}
