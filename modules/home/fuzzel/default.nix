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
    
    # Configure Fuzzel
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          font = "${cfg.font}:size=${toString cfg.fontSize}";
          terminal = "${cfg.terminal}";
          layer = "overlay";
          width = toString cfg.width;
          horizontal-pad = "30";
          vertical-pad = "20";
          inner-pad = "10";
          line-height = "25";
          letter-spacing = "0.5";
        };
        
        border = {
          width = "2";
          radius = toString cfg.borderRadius;
        };
        
        icon = {
          theme = if cfg.showIcons then "hicolor" else "";
          size = if cfg.showIcons then "24" else "0";
        };
        
        dmenu = {
          exit-immediately-if-empty = "yes";
        };
        
        search = {
          fuzzy = "yes";
        };
        
        key-bindings = {
          next = "Tab Down";
          prev = "ISO_Left_Tab Up";
        };
        
        output = {
          anchor = "center";
          clip = "no";
          animation = cfg.animation;
          duration = "100";
        };
      } // cfg.extraConfig;
    };
  };
} 