{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myHyprlock;
in {
  options.myHyprlock = {
    enable = mkEnableOption "Enable custom Hyprlock configuration";
  };

  config = mkIf cfg.enable {
    # Install hyprlock package
    home.packages = with pkgs; [
      hyprlock
    ];
    
    # Create hyprlock configuration file
    xdg.configFile."hyprlock/hyprlock.conf".text = ''
      general {
        disable_loading_bar = false
        hide_cursor = true
        grace = 0
        no_fade_in = false
      }
      
      input-field {
        size = 300, 50
        position = 0, 0
        placeholder_text = "Enter Password..."
        dots_size = 0.2
        dots_spacing = 0.64
        dots_center = true
        fade_on_empty = true
        font_family = Sans
        placeholder_text_font_family = Sans
      }
    '';
  };
} 