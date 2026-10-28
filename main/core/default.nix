{ lib, ... }:
{
  imports =
    [
      # system
      ./system.nix
      ./user.nix
      ./bootloader.nix
      ./hardware.nix
      ./xserver.nix
      ./wayland.nix
      ./network.nix
      ./bluetooth.nix
      ./pipewire.nix
      ./program.nix
      ./security.nix
      ./services.nix
      ./nh.nix

      # secrets / auth
      ./soap.nix

      # gaming
      ./steam.nix

      # virtualisation / containers
      ./virtualization.nix
      ./docker.nix
      ./pi.nix
      ./b4-docker.nix
    ]
    ++ lib.optional (builtins.pathExists ./stoat.nix) ./stoat.nix
    ++ [
      # disabled (keep commented until wired up)
      # ./flatpak.nix   # requires inputs.nix-flatpak (not declared in flake.nix)
      # ./piper.nix
      # ./fonts.nix     # not wired in yet
    ];
}
