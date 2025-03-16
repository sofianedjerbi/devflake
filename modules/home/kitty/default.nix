{ config, lib, pkgs, themeColors ? null, ... }:

with lib;
let
  cfg = config.myKitty;
  
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
    terminal = {
      black = "21222c";
      brightBlack = "6272a4";
      white = "f8f8f2";
      brightWhite = "f8f8f2";
      cursor = "f8f8f2";
    };
  };
  
  # Use theme colors or fall back to default
  colors = if themeColors != null then themeColors else defaultTheme;
  
  # Generate terminal color scheme from theme colors
  terminalColors = {
    background = "#${colors.background}";
    foreground = "#${colors.foreground}";
    selection_background = "#${colors.comment}";
    selection_foreground = "#${colors.foreground}";
    url_color = "#${colors.cyan}";
    cursor = if colors.terminal ? cursor then "#${colors.terminal.cursor}" else "#${colors.foreground}";
    cursor_text_color = "#${colors.background}";
    
    # Normal colors
    color0 = "#${colors.terminal.black}"; # black
    color1 = "#${colors.red}"; # red
    color2 = "#${colors.green}"; # green
    color3 = "#${colors.yellow}"; # yellow
    color4 = "#${colors.purple}"; # blue
    color5 = "#${colors.pink}"; # magenta
    color6 = "#${colors.cyan}"; # cyan
    color7 = "#${colors.terminal.white}"; # white
    
    # Bright colors
    color8 = "#${colors.terminal.brightBlack}"; # bright black
    color9 = "#${colors.red}"; # bright red
    color10 = "#${colors.green}"; # bright green
    color11 = "#${colors.yellow}"; # bright yellow
    color12 = "#${colors.purple}"; # bright blue
    color13 = "#${colors.pink}"; # bright magenta
    color14 = "#${colors.cyan}"; # bright cyan
    color15 = "#${colors.terminal.brightWhite}"; # bright white
    
    # UI elements
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
      settings = terminalColors // {
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