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
    # Enable our custom Waybar configuration
    myWaybar = {
      enable = true;
      position = "top";
    };
    
    # Enable our custom Kitty configuration
    myKitty = {
      enable = true;
    };
    
    # Enable our custom Fuzzel configuration
    myFuzzel = {
      enable = true;
      terminal = cfg.terminal;
    };
    
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
          "swayidle -w timeout 120 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 180 'swaylock -f' timeout 300 'systemctl suspend' before-sleep 'swaylock -f'"
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
          
          # Shadows - let Catppuccin handle colors
          shadow = {
            enabled = true;
            size = 15;
            offset = "0 5";
          };

          # Add a drop shadow for windows
          drop_shadow = true;
        };
        
        # Animations
        animations = {
          enabled = true;
          
          bezier = [
            "myBezier, 0.05, 0.9, 0.1, 1.05"
            "easeOut, 0.36, 0, 0.66, -0.56"
            "easeIn, 0.12, 0.8, 0.4, 1"
          ];
          
          animation = [
            "windows, 1, 5, myBezier"      # Reduced animation time
            "windowsOut, 1, 5, default, popin 80%"
            "border, 1, 8, default"
            "fade, 1, 5, default"          # Faster fading
            "workspaces, 1, 4, easeOut, slide"
          ];
        };
        
        # Input settings
        input = {
          kb_layout = "us";
          kb_variant = "intl";
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
          "$mainMod, L, exec, swaylock"
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
        
        # Move/resize windows with mainMod + LMB/RMB and dragging
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
    
    # Ensure we have the necessary tools installed - combined with dunst packages
    home.packages = with pkgs; [
      # Core tools for Hyprland
      hyprpaper
      networkmanagerapplet
      
      # Screenshot & utilities
      grim
      slurp
      wl-clipboard
      
      # Screen locking
      swaylock
      swayidle
      
      # File manager - using Yazi instead of Thunar
      yazi
      
      # Audio control
      pavucontrol
      
      # Notification system
      dunst
      libcanberra-tools # For notification sounds
    ];
    
    # Set up Swaylock - Catppuccin module will handle theming
    programs.swaylock = {
      enable = true;
    };
  };
}
