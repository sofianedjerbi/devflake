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
    
    # Import hyprland configuration
    ../../modules/home/hyprland
    
    # Import waybar configuration
    ../../modules/home/waybar
    
    # Import kitty configuration
    ../../modules/home/kitty
    
    # Import fuzzel configuration
    ../../modules/home/fuzzel
  ];

  # === Basic User Information ================================================
  home = {
    username = actualUsername;
    homeDirectory = homeDir;
    
    # === User-specific GUI applications ======================================
    packages = with pkgs; [
      # GUI Applications
      code-cursor
      brave
      spotify
    ];
    
    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      SHELL = "${pkgs.zsh}/bin/zsh";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  # === Hyprland Configuration ================================================
  myHyprland = {
    enable = true;
    wallpaper = ../../resources/wallpapers/neon.jpg;
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
    opacity = "0.95";
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
    fontSize = 12;
    width = 35;
    borderRadius = 10;
    backgroundOpacity = "ee";  # ~93% opacity
    showIcons = false;         # Elegant look without icons
    animation = "zoom";
    extraConfig = {
      main = {
        prompt = "❯ ";         # Simple prompt character
      };
    };
  };
  
  # === Notification Configuration ============================================
  services.dunst.enable = true;

  # === User-specific Configurations ==========================================
  
  # Enable zsh for this user
  programs.zsh.enable = true;

  # User-specific git information
  programs.git = {
    userName = userFullName;
    userEmail = userEmail;
  };

  # Terminal prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$username@$hostname $directory $git_branch $character";
      username = { show_always = true; };
      directory = { truncate_to_repo = false; };
      git_branch = { symbol = "🌱 "; };
    };
  };
  
  # === Neovim Theme Override ================================================
  myNeovim.theme = "catppuccin";
} 