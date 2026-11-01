{ pkgs, lib, config, ... }:
let
  # The skin is not in nixpkgs; this builds it and exposes the upstream CLI
  # installer. AdwSteamGtk is the graphical installer/updater for the same skin.
  adwaita-for-steam = pkgs.callPackage ../pkgs/adwaita-for-steam.nix { };

  # nixpkgs ships AdwSteamGtk 0.8.0, which calls the installer with
  # `--custom-css` and no path. Skin 4.4 requires a path, so the GUI's
  # "Custom CSS" toggle would make the install fail. Hand it the file it
  # already copies to its extraction directory. Drop when nixpkgs >= 0.9.1.
  adwsteamgtk = pkgs.adwsteamgtk.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/install.py \
        --replace-fail 'custom_css = "--custom-css "' 'custom_css = f"--custom-css {paths.CUSTOM_CSS_FILE}"'
    '';
  });
in
{
  # AdwSteamGtk reads this symlink; the runtime renderer rewrites its target
  # when the palette changes. The GUI's "Edit" button follows the symlink.
  xdg.configFile."AdwSteamGtk/custom.css" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/unit3/active/steam.css";
    force = true;
  };

  # Steam rewrites steamui/ on updates, so re-apply the skin on rebuild. The
  # installed skin's custom.css is a symlink to the active palette; a runtime
  # switch only needs a Steam restart.
  home.activation.adwSteamCss = lib.hm.dag.entryAfter [ "writeBoundary" "unit3Palette" ] ''
    set -e
    if [ -n "$DRY_RUN_CMD" ]; then
      echo "would apply the Adwaita-for-Steam skin"
    else
      if ${pkgs.procps}/bin/pgrep -x steam >/dev/null 2>&1; then
        echo "adwaita-for-steam: Steam is running, skin NOT applied — close Steam and rebuild (or run: adwaita-for-steam --custom-css ~/.config/AdwSteamGtk/custom.css)" >&2
      else
        ${adwaita-for-steam}/bin/adwaita-for-steam \
          --custom-css "$HOME/.config/AdwSteamGtk/custom.css" \
          || echo "adwaita-for-steam: install failed (Steam not found?) — custom.css is still in place" >&2
      fi

      skin="$HOME/.steam/steam/steamui/adwaita/custom.css"
      if [ -e "$skin" ] || [ -L "$skin" ]; then
        ${pkgs.coreutils}/bin/ln -sfn "$HOME/.config/unit3/active/steam.css" "$skin"
      fi
    fi
  '';

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

    ## Steam theming
    adwsteamgtk        # GTK installer/updater for the Adwaita-for-Steam skin
    adwaita-for-steam  # skin + CLI installer (AdwSteamGtk updates it automatically)
  ];
}

