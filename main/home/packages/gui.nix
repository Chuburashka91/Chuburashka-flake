{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Multimedia
    audacity
    gimp
    media-downloader
    #obs-studio
    pavucontrol
    video-trimmer
    vlc
    gnome-clocks
    newsflash

    ## Office
    libreoffice
    gnome-calculator

    ## Utility
    dconf-editor
    gnome-disk-utility
    popsicle
    mission-center # GUI resources monitor
    zenity
    gsimplecal

    ## Связь
    telegram-desktop

    ## Level editor
    ldtk
    tiled
  ];

  xdg.configFile."gsimplecal/config".text = ''
    show_week_numbers = true
  '';
}
