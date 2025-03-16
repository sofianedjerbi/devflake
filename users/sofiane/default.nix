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
  programs.kitty = {
    enable = true;
    settings = {
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
      
      # Terminal window settings
      background_opacity = "0.95";
      window_padding_width = 8;
      confirm_os_window_close = 0;
      enable_audio_bell = false;
    };
    
    # Configure font
    font = {
      name = "JetBrains Mono Nerd Font";
      size = 12;
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