{ pkgs, ... }:
{
  programs = {
    dconf.enable = true;
    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      # pinentryFlavor = "";
    };

    appimage.enable = true;

    # KDE Connect for ControlCenter quickshare (installs kdePackages.kdeconnect-kde
    # and opens TCP/UDP 1714-1764).
    kdeconnect.enable = true;

    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [ ];
  };
}
