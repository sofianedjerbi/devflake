{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myHyprland;
in {
  imports = [
    # Import our custom Waybar module
    ../waybar
    # Import our custom Kitty module
    ../kitty
    # Import our custom Fuzzel module
    ../fuzzel
    # Import our custom Hyprlock module
    ../hyprlock
    # Import our custom Hypridle module
    ../hypridle
  ];

  options.myHyprland = {
    enable = mkEnableOption "Enable custom Hyprland configuration";
    
    wallpaper = mkOption {
      type = types.path;
      description = "Path to wallpaper image";
      example = "./wallpapers/default.jpg";
    };
    
    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Default terminal emulator";
    };
    
    launcher = mkOption {
      type = types.str;
      default = "fuzzel";
      description = "Application launcher program";
    };
  };

  config = mkIf cfg.enable {
    # Enable our custom modules
    myHyprlock.enable = true;
    myHypridle.enable = true;
    
    # Enable Hyprland with Catppuccin theming
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      
      settings = {
        # Monitor configuration
        monitor = [
          ",preferred,auto,1,bitdepth,10"  # Add bitdepth to save power
        ];
        
        # Set user wallpaper via exec-once
        exec-once = [
          "${pkgs.hyprpaper}/bin/hyprpaper"
          "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
          "${pkgs.blueman}/bin/blueman-applet"
          "${pkgs.solaar}/bin/solaar --window=hide"
          "hypridle"
        ];
        
        # General configuration
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          layout = "dwindle";
          # Let Catppuccin handle border colors
        };
        
        # Decoration
        decoration = {
          rounding = 10;
          active_opacity = 1.0;
          inactive_opacity = 0.95;
          
          # Blur
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            new_optimizations = true;
            ignore_opacity = true;
          };
          
          # Shadow configuration
          shadow = {
            enabled = true;
            range = 15;
            render_power = 3;
            sharp = false;
            ignore_window = true;
            offset = "0 5";
            scale = 1.0;
            # Colors handled by Catppuccin theme
          };
        };
        
        # Animations
        animations = {
          enabled = true;
          
          bezier = [
            "easeOut, 0.27, 0, 0.38, 1"
            "easeIn, 0.12, 0.8, 0.4, 1"
            "gentle, 0.33, 1, 0.68, 1"
            "bounce, 0.1, 1.1, 0.2, 1.05"
          ];
          
          animation = [
            "windows, 1, 3, bounce"
            "windowsOut, 1, 3, easeOut, popin 80%"
            "windowsMove, 1, 3, gentle"
            "border, 1, 5, easeOut"
            "fade, 1, 3, easeIn" 
            "workspaces, 1, 3, gentle, slide"
            "layers, 1, 3, easeIn, slide"
          ];
        };
        
        # Input settings
        input = {
          kb_layout = "us";
          kb_variant = "altgr-intl";
          follow_mouse = 1;
          sensitivity = 0;  # -1.0 - 1.0, 0 means no modification
          
          touchpad = {
            natural_scroll = true;
            tap-to-click = true;
            disable_while_typing = true;
          };
        };
        
        # Layout/tiling settings
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        
        master = {
          #new_is_master = true;
        };
        
        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
        };
        
        # System settings
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          # Power saving options
          vfr = true;  # Variable refresh rate to save power
          vrr = 1;     # Enable adaptive sync
          disable_autoreload = true; # Save CPU cycles by disabling auto-reload
        };
        
        # Window rules
        windowrule = [
          "float, ^(pavucontrol)$"
          "float, ^(nm-connection-editor)$"
          "float, ^(blueman-manager)$"
          "float, ^(yazi)$"
          "size 80% 80%, ^(yazi)$"
          "center, ^(yazi)$"
          "opacity 0.9, ^(Alacritty)$"
          "opacity 0.9, ^(kitty)$"
        ];
        
        # Environment variables
        env = [
          "HYPRGAMEMODE,0"
          "XCURSOR_SIZE,24"
          "QT_QPA_PLATFORMTHEME,qt5ct"
          "QT_QPA_PLATFORM,wayland"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "GDK_BACKEND,wayland,x11"
          "SDL_VIDEODRIVER,wayland"
          "CLUTTER_BACKEND,wayland"
          "MOZ_ENABLE_WAYLAND,1"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
        ];
        
        # Key bindings
        "$mainMod" = "SUPER";
        "$terminal" = cfg.terminal;
        "$launcher" = cfg.launcher;
        
        bind = [
          # Basic bindings
          "$mainMod, Return, exec, $terminal"
          "$mainMod, Q, killactive,"
          "$mainMod SHIFT, Q, exit,"
          "$mainMod, E, exec, $terminal --class yazi -e yazi"
          "$mainMod, F, togglefloating,"
          "$mainMod, Space, exec, $launcher"
          "$mainMod, L, exec, hyprlock"
          "$mainMod, V, togglesplit,"
          "$mainMod, P, pseudo,"
          "$mainMod, F11, fullscreen, 0"
          
          # Move focus with mainMod + arrow keys
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          
          # Move window with mainMod + SHIFT + arrow keys
          "$mainMod SHIFT, left, movewindow, l"
          "$mainMod SHIFT, right, movewindow, r"
          "$mainMod SHIFT, up, movewindow, u"
          "$mainMod SHIFT, down, movewindow, d"
          
          # Switch workspaces with mainMod + [0-9]
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          
          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          
          # Scroll through existing workspaces with mainMod + scroll
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          
          # Media keys
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          
          # Brightness control
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          
          # Screenshot
          "$mainMod SHIFT, S, exec, grim -g \"$(slurp)\" - | wl-copy"
          "$mainMod, Print, exec, grim - | wl-copy"
        ];
        
        # Mouse bindings
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
    
    # Configure hyprpaper
    home.file.".config/hypr/hyprpaper.conf".text = ''
      preload = ${cfg.wallpaper}
      wallpaper = ,${cfg.wallpaper}
      ipc = off
    '';
    
    # Ensure we have the necessary tools installed
    home.packages = with pkgs; [
      # Core tools for Hyprland
      hyprpaper
      networkmanagerapplet
      
      # Screenshot & utilities
      grim
      slurp
      wl-clipboard

      # File manager - using Yazi instead of Thunar
      yazi
      
      # Audio control
      pavucontrol
      
      # Notification system
      dunst
      libcanberra # For notification sounds
    ];
  };
} 
