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
      # CPU settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      
      # Enhanced power savings on battery
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      
      # PCIe power management
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      
      # Battery charge thresholds (adjust according to your usage patterns)
      START_CHARGE_THRESH_BAT0 = 75;  # Start charging at 75%
      STOP_CHARGE_THRESH_BAT0 = 80;   # Stop charging at 80%
      
      # Wireless power saving
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      BLUETOOTH_POWER_STATE_ON_AC = 1;
      BLUETOOTH_POWER_STATE_ON_BAT = 0; # Automatically disable Bluetooth on battery
      
      # Runtime Power Management for devices
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      
      # Audio power saving
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      
      # Disk power saving
      DISK_DEVICES = "nvme0n1"; # Adjust for your SSD/hard drive device
      DISK_APM_LEVEL_ON_AC = "254 254";
      DISK_APM_LEVEL_ON_BAT = "128 128";
      DISK_SPINDOWN_TIMEOUT_ON_AC = "0 0";
      DISK_SPINDOWN_TIMEOUT_ON_BAT = "1 1";
      DISK_IOSCHED = "none none";
    };
  };

  # Thermal management
  services.thermald.enable = true;
  
  # Battery optimizations
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };
  
  # Add a powertop auto-tune service
  systemd.services.powertop-auto-tune = {
    description = "Powertop auto tune";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.powertop}/bin/powertop --auto-tune";
    };
  };

  # Enhanced power saving options
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Auto-suspending unused devices
  services.udev.extraRules = ''
    # Autosuspend USB devices when on battery
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="auto"
    
    # Autosuspend PCI devices when on battery
    ACTION=="add", SUBSYSTEM=="pci", ATTR{power/control}="auto"
    
    # Autosuspend for specific device types (like Bluetooth)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0000", ATTR{idProduct}=="0000", ATTR{power/control}="auto"
  '';
  
  # Deep sleep
  boot.kernelParams = [ 
    "mem_sleep_default=deep" 
    # Kernel parameters for power saving
    "intel_pstate=active" # Adjust if using AMD CPU
    "nvme.noacpi=1"
    "pcie_aspm=force"
    "i915.enable_psr=1" # For Intel graphics, remove if AMD
  ];
  
  # Screen brightness control with automatic dimming
  programs.light.enable = true;
  
  # Hyprland configuration with power optimizations
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  # === Desktop Environment ===================================================
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
    wlogout  # Added for power menu integration
    
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
    auto-cpufreq
    power-profiles-daemon
    acpi
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