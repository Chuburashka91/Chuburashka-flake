{ username, ... }:
{
  # Keybinds ported from samyns/Unit-3 (MIT): config/hypr/hyprland.conf
  # Quickshell app menu / wallpaper are active; ControlCenter/player stay L3.
  wayland.windowManager.hyprland.settings = {
    binds = {
      scroll_event_delay = 100;
      movefocus_cycles_fullscreen = true;
    };

    bind = [
      # ── Quickshell ────────────────────────────────────
      # "$mod, Super_L, exec, echo t >> /tmp/qs-menu"          # app menu (tap SUPER)
      "$mod, Tab, exec, /home/${username}/.config/quickshell/ctrl.sh"
      "$mod, F1, exec, echo t >> /tmp/qs-help"
      # "$mod, Return, exec, echo t >> /tmp/qs-toggle"         # player: skipped
      # "$mod SHIFT, Return, exec, echo t >> /tmp/qs-front"    # player: skipped
      # "$mod, R, exec, pkill -x quickshell || true"           # restart shell

      # ── Screen off/on (no lock) ───────────────────────
      "$mod, L, exec, lock"
      "$mod SHIFT, L, exec, layout-toggle"

      # ── Apps ──────────────────────────────────────────
      "$mod, T, exec, kitty"
      "$mod, Return, exec, kitty" # player skipped
      "$mod, B, exec, zen-beta"
      "$mod, P, exec, /home/${username}/.config/quickshell/wallpaper.sh"
      # "$mod, M, exec, pgrep -x spotify >/dev/null && hyprctl dispatch togglespecialworkspace spotify || spotify"

      # ── L2: Quickshell app menu on SUPER+D (was rofi) ──
      "$mod, D, exec, echo t >> /tmp/qs-menu"
      "$mod, E, exec, nemo"

      # ── Window management ─────────────────────────────
      "$mod, Q, killactive"
      "$mod, F, fullscreen"
      "$mod, V, togglefloating"
      "$mod, Escape, exit"
      "$mod SHIFT, F, fullscreen, 1"

      # ── Focus ─────────────────────────────────────────
      "ALT, Tab, cyclenext"
      "ALT SHIFT, Tab, cyclenext, prev"

      "$mod, left, movefocus, l"
      "$mod, right, movefocus, r"
      "$mod, up, movefocus, u"
      "$mod, down, movefocus, d"

      # ── Workspaces (niri-like) ────────────────────────
      "$mod CTRL, up, exec, workspace-focus up"
      "$mod CTRL, down, exec, workspace-focus down"
      "$mod CTRL, left, exec, workspace-focus-monitor left"
      "$mod CTRL, right, exec, workspace-focus-monitor right"
      "$mod, O, hyprtasking:toggle, cursor"
      ", Escape, hyprtasking:if_active, hyprtasking:toggle cursor"

      # ── Move active window to workspaces ──────────────
      "$mod SHIFT, up, exec, workspace-move up"
      "$mod SHIFT, down, exec, workspace-move down"
      "$mod SHIFT, left, exec, workspace-move-monitor left"
      "$mod SHIFT, right, exec, workspace-move-monitor right"

      # ── Move window inside the tiling (fallback) ──────
      "$mod ALT, left, movewindow, l"
      "$mod ALT, right, movewindow, r"
      "$mod ALT, up, movewindow, u"
      "$mod ALT, down, movewindow, d"

      # ── Special workspace ─────────────────────────────
      "$mod SHIFT, S, movetoworkspace, special:magic"
      "$mod, S, togglespecialworkspace, magic"

      # ── Workspaces (ALT + number) ─────────────────────
      "ALT, 1, workspace, 1"
      "ALT, 2, workspace, 2"
      "ALT, 3, workspace, 3"
      "ALT, 4, workspace, 4"
      "ALT, 5, workspace, 5"
      "ALT, 6, workspace, 6"
      "ALT, 7, workspace, 7"
      "ALT, 8, workspace, 8"
      "ALT, 9, workspace, 9"
      "ALT, 0, workspace, 10"

      # ── Move window to workspace ──────────────────────
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"

      # ── Scroll workspaces ─────────────────────────────
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"

      # ── Screenshots (use the existing screenshot helper) ──
      "ALT SHIFT, S, exec, screenshot --copy"
      ", Print, exec, screenshot --save"
    ];

    bindm = [
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindl = [
      ", switch:on:Lid Switch, exec, hyprctl dispatch dpms off"
      ", switch:off:Lid Switch, exec, hyprctl dispatch dpms on"
    ];
  };
}
