{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myKitty;
in {
  options.myKitty = {
    enable = mkEnableOption "Enable custom Kitty configuration";
    
    fontSize = mkOption {
      type = types.int;
      default = 12;
      description = "Font size for Kitty";
    };
    
    opacity = mkOption {
      type = types.str;
      default = "0.95";
      description = "Background opacity (0.0 to 1.0)";
    };
    
    font = mkOption {
      type = types.str;
      default = "JetBrains Mono Nerd Font";
      description = "Font family for Kitty";
    };
    
    padding = mkOption {
      type = types.int;
      default = 8;
      description = "Window padding width";
    };
    
    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional Kitty settings";
    };
  };

  config = mkIf cfg.enable {
    # Configure Kitty
    programs.kitty = {
      enable = true;
      settings = {
        # Terminal window settings
        background_opacity = cfg.opacity;
        window_padding_width = cfg.padding;
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        
        # Add any other default settings
        scrollback_lines = 10000;
        copy_on_select = "clipboard";
        strip_trailing_spaces = "smart";
        
        # Allow user to override with extra settings
      } // cfg.extraSettings;
      
      # Configure font
      font = {
        name = cfg.font;
        size = cfg.fontSize;
      };
    };
    
    # Ensure Kitty is installed
    home.packages = with pkgs; [
      kitty
    ];
  };
} 