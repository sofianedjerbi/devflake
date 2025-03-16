{ config, pkgs, lib, inputs, username ? null, themeColors ? null, ... }:

let
  # User information
  actualUsername = if username != null then username 
                   else if config.home.username or null != null then config.home.username
                   else "sofiane";
  userFullName = "Sofiane Djerbi";
  userEmail = "contact@sofianedjerbi.com";
  homeDir = "/home/${actualUsername}";
  
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
in {
  imports = [
    # Import common user settings
    ../_modules/default.nix
    
    # Import theme configuration
    ../../modules/home/theme
    
    # Import hyprland configuration
    ../../modules/home/hyprland
    
    # Import waybar configuration
    ../../modules/home/waybar
    
    # Import kitty configuration
    ../../modules/home/kitty
  ];

  # === Theme Configuration ==================================================
  myTheme = {
    enable = true;
    name = "catppuccin-mocha";
  };

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
    theme = "catppuccin-mocha";
    position = "top";
  };
  
  # === Kitty Configuration ==================================================
  myKitty = {
    enable = true;
    theme = "catppuccin-mocha";
    fontSize = 12;
    opacity = "0.95";
    extraSettings = {
      # Any additional custom settings can go here
      cursor_blink_interval = "0.5";
      cursor_shape = "beam";
    };
  };
  
  # === Notification Configuration ============================================
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "10x50";
        origin = "top-right";
        transparency = 10;
        frame_color = "#${colors.purple}";
        separator_color = "frame";
        font = "JetBrains Mono Nerd Font 10";
        corner_radius = 10;
        frame_width = 2;
      };
      
      urgency_low = {
        background = "#${colors.background}";
        foreground = "#${colors.foreground}";
        timeout = 5;
      };
      
      urgency_normal = {
        background = "#${colors.background}";
        foreground = "#${colors.foreground}";
        timeout = 10;
      };
      
      urgency_critical = {
        background = "#${colors.background}";
        foreground = "#${colors.red}";
        frame_color = "#${colors.red}";
        timeout = 0;
      };
    };
  };

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