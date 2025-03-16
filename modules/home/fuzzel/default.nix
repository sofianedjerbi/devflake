{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myFuzzel;
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
      default = 10;
      description = "Font size for the launcher";
    };
    
    width = mkOption {
      type = types.int;
      default = 20;
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
    
    # Configure Fuzzel
    programs.fuzzel = {
      enable = true;
      settings = mkMerge [
        {
          main = {
            # Core settings
            font = "${cfg.font}:size=${toString cfg.fontSize}";
            terminal = "${cfg.terminal}";
            layer = "overlay";
            width = toString cfg.width;
            # Ultra compact padding values
            horizontal-pad = "5";
            vertical-pad = "3";
            inner-pad = "2";
            line-height = "16";
            letter-spacing = "0.1";
            
            prompt = lib.mkForce "";
            
            # Icon settings
            icons-enabled = if cfg.showIcons then "yes" else "no";
            
            # Animation and positioning
            anchor = "center";
            
            # Search behavior
            match-mode = "fuzzy";
            
            # Reduce lines to make it more compact
            lines = "8";  # Default is usually 15
          };
          
          # Fix for icon settings
          icon = lib.mkIf cfg.showIcons {
            theme = "hicolor";
            size = "24";
          };
          
          border = {
            width = "1";
            radius = toString cfg.borderRadius;
          };
          
          dmenu = {
            exit-immediately-if-empty = "yes";
          };
          
          key-bindings = {
            next = "Down Control+n";
            prev = "Up Control+p";
          };
        }
        cfg.extraConfig
      ];
    };
  };
} 