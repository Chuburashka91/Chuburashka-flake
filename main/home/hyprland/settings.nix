{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    input = {
      # Keep Russian layout; Unit-3 uses plain "us".
      kb_layout = "us,ru";
      kb_options = "grp:win_space_toggle";

      numlock_by_default = true;
      repeat_delay = 300;

      # 2 = pointer focus follows the window under the cursor, but keyboard
      # focus stays put until a click. Scroll goes to the hovered window.
      follow_mouse = 2;
      float_switch_override_focus = 0;
      sensitivity = 0;

      touchpad = {
        natural_scroll = true;
        disable_while_typing = false;
      };
    };

    # Visuals ported from samyns/Unit-3 (MIT).
    general = {
      gaps_in = 4;
      gaps_out = 8;
      border_size = 1;
      "col.active_border" = "rgba(c8b89aee)";
      "col.inactive_border" = "rgba(1a1814aa)";
      layout = "dwindle";
    };

    decoration = {
      rounding = 0;

      blur.enabled = false;
      shadow.enabled = false;
    };

    animations = {
      enabled = true;

      bezier = [ "niercurve, 0.4, 0, 0.2, 1" ];

      animation = [
        "windows, 1, 4, niercurve, slide"
        "windowsOut, 1, 3, niercurve, slide"
        "fade, 1, 4, niercurve"
        "workspaces, 1, 5, niercurve, slidevert"
      ];
    };

    dwindle = {
      preserve_split = true;
    };

    master = {
      new_status = "master";
      mfact = 0.55;
    };

    scrolling = {
      column_width = 0.5;
      fullscreen_on_one_column = 0;
    };

    misc = {
      disable_hyprland_logo = true;
      middle_click_paste = false;
      focus_on_activate = true;
    };

    plugin.hyprtasking = {
      layout = "grid";
      gap_size = 10;
      bg_color = 4278913545;
      border_size = 2;
      exit_on_hovered = false;
      warp_on_move_window = 1;
      close_overview_on_reload = false;

      jump = {
        enabled = true;
        show_workspace_names = false;
        label_color = 4294967295;
        label_background = 204;
        label_size = 32;
      };

      grid = {
        rows = 2;
        cols = 3;
        loop = true;
        layers = 1;
        loop_layers = true;
        gaps_use_aspect_ratio = true;
      };

      gestures = {
        enabled = true;
        move_fingers = 3;
        move_distance = 300;
        open_fingers = 4;
        open_distance = 300;
        open_positive = true;
      };
    };

    xwayland = {
      force_zero_scaling = true;
    };
  };
}
