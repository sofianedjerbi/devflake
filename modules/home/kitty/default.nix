{ config, lib, pkgs, themeColors ? null, ... }:

with lib;
let
  cfg = config.myKitty;
  
  # Use theme colors from the central theme module or fallback to Dracula
  colors = if themeColors != null then themeColors else {
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
  
  # Add theme-specific color mappings
  themeColorScheme = 
    if themeColors != null && cfg.theme == "catppuccin-mocha" then {
      # Catppuccin Mocha colors
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      selection_background = "#585b70";
      selection_foreground = "#cdd6f4";
      url_color = "#89dceb";
      cursor = "#f5e0dc";
      
      # Normal colors
      color0 = "#45475a"; # black
      color1 = "#f38ba8"; # red
      color2 = "#a6e3a1"; # green
      color3 = "#f9e2af"; # yellow
      color4 = "#89b4fa"; # blue
      color5 = "#cba6f7"; # magenta
      color6 = "#89dceb"; # cyan
      color7 = "#bac2de"; # white
      
      # Bright colors
      color8 = "#585b70"; # bright black
      color9 = "#f38ba8"; # bright red
      color10 = "#a6e3a1"; # bright green
      color11 = "#f9e2af"; # bright yellow
      color12 = "#89b4fa"; # bright blue
      color13 = "#cba6f7"; # bright magenta
      color14 = "#89dceb"; # bright cyan
      color15 = "#a6adc8"; # bright white
    } 
    else if cfg.theme == "nord" then {
      # Nord theme colors
      background = "#2e3440";
      foreground = "#d8dee9";
      selection_background = "#4c566a";
      selection_foreground = "#d8dee9";
      url_color = "#88c0d0";
      cursor = "#d8dee9";
      
      # Normal colors
      color0 = "#3b4252"; # black
      color1 = "#bf616a"; # red
      color2 = "#a3be8c"; # green
      color3 = "#ebcb8b"; # yellow
      color4 = "#81a1c1"; # blue
      color5 = "#b48ead"; # magenta
      color6 = "#88c0d0"; # cyan
      color7 = "#e5e9f0"; # white
      
      # Bright colors
      color8 = "#4c566a"; # bright black
      color9 = "#bf616a"; # bright red
      color10 = "#a3be8c"; # bright green
      color11 = "#ebcb8b"; # bright yellow
      color12 = "#81a1c1"; # bright blue
      color13 = "#b48ead"; # bright magenta
      color14 = "#8fbcbb"; # bright cyan
      color15 = "#eceff4"; # bright white
    }
    else {
      # Dracula theme (default)
      background = "#${colors.background}";
      foreground = "#${colors.foreground}";
      selection_background = "#${colors.comment}";
      selection_foreground = "#${colors.foreground}";
      url_color = "#${colors.cyan}";
      cursor = "#${colors.foreground}";
      cursor_text_color = "#${colors.background}";
      
      # Normal colors
      color0 = "#21222c"; # black
      color1 = "#${colors.red}"; # red
      color2 = "#${colors.green}"; # green
      color3 = "#${colors.yellow}"; # yellow
      color4 = "#${colors.purple}"; # blue
      color5 = "#${colors.pink}"; # magenta
      color6 = "#${colors.cyan}"; # cyan
      color7 = "#${colors.foreground}"; # white
      
      # Bright colors
      color8 = "#6272a4"; # bright black
      color9 = "#${colors.red}"; # bright red
      color10 = "#${colors.green}"; # bright green
      color11 = "#${colors.yellow}"; # bright yellow
      color12 = "#${colors.purple}"; # bright blue
      color13 = "#${colors.pink}"; # bright magenta
      color14 = "#${colors.cyan}"; # bright cyan
      color15 = "#${colors.foreground}"; # bright white
      
      # Additional UI elements
      active_border_color = "#${colors.purple}";
      inactive_border_color = "#${colors.comment}";
      active_tab_background = "#${colors.background}";
      active_tab_foreground = "#${colors.foreground}";
      inactive_tab_background = "#${colors.currentLine}";
      inactive_tab_foreground = "#${colors.foreground}";
      tab_bar_background = "#${colors.background}";
    };
in {
  options.myKitty = {
    enable = mkEnableOption "Enable custom Kitty configuration";
    
    theme = mkOption {
      type = types.enum [ "dracula" "nord" "catppuccin-mocha" ];
      default = "dracula";
      description = "Theme to use for Kitty";
    };
    
    fontSize = mkOption {
      type = types.int;
      default = 12;
      description = "Font size for Kitty";
    };
    
    opacity = mkOption {
      type = types.str;
      default = "0.95";
      description = "Background opacity (0.0 to 1.0)";
    };
    
    font = mkOption {
      type = types.str;
      default = "JetBrains Mono Nerd Font";
      description = "Font family for Kitty";
    };
    
    padding = mkOption {
      type = types.int;
      default = 8;
      description = "Window padding width";
    };
    
    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional Kitty settings";
    };
  };

  config = mkIf cfg.enable {
    # Configure Kitty with theme colors
    programs.kitty = {
      enable = true;
      settings = themeColorScheme // {
        # Terminal window settings
        background_opacity = cfg.opacity;
        window_padding_width = cfg.padding;
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        
        # Add any other default settings
        scrollback_lines = 10000;
        copy_on_select = "clipboard";
        strip_trailing_spaces = "smart";
        
        # Allow user to override with extra settings
      } // cfg.extraSettings;
      
      # Configure font
      font = {
        name = cfg.font;
        size = cfg.fontSize;
      };
    };
    
    # Ensure Kitty is installed
    home.packages = with pkgs; [
      kitty
    ];
  };
} 