{ config, lib, pkgs, themeColors ? null, ... }:

with lib;
let
  cfg = config.myWaybar;
  
  # Fallback colors if theme is not available (should not happen in normal usage)
  defaultTheme = {
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
  };
  
  # Use theme colors or fall back to default
  colors = if themeColors != null then themeColors else defaultTheme;
in {
  options.myWaybar = {
    enable = mkEnableOption "Enable custom Waybar configuration";
    
    position = mkOption {
      type = types.str;
      default = "top";
      description = "Position of the Waybar (top or bottom)";
    };
    
    theme = mkOption {
      type = types.enum [ "dark" "light" "catppuccin-mocha" "nord" "dracula" ];
      default = "dracula";
      description = "Theme to use for Waybar";
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
        /* Apply the selected theme */
        @import "${cfg.theme}.css";
        
        * {
          font-family: "JetBrains Mono Nerd Font", "Font Awesome 6 Free";
          font-size: 13px;
          font-weight: bold;
          border-radius: 8px;
          transition-property: background-color;
          transition-duration: 0.3s;
        }
        
        window#waybar {
          background-color: transparent;
          color: @text;
          margin: 5px 5px;
        }
        
        window#waybar.hidden {
          opacity: 0.2;
        }
        
        #window {
          margin-top: 8px;
          padding-left: 16px;
          padding-right: 16px;
          border-radius: 26px;
          transition: none;
          background: @surface0;
          color: @text;
        }
        
        #workspaces {
          margin-top: 8px;
          margin-left: 12px;
          margin-bottom: 0;
          border-radius: 26px;
          background: @surface0;
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
          border-radius: 20px;
        }
        
        #workspaces button:hover {
          color: @rosewater;
          border-radius: 20px;
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
          margin-top: 8px;
          margin-left: 8px;
          padding-left: 16px;
          padding-right: 16px;
          margin-bottom: 0;
          border-radius: 26px;
          transition: none;
          color: @text;
          background: @surface0;
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
          margin-right: 12px;
        }
      '';
      
      # Add theme files
      settings.mainBar = {
        position = cfg.position;
        layer = "top";
        height = 40;
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
    
    # Create theme files in the configuration directory
    home.file = {
      ".config/waybar/catppuccin-mocha.css".text = ''
        @define-color base   #${colors.background};
        @define-color mantle #1e1f29;
        @define-color crust  #181920;
        
        @define-color text     #${colors.foreground};
        @define-color subtext0 #${colors.foreground};
        @define-color subtext1 #${colors.foreground};
        
        @define-color surface0 #${colors.currentLine};
        @define-color surface1 #${colors.comment};
        @define-color surface2 #${colors.comment};
        
        @define-color overlay0 #${colors.comment};
        @define-color overlay1 #${colors.comment};
        @define-color overlay2 #${colors.comment};
        
        @define-color blue      #${colors.cyan};
        @define-color lavender  #${colors.purple};
        @define-color sapphire  #${colors.cyan};
        @define-color sky       #${colors.cyan};
        @define-color teal      #${colors.cyan};
        @define-color green     #${colors.green};
        @define-color yellow    #${colors.yellow};
        @define-color peach     #${colors.orange};
        @define-color maroon    #${colors.red};
        @define-color red       #${colors.red};
        @define-color mauve     #${colors.purple};
        @define-color pink      #${colors.pink};
        @define-color flamingo  #${colors.orange};
        @define-color rosewater #${colors.foreground};
      '';
      
      ".config/waybar/nord.css".text = ''
        @define-color base   #${colors.background};
        @define-color mantle #${colors.background};
        @define-color crust  #272c36;
        
        @define-color text     #${colors.foreground};
        @define-color subtext0 #${colors.foreground};
        @define-color subtext1 #${colors.foreground};
        
        @define-color surface0 #${colors.currentLine};
        @define-color surface1 #${colors.comment};
        @define-color surface2 #${colors.comment};
        
        @define-color overlay0 #${colors.comment};
        @define-color overlay1 #${colors.comment};
        @define-color overlay2 #${colors.comment};
        
        @define-color blue      #${colors.cyan};
        @define-color lavender  #${colors.purple};
        @define-color sapphire  #${colors.cyan};
        @define-color sky       #${colors.cyan};
        @define-color teal      #${colors.cyan};
        @define-color green     #${colors.green};
        @define-color yellow    #${colors.yellow};
        @define-color peach     #${colors.orange};
        @define-color maroon    #${colors.red};
        @define-color red       #${colors.red};
        @define-color mauve     #${colors.purple};
        @define-color pink      #${colors.pink};
        @define-color flamingo  #${colors.orange};
        @define-color rosewater #${colors.foreground};
      '';
      
      ".config/waybar/dracula.css".text = ''
        @define-color base   #${colors.background};
        @define-color mantle #1e1f29;
        @define-color crust  #181920;
        
        @define-color text     #${colors.foreground};
        @define-color subtext0 #${colors.foreground};
        @define-color subtext1 #${colors.foreground};
        
        @define-color surface0 #${colors.currentLine};
        @define-color surface1 #${colors.comment};
        @define-color surface2 #${colors.comment};
        
        @define-color overlay0 #${colors.comment};
        @define-color overlay1 #${colors.comment};
        @define-color overlay2 #${colors.comment};
        
        @define-color blue      #${colors.cyan};
        @define-color lavender  #${colors.purple};
        @define-color sapphire  #${colors.cyan};
        @define-color sky       #${colors.cyan};
        @define-color teal      #${colors.cyan};
        @define-color green     #${colors.green};
        @define-color yellow    #${colors.yellow};
        @define-color peach     #${colors.orange};
        @define-color maroon    #${colors.red};
        @define-color red       #${colors.red};
        @define-color mauve     #${colors.purple};
        @define-color pink      #${colors.pink};
        @define-color flamingo  #${colors.orange};
        @define-color rosewater #${colors.foreground};
      '';
    };
    
    # Create or update a wlogout configuration for the power menu
    programs.wlogout = {
      enable = true;
      style = ''
        * {
          background-image: none;
          font-family: "JetBrains Mono Nerd Font";
        }
        
        window {
          background-color: rgba(${colors.background}, 0.8);
        }
        
        button {
          color: #${colors.foreground};
          background-color: #${colors.currentLine};
          border-style: solid;
          border-width: 0;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          border-radius: 12px;
          margin: 8px;
          box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
        }
        
        button:focus, button:active, button:hover {
          background-color: #${colors.comment};
          color: #${colors.cyan};
          outline-style: none;
        }
        
        #lock {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/lock.png"));
        }
        
        #logout {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/logout.png"));
        }
        
        #suspend {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/suspend.png"));
        }
        
        #hibernate {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/hibernate.png"));
        }
        
        #shutdown {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/shutdown.png"));
        }
        
        #reboot {
          background-image: image(url("${pkgs.wlogout}/share/wlogout/icons/reboot.png"));
        }
      '';
    };
  };
} 