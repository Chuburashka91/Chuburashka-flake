{ ... }:
{
  # Ported from samyns/Unit-3 (MIT): config/waybar/config.jsonc
  # Kept: tray + keyboard layout (functional, not decorative).
  programs.waybar.settings.mainBar = {
    layer = "top";
    position = "top";
    height = 28;
    spacing = 0;

    modules-left = [
      "hyprland/workspaces"
      "hyprland/window"
      "custom/ticker"
      "tray"
    ];

    modules-center = [ "clock" ];

    modules-right = [
      "custom/pomodoro"
      "cpu"
      "memory"
      "network"
      "pulseaudio"
      "hyprland/language"
      "custom/power"
    ];

    "hyprland/workspaces" = {
      format = "{id}";
      on-click = "activate";
    };

    "hyprland/window" = {
      format = "// {title}";
      max-length = 40;
    };

    "hyprland/language" = {
      leght = "30";
      format = "{}";
      format-ru = "RU";
      format-en = "EN";
      on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
    };

    tray = {
      icon-size = 16;
      spacing = 8;
    };

    cpu = {
      format = "CPU {usage}%";
      interval = 3;
    };

    memory = {
      format = "MEM {percentage}%";
      interval = 3;
    };

    network = {
      format-wifi = "NET {essid}";
      format-ethernet = "ETH {ifname}";
      format-disconnected = "NET --";
      tooltip-format = "{ipaddr}";
    };

    pulseaudio = {
      format = "VOL {volume}%";
      format-muted = "VOL --";
      on-click = "pavucontrol";
    };

    clock = {
      format = "{:%H:%M}";
      format-alt = "{:%H:%M}";
      tooltip-format = "{:%A %d %B %Y}";
      on-click = "calendar";
    };

    "custom/ticker" = {
      exec = "echo '接続中 // SCANNING // データ処理 // SYS:ACTIVE // NR-2B@ARCH // 全システム正常 // 起動完了 //'";
      interval = 60;
      format = "{}";
    };

    "custom/pomodoro" = {
      exec = "~/.config/waybar/scripts/pomodoro.sh";
      interval = 1;
      format = "{}";
      on-click = "~/.config/waybar/scripts/pomodoro_toggle.sh";
    };

    "custom/power" = {
      format = "⏻";
      on-click = "hyprctl dispatch exit";
    };
  };
}
