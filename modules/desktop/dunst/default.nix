{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myDunst;
in {
  options.myDunst = {
    enable = mkEnableOption "Enable Dunst notification daemon";
    
    # Additional configuration options you might want to expose
    width = mkOption {
      type = types.int;
      default = 300;
      description = "Width of notification popups";
    };
    
    height = mkOption {
      type = types.int;
      default = 300;
      description = "Height of notification popups";
    };
    
    offset = mkOption {
      type = types.str;
      default = "15x15";
      description = "Offset of notifications from the edge";
    };
    
    origin = mkOption {
      type = types.enum [ "top-left" "top-center" "top-right" "center" "center-left" "center-right" "bottom-left" "bottom-center" "bottom-right" ];
      default = "top-right";
      description = "Origin of the notification popups";
    };
    
    transparency = mkOption {
      type = types.int;
      default = 10;
      description = "Transparency level (0-100)";
    };
    
    frameWidth = mkOption {
      type = types.int;
      default = 2;
      description = "Width of the frame around notifications";
    };
    
    cornerRadius = mkOption {
      type = types.int;
      default = 10;
      description = "Corner radius for notifications";
    };
    
    font = mkOption {
      type = types.str;
      default = "JetBrains Mono 10";
      description = "Font to use for notifications";
    };
  };

  config = mkIf cfg.enable {
    # Install dunst and libnotify for notifications
    home.packages = with pkgs; [
      dunst
      libnotify  # Provides notify-send for testing
    ];
    
    # Configure dunst
    services.dunst = {
      enable = true;
      settings = {
        global = {
          # Apply user configuration
          width = cfg.width;
          height = cfg.height;
          offset = cfg.offset;
          origin = cfg.origin;
          transparency = cfg.transparency;
          frame_width = cfg.frameWidth;
          corner_radius = cfg.cornerRadius;
          font = cfg.font;
          
          # Standard settings
          line_height = 4;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 60;
          word_wrap = true;
          
          stack_duplicates = true;
          hide_duplicate_count = false;
          
          show_indicators = false;
          
          min_icon_size = 0;
          max_icon_size = 64;
          
          title = "Dunst";
          class = "Dunst";
          
          # Set default browser for URLs
          browser = "${pkgs.brave}/bin/brave";
          
          # Mouse actions
          mouse_left_click = "close_current";
          mouse_middle_click = "do_action, close_current";
          mouse_right_click = "close_all";
        };
        
        # Urgency levels with timeouts
        urgency_low = {
          timeout = 4;
        };
        
        urgency_normal = {
          timeout = 8;
        };
        
        urgency_critical = {
          timeout = 0;  # Don't timeout critical notifications
        };
      };
    };
  };
} 