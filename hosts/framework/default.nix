{ config, pkgs, lib, hostname, inputs, usersPath, ... }:

{
  imports = [
    # Import system configuration
    ../../modules/system/configuration.nix
  ];

  # === Host Configuration ====================================================
  networking.hostName = hostname;

  # === User Configuration ====================================================
  # Define which users are enabled on this host
  devflake.enabledUsers = [
    "sofiane"
    # Add other users as needed
  ];

  # Configure system users
  users.users.sofiane = {
    isNormalUser = true;
    description = "Sofiane Djerbi";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # === Hardware-specific Settings ============================================
  hardware = {
    # Framework-specific hardware settings
    bluetooth.enable = true;
    
    # CPU-specific optimizations
    cpu.amd.updateMicrocode = true;
  };

  # === Framework Laptop Optimizations ========================================
  # Power management
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Thermal management
  services.thermald.enable = true;
  
  # Battery optimizations
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  
  # Deep sleep
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  
  # === Desktop Environment ===================================================
  # We use Hyprland
  programs.hyprland.enable = true;

  # Login manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # === Host-specific Packages ================================================
  environment.systemPackages = with pkgs; [
    # Required for Hyprland
    greetd.tuigreet
    waybar
    wofi
    wl-clipboard
    swaylock
    swayidle
    kitty
    fuzzel
    dunst
    grim
    slurp
    
    # File management tools
    yazi # Terminal file manager
    file # File type detection
    unar # Archive extraction
    ffmpegthumbnailer # Video thumbnails
    poppler # PDF support
    fd # Fast find alternative
    
    # Framework-specific utilities
    powertop
    fwupd
    networkmanagerapplet
    brightnessctl
  ];

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