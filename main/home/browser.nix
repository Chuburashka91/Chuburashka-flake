{ inputs, pkgs, ... }:
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;
    profiles.default = {
      path = "uf1assfh.Default Profile";
      isDefault = true;
      userChrome = builtins.readFile ../themes/zen/userChrome.css;
      userContent = builtins.readFile ../themes/zen/userContent.css;
    };
  };
}
