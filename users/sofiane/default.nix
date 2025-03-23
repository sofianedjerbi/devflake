{ config, pkgs, lib, inputs, username ? null, ... }:

let
  # Dynamic username resolution with fallbacks
  actualUsername = if username != null then username 
                   else if config.home.username or null != null then config.home.username
                   else "sofiane";
  userFullName = "Sofiane Djerbi";
  userEmail = "contact@sofianedjerbi.com";
  homeDir = "/home/${actualUsername}";
in {
  imports = [
    # Common user settings from _modules
    ../_modules/default.nix
    inputs.catppuccin.homeManagerModules.catppuccin
    ../../modules/home/brave
    ../../modules/home/starship
  ];

  # Basic user configuration
  home = {
    username = actualUsername;
    homeDirectory = homeDir;
    
    packages = with pkgs; [
      cursor
      discord
      obsidian
      spotify
      shell-gpt
    ];
  };

  # Desktop environment
  myDesktop = {
    enable = true;
    type = "hyprland";
    wallpaper = ../../resources/wallpapers/asian-town.png;
    terminal = "kitty";
    launcher = "fuzzel";
  };
  
  # UI components configuration
  myWaybar = {
    enable = true;
    position = "top";
  };
  
  myKitty = {
    enable = true;
    fontSize = 12;
    opacity = "1.0";
    extraSettings = {
      cursor_blink_interval = "0.5";
      cursor_shape = "beam";
    };
  };
  
  myFuzzel = {
    enable = true;
    font = "JetBrains Mono";
    fontSize = 8;
    width = 20;
    borderRadius = 10;
    backgroundOpacity = "ee";  # ~93% opacity
    showIcons = false;
    animation = "zoom";
    extraConfig = {
      main = {
        prompt = " ";
      };
    };
  };
  
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
  
  # Shell and development tools
  programs.zsh.enable = true;

  programs.git = {
    userName = userFullName;
    userEmail = userEmail;
  };

  myStarship.enable = true;
  
  # Theme and app settings
  myNeovim.theme = "catppuccin";
  
  myBrave = {
    enable = true;
  };
} 