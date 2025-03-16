{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myTheme;
  
  # Define all themes here so they can be applied consistently across all modules
  themes = {
    dracula = {
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
      
      # Terminal-specific colors (for kitty, alacritty, etc)
      terminal = {
        black = "21222c";
        brightBlack = "6272a4";
        white = "f8f8f2";
        brightWhite = "f8f8f2";
      };
    };
    
    nord = {
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
      
      # Terminal-specific colors
      terminal = {
        black = "3b4252";
        brightBlack = "4c566a";
        white = "e5e9f0";
        brightWhite = "eceff4";
      };
    };
    
    "catppuccin-mocha" = {
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
      
      # Terminal-specific colors
      terminal = {
        black = "45475a";
        brightBlack = "585b70";
        white = "bac2de";
        brightWhite = "a6adc8";
        cursor = "f5e0dc";
      };
    };
  };
  
  # The active theme colors
  activeTheme = themes.${cfg.name};
in {
  options.myTheme = {
    enable = mkEnableOption "Enable central theme configuration";
    
    name = mkOption {
      type = types.enum (builtins.attrNames themes);
      default = "dracula";
      description = "Theme to use";
    };
  };

  config = mkIf cfg.enable {
    # Export colors to be used by other modules
    _module.args.themeColors = activeTheme;
  };
} 