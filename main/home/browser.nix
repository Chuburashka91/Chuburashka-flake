{ inputs, pkgs, lib, ... }:
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    profiles.default = {
      path = "uf1assfh.Default Profile";
      isDefault = true;
      # The real files are symlinked to the active palette in the activation
      # hook below; let the module create placeholders first.
      userChrome = "";
      userContent = "";
    };
  };

  home.activation.zenPaletteCss = lib.hm.dag.entryAfter [ "writeBoundary" "unit3Palette" ] ''
    set -e
    dir="$HOME/.config/zen/uf1assfh.Default Profile/chrome"
    if [ -n "$DRY_RUN_CMD" ]; then
      echo "would link Zen chrome CSS to the active palette"
    else
      ${pkgs.coreutils}/bin/mkdir -p "$dir"
      ${pkgs.coreutils}/bin/ln -sfn "$HOME/.config/unit3/active/zenChrome.css" "$dir/userChrome.css"
      ${pkgs.coreutils}/bin/ln -sfn "$HOME/.config/unit3/active/zenContent.css" "$dir/userContent.css"
    fi
  '';
}
