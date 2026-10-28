{ lib, ... }:
{
  imports =
    [
      ./cli
      ./bat.nix
      ./browser.nix
      ./direnv.nix
      ./discord.nix
      ./fastfetch/fastfetch.nix
      ./fzf.nix
      ./fonts.nix
      ./gaming.nix
    ]
    ++ lib.optional (builtins.pathExists ./git.nix) ./git.nix
    ++ [
      ./gnome.nix
      ./gtk.nix
      ./hyprland
      ./lazygit.nix
      ./nemo.nix
      ./neovim.nix
      ./p10k/p10k.nix
      ./packages
      ./quickshell.nix
      ./rofi/rofi.nix
      ./scripts/scripts.nix
      ./ssh.nix
      ./swaylock.nix
      ./swayosd.nix
      ./swaync/swaync.nix
      ./waypaper.nix
      ./xdg-mimes.nix
      ./zsh
      ./waybar
      ./kitty.nix
    ];
}
