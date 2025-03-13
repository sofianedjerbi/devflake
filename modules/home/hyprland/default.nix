{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myHyprland;
in {
  options.myHyprland = {
    enable = mkEnableOption "Enable my custom Hyprland configuration";
    
    wallpaper = mkOption {
      type = types.str;
      default = "~/Pictures/wallpapers/default.jpg";
      description = "Path to user wallpaper";
    };
    
    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Default terminal";
    };
    
    launcher = mkOption {
      type = types.str;
      default = "fuzzel";
      description = "Application launcher";
    };
  };

  config = mkIf cfg.enable {
    # Enable Hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      
      settings = {
        # Monitor configuration
        monitor = [
          ",preferred,auto,1"  # Automatically detect and configure monitors
        ];
        
        # Set user wallpaper via exec-once
        exec-once = [
          "${pkgs.hyprpaper}/bin/hyprpaper"
          "${pkgs.waybar}/bin/waybar"
          "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
          "swayidle -w timeout 300 'swaylock -f' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f'"
        ];
        
        # General configuration
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          
          # For all categories, see https://wiki.hyprland.org/Configuring/Variables/
          cursor_inactive_timeout = 4;
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
          
          # Shadows
          drop_shadow = true;
          shadow_range = 15;
          shadow_render_power = 2;
          shadow_offset = "0 5";
          "col.shadow" = "rgba(00000099)";
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
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, easeOut, slide"
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
          new_is_master = true;
        };
        
        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
        };
        
        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
        };
        
        # Window rules
        windowrule = [
          "float, ^(pavucontrol)$"
          "float, ^(nm-connection-editor)$"
          "float, ^(blueman-manager)$"
          "opacity 0.9, ^(Alacritty)$"
          "opacity 0.9, ^(kitty)$"
        ];
        
        # Environment variables
        env = [
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
          "$mainMod, E, exec, dolphin"
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
    
    # Ensure we have the necessary tools installed
    home.packages = with pkgs; [
      # Core tools for Hyprland
      hyprpaper
      fuzzel
      waybar
      networkmanagerapplet
      
      # Screenshot & utilities
      grim
      slurp
      wl-clipboard
      
      # Screen locking
      swaylock
      swayidle
      
      # Notification
      dunst
      
      # Terminal
      kitty
      
      # File manager
      xfce.thunar
      
      # Audio control
      pavucontrol
    ];
    
    # Set up Swaylock
    programs.swaylock = {
      enable = true;
      settings = {
        color = "000000";
        show-failed-attempts = true;
        indicator-idle-visible = false;
        indicator-radius = 100;
        indicator-thickness = 7;
        ring-color = "3b4252";
        inside-color = "2e3440";
        key-hl-color = "5e81ac";
        line-color = "88c0d0";
        separator-color = "3b4252";
      };
    };
  };
}
