{ config, pkgs, lib, inputs, username ? null, ... }:

let
  # User information
  actualUsername = if username != null then username 
                   else if config.home.username or null != null then config.home.username
                   else "sofiane";
  userFullName = "Sofiane Djerbi";
  userEmail = "contact@sofianedjerbi.com";
  homeDir = "/home/${actualUsername}";
in {
  imports = [
    # Import common user settings
    ../_modules/default.nix
    
    # Import catppuccin module
    inputs.catppuccin.homeManagerModules.catppuccin
    
    # Import brave configuration
    ../../modules/home/brave
    
    # Import starship configuration
    ../../modules/home/starship
  ];

  # === Basic User Information ================================================
  home = {
    username = actualUsername;
    homeDirectory = homeDir;
    
    # === User-specific GUI applications ======================================
    packages = with pkgs; [
      # GUI Applications
      cursor
      discord
      obsidian
      spotify
    ];
  };

  # === Desktop Environment Configuration =====================================
  myDesktop = {
    enable = true;
    type = "hyprland";
    wallpaper = ../../resources/wallpapers/asian-town.png;
    terminal = "kitty";
    launcher = "fuzzel";
  };
  
  # === Waybar Configuration ==================================================
  myWaybar = {
    enable = true;
    position = "top";
  };
  
  # === Kitty Configuration ==================================================
  myKitty = {
    enable = true;
    fontSize = 12;
    opacity = "1.0";
    extraSettings = {
      # Any additional custom settings can go here
      cursor_blink_interval = "0.5";
      cursor_shape = "beam";
    };
  };
  
  # === Fuzzel Configuration =================================================
  myFuzzel = {
    enable = true;
    font = "JetBrains Mono";
    fontSize = 8;
    width = 20;
    borderRadius = 10;
    backgroundOpacity = "ee";  # ~93% opacity
    showIcons = false;         # Elegant look without icons
    animation = "zoom";
    extraConfig = {
      main = {
        prompt = " ";         # Simple prompt character
      };
    };
  };
  
  # === Dunst Configuration ==================================================
  myDunst = {
    enable = true;
    width = 300;
    height = 300;
    offset = "15x15";
    origin = "top-right";
    transparency = 10;
    frameWidth = 2;
    cornerRadius = 10;
    font = "JetBrains Mono 10";
  };
  
  # === User-specific Configurations ==========================================
  
  # Enable zsh for this user
  programs.zsh.enable = true;

  # User-specific git information
  programs.git = {
    userName = userFullName;
    userEmail = userEmail;
  };

  # Enable Starship prompt with the modular configuration
  myStarship.enable = true;
  
  # === Neovim Theme Override ================================================
  myNeovim.theme = "catppuccin";
  
  # === Browser Configuration ================================================
  myBrave = {
    enable = true;
  };
} 