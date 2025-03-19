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
      fortune
    ];
    
    # Create hyprlock configuration file
    xdg.configFile."hypr/hyprlock.conf".text = ''
      general {
        disable_loading_bar = false
        hide_cursor = true
        no_fade_in = false
        grace = 0
      }
      
      background {
        path = screenshot
        blur_size = 4
        blur_passes = 3
      }
      
      # Clock - Large time display
      label {
        text = $TIME
        font_size = 96
        font_family = JetBrains Mono
        position = 0, 160
        halign = center
        valign = center
      }

      # Date with nice format
      label {
        text = cmd[update:1000] date "+%A, %B %d"
        font_size = 24
        font_family = JetBrains Mono
        position = 0, 60
        halign = center
        valign = center
      }

      # Username label
      label {
        text = hi there, @$USER
        font_size = 16
        font_family = JetBrains Mono
        position = 0, -30
        halign = center
        valign = center
      }

      # Quote
      label {
        text = cmd[] fortune -s
        font_size = 12
        font_family = JetBrains Mono
        position = 0, 20
        halign = center
        valign = bottom
      }

      # Password input field
      input-field {
        size = 250, 50
        position = 0, -80
        outline_thickness = 2
        dots_size = 0.2
        dots_spacing = 0.2
        dots_center = true
        fade_on_empty = false
        placeholder_text = Password...
        font_family = JetBrains Mono
        halign = center
        valign = center
      }
    '';
  };
} 