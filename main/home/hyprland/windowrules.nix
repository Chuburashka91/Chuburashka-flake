{ ... }:
{
  # Window rules ported from samyns/Unit-3 (MIT).
  # The quickshell / qs-yazi-picker rules are harmless until L2/L3.
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "float on, match:class ^(quickshell)$"
      "pin on, match:class ^(quickshell)$"
      "no_blur on, match:class ^(quickshell)$"
      "no_shadow on, match:class ^(quickshell)$"

      "float on, match:class ^(gsimplecal)$"
      "float on, match:title ^(gsimplecal)$"

      "workspace special:spotify, match:class ^(Spotify)$"
      "fullscreen on, match:class ^(Spotify)$"

      "float on, match:class ^(qs-yazi-picker)$"
      "size 900 600, match:class ^(qs-yazi-picker)$"
      "center 1, match:class ^(qs-yazi-picker)$"
    ];
  };
}
