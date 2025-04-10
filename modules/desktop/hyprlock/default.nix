{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myHyprlock;
in {
  options.myHyprlock = {
    enable = mkEnableOption "Enable custom Hyprlock configuration";
  };

  config = mkIf cfg.enable {
    # Install fortune package
    home.packages = with pkgs; [
      fortune
    ];
    
    # Use the built-in hyprlock module
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = false;
          hide_cursor = true;
          grace = 0;
        };
        
        background = [
          {
            path = "screenshot";
            blur_size = 4;
            blur_passes = 2;
          }
        ];
      };
    };
  };
} 