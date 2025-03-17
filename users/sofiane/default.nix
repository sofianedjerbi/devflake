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
      cursor
      discord
      obsidian
      spotify
    ];
  };

  # === Hyprland Configuration ================================================
  myHyprland = {
    enable = true;
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
  services.dunst = {
    enable = true;
    
    settings = {
      global = {
        width = 300;
        height = 300;
        offset = "15x15";
        origin = "top-right";
        transparency = 10;
        frame_width = 2;
        corner_radius = 10;
        
        font = "JetBrains Mono 10";
        line_height = 4;
        markup = "full";
        format = "<b>%s</b>\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        word_wrap = true;
        
        stack_duplicates = true;
        hide_duplicate_count = false;
        
        show_indicators = false;
        
        min_icon_size = 0;
        max_icon_size = 64;
        
        title = "Dunst";
        class = "Dunst";
        
        # Set default browser for URLs
        browser = "${pkgs.brave}/bin/brave";
        
        # Mouse actions
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
      
      # Urgency settings retain timeouts but colors are managed by Catppuccin
      urgency_low = {
        timeout = 4;
        highlight = "none";
        script = "${pkgs.libcanberra}/bin/canberra-gtk-play -f /usr/share/sounds/freedesktop/stereo/message-new-instant.oga";
      };
      
      urgency_normal = {
        timeout = 8;
        highlight = "none";
        script = "${pkgs.libcanberra}/bin/canberra-gtk-play -f /usr/share/sounds/freedesktop/stereo/message.oga";
      };
      
      urgency_critical = {
        timeout = 0;  # Don't time out
        highlight = "none";
        script = "${pkgs.libcanberra}/bin/canberra-gtk-play -f /usr/share/sounds/freedesktop/stereo/dialog-warning.oga";
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