{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myDesktop;
in {
  imports = [
    # Import our desktop components
    ./hyprland
    ./waybar
    ./kitty
    ./fuzzel
    ./hyprlock
    ./hypridle
  ];

  options.myDesktop = {
    enable = mkEnableOption "Enable desktop environment";
    
    # Desktop environment type
    type = mkOption {
      type = types.enum [ "hyprland" ];
      default = "hyprland";
      description = "Type of desktop environment to enable";
    };
    
    # Common desktop configuration options
    wallpaper = mkOption {
      type = types.path;
      description = "Path to wallpaper image";
      example = "./wallpapers/default.jpg";
    };
    
    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Default terminal emulator";
    };
    
    launcher = mkOption {
      type = types.str;
      default = "fuzzel";
      description = "Application launcher program";
    };
  };

  config = mkIf cfg.enable {
    # Enable appropriate desktop components based on desktop type
    myHyprland = mkIf (cfg.type == "hyprland") {
      enable = true;
      wallpaper = cfg.wallpaper;
      terminal = cfg.terminal;
      launcher = cfg.launcher;
    };
    
    # Always enable these components when desktop is enabled
    myWaybar.enable = true;
    myKitty.enable = true;
    myFuzzel.enable = true;
  };
} 