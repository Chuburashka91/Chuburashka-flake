{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Minecraft
    prismlauncher

    ## Cli games
    #_2048
    #_2048-in-terminal
    #vitetris
    #nethack

    ## Celeste
    # olympus
    # celeste-classic
    # celeste-classic-pm

    ## Doom
    #crispy-doom

    ## Emulation
    cemu
    mgba
    snes9x
    sameboy
    melonds
    dolphin-emu
    cabextract
    unzip
    ## Star Citizen (из nix-gaming)
    #unstable.gamescope
    bubblewrap
    dxvk
    lutris
    vulkan-tools
    qbittorrent
    bottles
    obs-studio
  ];
}

