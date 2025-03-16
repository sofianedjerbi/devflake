{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myWaybar;
in {
  options.myWaybar = {
    enable = mkEnableOption "Enable custom Waybar configuration";
    
    position = mkOption {
      type = types.str;
      default = "top";
      description = "Position of the Waybar (top or bottom)";
    };
  };

  config = mkIf cfg.enable {
    # Install Waybar and dependencies
    home.packages = with pkgs; [
      waybar
      font-awesome # For icons
      nerd-fonts.jetbrains-mono # Using the new namespace
      nerd-fonts.fira-code
    ];
    
    # Configure Waybar
    programs.waybar = {
      enable = true;
      systemd.enable = true; # Manage Waybar through systemd
      
      style = ''
        * {
          font-family: "JetBrains Mono Nerd Font", "Font Awesome 6 Free";
          font-size: 13px;
          font-weight: bold;
          transition-property: background-color;
          transition-duration: 0.3s;
        }
        
        window#waybar {
          background-color: @surface0;
          color: @text;
          margin: 0;
          border-radius: 0;
        }
        
        window#waybar.hidden {
          opacity: 0.2;
        }
        
        #window {
          padding-left: 16px;
          padding-right: 16px;
          transition: none;
          color: @text;
        }
        
        #workspaces {
          margin-left: 8px;
          background: transparent;
          transition: none;
        }
        
        #workspaces button {
          transition: none;
          color: @text;
          background: transparent;
          padding: 5px;
          font-weight: bolder;
        }
        
        #workspaces button.active {
          color: @mauve;
          background: @surface1;
          border-radius: 8px;
        }
        
        #workspaces button:hover {
          color: @rosewater;
          border-radius: 8px;
        }
        
        #battery,
        #cpu,
        #memory,
        #disk,
        #temperature,
        #network,
        #pulseaudio,
        #clock,
        #tray,
        #backlight,
        #bluetooth,
        #custom-power,
        #custom-notification {
          padding-left: 16px;
          padding-right: 16px;
          transition: none;
          color: @text;
        }
        
        #tray {
          margin-right: 8px;
        }
        
        #workspaces {
          padding-right: 4px;
          padding-left: 4px;
        }
        
        #clock {
          color: @lavender;
        }
        
        #network {
          color: @blue; 
        }
        
        #pulseaudio {
          color: @teal;
        }
        
        #battery {
          color: @green;
        }
        
        #battery.warning {
            color: @yellow;
        }
        
        #battery.critical {
            color: @red;
        }
        
        #cpu {
          color: @mauve;
        }
        
        #memory {
          color: @sky;
        }
        
        #temperature {
          color: @peach;
        }
        
        #bluetooth {
          color: @blue;
        }
        
        #backlight {
          color: @yellow;
        }
        
        #custom-power {
          color: @red;
          margin-right: 8px;
        }
      '';
      
      # Waybar configuration
      settings.mainBar = {
        position = cfg.position;
        layer = "top";
        height = 30;
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "network"
          "memory"
          "cpu"
          "temperature"
          "backlight"
          "pulseaudio"
          "bluetooth"
          "battery"
          "tray"
          "custom/power"
        ];
        
        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "󰲠";
            "2" = "󰲢";
            "3" = "󰲤";
            "4" = "󰲦";
            "5" = "󰲨";
            "6" = "󰲪";
            "7" = "󰲬";
            "8" = "󰲮";
            "9" = "󰲰";
            "10" = "󰿬";
          };
          on-click = "activate";
          all-outputs = true;
          sort-by-number = true;
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };
        
        "clock" = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d | %H:%M:%S}";
          interval = 1;
        };
        
        "battery" = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󱘖 {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󱟢" ];
          tooltip = true;
        };
        
        "cpu" = {
          format = "󰻠 {usage}%";
          tooltip = true;
          interval = 2;
        };
        
        "memory" = {
          format = "󰍛 {}%";
          interval = 2;
        };
        
        "network" = {
          format-wifi = "  {signalStrength}%";
          format-ethernet = "󰈁 {ipaddr}";
          format-linked = "󰈂 {ifname} (No IP)";
          format-disconnected = "󰈂 Disconnected";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          on-click = "nm-connection-editor";
        };
        
        "temperature" = {
          interval = 2;
          hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
          input-filename = "temp1_input";
          format = "󰔏 {temperatureC}°C";
          format-critical = "󱃂 {temperatureC}°C";
          tooltip = false;
        };
        
        "backlight" = {
          format = "{icon} {percent}%";
          format-icons = [ "󰃞" "󰃟" "󰃠" ];
          min-length = 6;
        };
        
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          on-click = "pavucontrol";
        };
        
        "bluetooth" = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱 {num_connections}";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "blueman-manager";
        };
        
        "tray" = {
          icon-size = 16;
          spacing = 8;
        };
        
        "custom/power" = {
          format = "󰐥";
          on-click = "wlogout";
          tooltip = false;
        };
      };
    };
    
    # Create or update a wlogout configuration for the power menu
    programs.wlogout = {
      enable = true;
    };
  };
} 