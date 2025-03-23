{ config, pkgs, lib, ... }:

{
  # === Common Desktop Environment Packages ===================================
  environment.systemPackages = with pkgs; [
    # Wayland essentials
    waybar
    wl-clipboard
    kitty
    fuzzel
    grim  # Screenshot utility
    slurp # Screen area selection
    wlogout
    
    # Hyprland specific tools
    hypridle
    hyprlock
    
    # File management tools
    yazi # Terminal file manager
    file # File type detection
    unar # Archive extraction
    ffmpegthumbnailer # Video thumbnails
    poppler # PDF support
    fd # Fast find alternative

    greetd.tuigreet
  ];

  # === Login Manager and Window Manager Configuration =======================
  # Login manager configuration
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland --theme 'text=white;time=cyan;container=black;border=cyan;title=cyan;greet=lightgray;prompt=white;input=cyan;action=lightgray;button=cyan'";
        user = "greeter";
      };
    };
  };

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # === Wayland/XDG Configuration =============================================
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };
  
  # Auto-mount removable media
  services.gvfs.enable = true;
  services.udisks2.enable = true;
} 