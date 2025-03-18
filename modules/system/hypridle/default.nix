{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myHypridle;
in {
  options.myHypridle = {
    enable = mkEnableOption "Enable custom Hypridle configuration";
  };

  config = mkIf cfg.enable {
    # Install hypridle package
    home.packages = with pkgs; [
      hypridle
    ];
    
    # Create hypridle configuration file
    xdg.configFile."hypridle/hypridle.conf".text = ''
      general {
        lock_cmd = "hyprlock";
        before_sleep_cmd = "hyprlock";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      }
      
      listener {
        timeout = 120
        on_timeout = "hyprctl dispatch dpms off"
        on_resume = "hyprctl dispatch dpms on"
      }
      
      listener {
        timeout = 180
        on_timeout = "hyprlock"
      }
      
      listener {
        timeout = 300
        on_timeout = "systemctl suspend"
      }
    '';
  };
} 