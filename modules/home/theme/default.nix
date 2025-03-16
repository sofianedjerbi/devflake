{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myTheme;
in {
  options.myTheme = {
    enable = mkEnableOption "Enable central theme configuration";
    
    name = mkOption {
      type = types.enum [ "dracula" "nord" "catppuccin-mocha" ];
      default = "dracula";
      description = "Theme to use";
    };
  };

  config = mkIf cfg.enable {
    # Export colors to be used by other modules
    _module.args.themeColors = 
      if cfg.name == "dracula" then {
        background = "282a36";
        currentLine = "44475a";
        foreground = "f8f8f2";
        comment = "6272a4";
        cyan = "8be9fd";
        green = "50fa7b";
        orange = "ffb86c";
        pink = "ff79c6";
        purple = "bd93f9";
        red = "ff5555";
        yellow = "f1fa8c";
      }
      else if cfg.name == "nord" then {
        background = "2e3440";
        currentLine = "3b4252";
        foreground = "eceff4";
        comment = "4c566a"; 
        cyan = "88c0d0";
        green = "a3be8c";
        orange = "d08770";
        pink = "b48ead";
        purple = "b48ead";
        red = "bf616a";
        yellow = "ebcb8b";
      }
      else if cfg.name == "catppuccin-mocha" then {
        background = "1e1e2e";
        currentLine = "313244";
        foreground = "cdd6f4";
        comment = "6c7086";
        cyan = "89dceb";
        green = "a6e3a1";
        orange = "fab387";
        pink = "f5c2e7";
        purple = "cba6f7";
        red = "f38ba8";
        yellow = "f9e2af";
      }
      else {
        # Default to dracula if something goes wrong
        background = "282a36";
        currentLine = "44475a";
        foreground = "f8f8f2";
        comment = "6272a4";
        cyan = "8be9fd";
        green = "50fa7b";
        orange = "ffb86c";
        pink = "ff79c6";
        purple = "bd93f9";
        red = "ff5555";
        yellow = "f1fa8c";
      };
  };
} 