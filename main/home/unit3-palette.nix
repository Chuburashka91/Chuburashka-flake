{ pkgs, lib, ... }:
let
  themes = ../themes;
  wallpapers = ../../files/wallpapers;
in
{
  # Runtime palette state. Templates and the renderer are copied once per
  # rebuild; palettes are copied only when missing, so runtime edits survive.
  # `unit3-palette set|next` then only rewrites ~/.config/unit3 and the
  # active symlink — no Nix evaluation involved.
  # The wrapper lives in the profile, so Hyprland keybinds can call it even
  # when the session PATH is minimal. Python is in the wrapper's PATH.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "unit3-palette";
      runtimeInputs = [ pkgs.python3 ];
      text = ''
        exec python3 "$HOME/.config/unit3/unit3-palette.py" "$@"
      '';
    })
  ];

  # Seed the per-style wallpaper folders once per user. `install -m` only
  # runs for missing files, so a user's own wallpapers are never replaced.
  home.activation.unit3Wallpapers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -e
    dest="$HOME/Pictures/wallpapers"
    if [ -n "$DRY_RUN_CMD" ]; then
      echo "would seed wallpaper folders in $dest"
    else
      ${pkgs.coreutils}/bin/mkdir -p "$dest"/unit3 "$dest"/gaming "$dest"/space "$dest"/mimimi "$dest"/others
      for style in unit3 gaming space mimimi others; do
        for image in ${wallpapers}/"$style"/*.png; do
          target="$dest/$style/$(${pkgs.coreutils}/bin/basename "$image")"
          [ -e "$target" ] || ${pkgs.coreutils}/bin/install -m 644 "$image" "$target"
        done
      done
    fi
  '';

  home.activation.unit3Palette = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -e
    dir="$HOME/.config/unit3"

    if [ -n "$DRY_RUN_CMD" ]; then
      echo "would prepare runtime palettes in $dir"
    else
      ${pkgs.coreutils}/bin/mkdir -p "$dir/templates" "$dir/palettes" "$dir/profiles"

      ${pkgs.coreutils}/bin/install -m 644 ${themes}/gtk/unit3.css          "$dir/templates/gtk.css"
      ${pkgs.coreutils}/bin/install -m 644 ${themes}/vencord/unit3.theme.css "$dir/templates/vencord.css"
      ${pkgs.coreutils}/bin/install -m 644 ${themes}/zen/userChrome.css     "$dir/templates/zenChrome.css"
      ${pkgs.coreutils}/bin/install -m 644 ${themes}/zen/userContent.css    "$dir/templates/zenContent.css"
      ${pkgs.coreutils}/bin/install -m 644 ${themes}/steam/unit3.css        "$dir/templates/steam.css"
      ${pkgs.coreutils}/bin/install -m 644 ${themes}/btop/unit3.theme       "$dir/templates/btop.theme"
      ${pkgs.coreutils}/bin/install -m 755 ${themes}/runtime/unit3-palette.py "$dir/unit3-palette.py"

      for palette in ${themes}/palettes/*.toml; do
        target="$dir/palettes/$(${pkgs.coreutils}/bin/basename "$palette")"
        [ -e "$target" ] || ${pkgs.coreutils}/bin/install -m 644 "$palette" "$target"
      done

      if [ -e "$dir/style" ]; then
        U3_PALETTE_SKIP_WALLPAPER=1 ${pkgs.python3}/bin/python3 "$dir/unit3-palette.py" render
      else
        U3_PALETTE_SKIP_WALLPAPER=1 ${pkgs.python3}/bin/python3 "$dir/unit3-palette.py" set unit3
      fi
    fi
  '';
}
