{ username, lib, ... }:
{
  services = {
    xserver = {
      enable = true;
      xkb.layout = "us,ru";
      displayManager.lightdm.enable = lib.mkForce false;
    };

    # No graphical login manager. Boot into a getty autologin on tty1 and
    # start Hyprland from ~/.zprofile. hyprlock (Hyprland exec-once) remains
    # the actual lock/login screen.
    displayManager.sddm.enable = lib.mkForce false;
    displayManager.gdm.enable = lib.mkForce false;
    displayManager.ly.enable = lib.mkForce false;
    greetd.enable = lib.mkForce false;

    getty.autologinUser = username;

    libinput = {
      enable = true;
    };
  };

  # To prevent getting stuck at shutdown
  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
}
