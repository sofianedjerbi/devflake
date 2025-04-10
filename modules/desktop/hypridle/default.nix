{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myHypridle;
in {
  options.myHypridle = {
    enable = mkEnableOption "Enable custom Hypridle configuration";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        # don't idle while playing audio
        "sway-audio-idle-inhibit"
      ];
    };

    home.packages = with pkgs; [
      hypridle
      sway-audio-idle-inhibit
    ];

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "${lib.getExe pkgs.hyprlock}";
          before_sleep_cmd = "${lib.getExe pkgs.hyprlock}";
          after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
        };

        listener = [
          # Turn off screen after 2 minutes of inactivity
          {
            timeout = 120;
            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
          # Lock screen after 3 minutes of inactivity
          {
            timeout = 180;
            on-timeout = "${lib.getExe pkgs.hyprlock}";
          }
          # Suspend after 5 minutes of inactivity
          {
            timeout = 300;
            on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
      };
    };
  };
} 