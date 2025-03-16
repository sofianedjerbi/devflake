{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myTheme;
in {
  options.myTheme = {
    enable = mkEnableOption "Enable Catppuccin theme integration";
    
    flavor = mkOption {
      type = types.enum [ "mocha" "macchiato" "frappe" "latte" ];
      default = "mocha";
      description = "Catppuccin flavor to use";
    };
    
    accent = mkOption {
      type = types.enum [ 
        "rosewater" "flamingo" "pink" "mauve" "red" "maroon" 
        "peach" "yellow" "green" "teal" "sky" "sapphire"
        "blue" "lavender" "text" 
      ];
      default = "mauve";
      description = "Catppuccin accent color";
    };
  };

  config = mkIf cfg.enable {
    # Enable the official Catppuccin module with our settings
    catppuccin = {
      enable = true;
      flavor = cfg.flavor;
      accent = cfg.accent;
      
      # Enable all the supported applications
      alacritty.enable = true;
      bat.enable = true;
      btop.enable = true;
      cava.enable = true;
      dunst.enable = true;
      fish.enable = true;
      foot.enable = true;
      fuzzel.enable = true;
      hyprland.enable = true;
      kitty.enable = true;
      neovim.enable = true;
      rofi.enable = true;
      starship.enable = true;
      swaylock.enable = true;
      waybar.enable = true;
      wlogout.enable = true;
      zsh-syntax-highlighting.enable = true;
    };
  };
} 