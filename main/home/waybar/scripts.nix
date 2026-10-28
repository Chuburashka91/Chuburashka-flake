{ ... }:
{
  # Pomodoro helpers referenced by config.jsonc.
  home.file.".config/waybar/scripts/pomodoro.sh" = {
    source = ../../themes/unit3/waybar/scripts/pomodoro.sh;
    executable = true;
  };

  home.file.".config/waybar/scripts/pomodoro_toggle.sh" = {
    source = ../../themes/unit3/waybar/scripts/pomodoro_toggle.sh;
    executable = true;
  };
}
