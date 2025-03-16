{ config, lib, pkgs, themeColors ? null, ... }:

with lib;
let
  cfg = config.myFuzzel;
  
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
  options.myFuzzel = {
    enable = mkEnableOption "Enable custom Fuzzel launcher configuration";
    
    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Default terminal to use when launching applications";
    };
    
    font = mkOption {
      type = types.str;
      default = "JetBrains Mono";
      description = "Font to use in the launcher";
    };
    
    fontSize = mkOption {
      type = types.int;
      default = 12;
      description = "Font size for the launcher";
    };
    
    width = mkOption {
      type = types.int;
      default = 35;
      description = "Width of the launcher (in characters)";
    };
    
    borderRadius = mkOption {
      type = types.int;
      default = 10;
      description = "Border radius for rounded corners";
    };
    
    backgroundOpacity = mkOption {
      type = types.str;
      default = "ee";
      description = "Opacity for the background (in hex, e.g., 'ee' for ~93%)";
    };
    
    showIcons = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to show application icons";
    };
    
    animation = mkOption {
      type = types.enum [ "none" "zoom" "slide-down" "slide-up" ];
      default = "zoom";
      description = "Animation style when opening the launcher";
    };
    
    extraConfig = mkOption {
      type = types.attrsOf (types.attrsOf types.str);
      default = {};
      description = "Additional configuration options for Fuzzel in section.key = value format";
      example = literalExpression ''
        {
          main = {
            fuzzy = "yes";
            drun-launch = "yes";
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install Fuzzel
    home.packages = with pkgs; [
      fuzzel
    ];
    
    # Configure Fuzzel with theme colors
    home.file.".config/fuzzel/fuzzel.ini".text = ''
      # Colors - using theme colors
      [colors]
      background=${colors.background}${cfg.backgroundOpacity}
      text=${colors.foreground}ff
      match=${colors.pink}ff
      selection=${colors.currentLine}ff
      selection-text=${colors.foreground}ff
      border=${colors.purple}ff
      
      # Border styling
      [border]
      width=2
      radius=${toString cfg.borderRadius}
      
      # Main configuration
      [main]
      font=${cfg.font}:size=${toString cfg.fontSize}
      terminal=${cfg.terminal}
      layer=overlay
      width=${toString cfg.width}
      horizontal-pad=30
      vertical-pad=20
      inner-pad=10
      line-height=25
      letter-spacing=0.5
      
      # Icon settings
      [icon]
      ${if cfg.showIcons then ''
      theme=hicolor
      size=24
      '' else ''
      theme=
      size=0
      ''}
      
      # Input field styling
      [dmenu]
      exit-immediately-if-empty=yes
      
      # Search behavior
      [search]
      fuzzy=yes
      
      # Key bindings
      [key-bindings]
      next=Tab Down
      prev=ISO_Left_Tab Up
      
      # Animation for a more polished feel
      [output]
      anchor=center
      clip=no
      animation=${cfg.animation}
      duration=100
      
      ${concatStringsSep "\n" (mapAttrsToList 
        (section: options: 
          "[${section}]\n" + 
          concatStringsSep "\n" (mapAttrsToList 
            (key: value: "${key}=${value}")
            options
          )
        ) 
        cfg.extraConfig
      )}
    '';
  };
} 