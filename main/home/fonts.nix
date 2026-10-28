{ pkgs, ... }:
{
  # Profile fonts used by Waybar/Quickshell (Noto CJK is needed for the
  # Japanese ticker text). The terminal keeps its own font (Maple Mono).
  fonts.fontconfig.enable = true;

  home.packages = [
    (pkgs.callPackage ../pkgs/share-tech-mono.nix { })
    pkgs.noto-fonts-cjk-sans
  ];
}
