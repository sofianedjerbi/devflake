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
    
    # No need for explicit theme option since it's handled by the Catppuccin module
  };

  config = mkIf cfg.enable {
    # Install Waybar and dependencies
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      font-awesome
    ];
    
    # Configure Waybar with style enhancements
    programs.waybar = {
      enable = true;
      systemd.enable = true; # Manage Waybar through systemd
      
      style = ''
        /* The @import for Catppuccin is automatically added by the module */
        
        * {
          font-family: "JetBrains Mono Nerd Font", "Font Awesome 6 Free";
          font-size: 14px;
          min-height: 0;
          border: none;
          border-radius: 0;
          transition-duration: 0.3s;
        }
        
        window#waybar {
          background-color: transparent;
          border-bottom: 2px solid alpha(@base, 0.1);
          color: @text;
          transition-duration: 0.3s;
        }
        
        window#waybar.hidden {
          opacity: 0.2;
        }
        
        #workspaces button {
          padding: 0 5px;
          background-color: @surface0;
          color: @text;
          border-radius: 8px;
          margin: 4px 2px;
          transition-duration: 0.2s;
          font-size: 14px;
        }
        
        #workspaces button:hover {
          background-color: @surface1;
          box-shadow: inset 0 0 0 1px @surface1;
        }
        
        #workspaces button.active {
          background-color: @surface0;
          color: @text;
          border-radius: 8px;
          min-width: 30px;
        }
        
        /* Common styling for all modules */
        #clock,
        #battery,
        #cpu,
        #memory,
        #temperature,
        #network,
        #pulseaudio,
        #backlight,
        #bluetooth,
        #tray,
        #custom-power,
        #window {
          padding: 0 10px;
          margin: 4px 2px;
          border-radius: 8px;
          background-color: @surface0;
          color: @text;
          min-height: 30px;
          font-size: 14px;
        }
        
        /* Hover effects for modules */
        #clock:hover,
        #battery:hover,
        #cpu:hover,
        #memory:hover,
        #temperature:hover,
        #network:hover,
        #pulseaudio:hover,
        #backlight:hover,
        #bluetooth:hover,
        #custom-power:hover,
        #window:hover {
          background-color: @surface1;
          border-radius: 8px;
        }
        
        #battery.charging, #battery.plugged {
        }
        
        #battery.critical:not(.charging) {
          background-color: @peach;
          color: @base;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
        
        /* Define the blink animation */
        @keyframes blink {
          to {
            background-color: @text;
            color: @base;
          }
        }
        
        #clock {
          background-color: @surface0;
          color: @text;
          font-size: 14px;
        }
        
        #network.disconnected {
          background-color: @peach;
          color: @base;
        }
        
        #custom-power {
          background-color: @surface0;
          color: @text;
          margin-right: 6px;
          font-size: 14px;
        }
        
        #tray {
          background-color: @surface0;
        }
        
        #tray > .passive {
          -gtk-icon-effect: dim;
        }
        
        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: @peach;
        }
      '';
      
      # Define layout and functional elements
      settings.mainBar = {
        position = cfg.position;
        layer = "top";
        height = 40;
        margin-top = 4;
        margin-bottom = 0;
        margin-left = 6;
        margin-right = 6;
        spacing = 4;
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
          "custom/power"
        ];
        
        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "10";
          };
          on-click = "activate";
          all-outputs = true;
          sort-by-number = true;
          active-only = false;
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
          show-special = true;
        };
        
        "hyprland/window" = {
          format = "{}";
          max-length = 50;
          separate-outputs = true;
          
          rewrite = {
            "" = "Desktop";
          };
          # Return nothing when window title is empty to hide the container
          empty_value = "";
        };
        
        "clock" = {
          tooltip-format = "<big>{:%A, %B %d, %Y}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d | %H:%M:%S}";
          interval = 1;
          tooltip = true;
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#89b4fa'><b>{}</b></span>";
              days = "<span color='#cdd6f4'>{}</span>";
              weeks = "<span color='#89b4fa'><b>W{}</b></span>";
              weekdays = "<span color='#89b4fa'><b>{}</b></span>";
              today = "<span color='#fab387'><b>{}</b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        
        "battery" = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          tooltip = true;
          interval = 3;
        };
        
        "cpu" = {
          format = "󰘚 {usage}%";
          tooltip = true;
          interval = 3;
          tooltip-format = "CPU Usage: {usage}%\nLoad: {load}";
        };
        
        "memory" = {
          format = "󰍛 {percentage}%";
          tooltip = true;
          tooltip-format = "Used: {used}GiB\nTotal: {total}GiB";
          interval = 3;
        };
        
        "network" = {
          format-wifi = "󰖩 {signalStrength}%";
          format-ethernet = "󰈀 {ipaddr}";
          format-linked = "󰈁 {ifname}";
          format-disconnected = "󰖪 DISCONNECTED";
          tooltip-format = "Interface: {ifname}\nIP: {ipaddr}/{cidr}\nGateway: {gwaddr}\nUp: {bandwidthUpBytes}\nDown: {bandwidthDownBytes}";
          on-click = "nm-connection-editor";
          interval = 3;
        };
        
        "temperature" = {
          interval = 3;
          hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
          input-filename = "temp1_input";
          format = "󰔏 {temperatureC}°C";
          format-critical = "󱃂 {temperatureC}°C";
          tooltip = true;
          tooltip-format = "CPU Temperature: {temperatureC}°C";
          critical-threshold = 80;
        };
        
        "backlight" = {
          format = "{icon} {percent}%";
          format-icons = ["󰃞" "󰃟" "󰃠"];
          min-length = 6;
          on-scroll-up = "light -A 5";
          on-scroll-down = "light -U 5";
          tooltip = true;
          tooltip-format = "Brightness: {percent}%";
        };
        
        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            default = ["󰕿" "󰖀" "󰕾"];
            headphone = "󰋋";
            headset = "󰋎";
            hands-free = "󰋎";
            portable = "󰶹";
            car = "󰄋";
            speaker = "󰓃";
          };
          scroll-step = 5.0;
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          tooltip = true;
          tooltip-format = "Volume: {volume}%\nDevice: {desc}";
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
          format = "󰇚";
          icon-size = 18;
          spacing = 8;
          show-passive-items = true;
        };
        
        "custom/power" = {
          format = "󰐥";
          on-click = "wlogout";
          tooltip = true;
          tooltip-format = "System actions menu";
        };
      };
    };
    
    # Enable wlogout but don't customize the style since it's already managed by Catppuccin
    programs.wlogout = {
      enable = true;
    };
  };
} 