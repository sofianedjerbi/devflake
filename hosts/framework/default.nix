{ config, pkgs, lib, hostname, inputs, usersPath, ... }:

{
  # === Host Configuration ====================================================
  networking.hostName = hostname;

  # Override garbage collection settings for this host
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = lib.mkForce "--delete-older-than 14d";
  };

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

  # === Framework Laptop Power Optimizations =================================
  # Comprehensive power management
  powerManagement = {
    enable = true;
    powertop.enable = true;
    # Aggressive power saving on battery
    cpuFreqGovernor = "powersave";
  };
  
  # === Power Management Strategy ============================================
  # Use power-profiles-daemon (recommended for AMD) with auto-switching
  services.power-profiles-daemon.enable = true;
  
  # Thermal management
  services.thermald.enable = true;
  
  # Enable laptop-mode-tools for additional power savings
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
  };
  
  # Enable GNOME power manager for additional controls
  services.xserver.displayManager.gdm.autoSuspend = false;
  
  # AMD-specific settings for CPU power management
  boot.kernelParams = [
    "mem_sleep_default=deep"     # Better sleep mode
    "pcie_aspm=off"              # USB-C stability
    "amdgpu.sg_display=0"        # Fix display flickering
    "amdgpu.abmlevel=0"          # Better color accuracy
    "nvme_core.default_ps_max_latency_us=0"  # NVMe stability
    "amd_pstate=active"          # Enable AMD pstate driver 
    "amd_pstate.shared_mem=1"    # Enable shared memory for pstate
    "amdgpu.runpm=1"             # Better GPU power management
    "amdgpu.bapm=1"              # Better APU power management
  ];
  
  # More robust auto-switch power profiles based on power source
  systemd.services.power-profile-switcher = {
    description = "Switch power profiles based on power source";
    path = with pkgs; [ power-profiles-daemon coreutils gnugrep ];
    script = ''
      # Simple logging with echo
      if grep -q 1 /sys/class/power_supply/*/online 2>/dev/null; then
        echo "AC connected - setting performance profile"
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance || true
      else
        echo "On battery - setting power-saver profile"
        ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver || true
      fi
      
      # Always return success
      exit 0
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
    };
  };
  
  # Improved profile switching trigger for system events
  systemd.services.power-profile-ac-connected = {
    description = "Handle power profile on AC changes";
    wantedBy = [ "multi-user.target" ];
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --no-block start power-profile-switcher.service";
    };
  };
  
  # Run the power profile switcher at boot
  systemd.services.power-profile-boot = {
    description = "Set initial power profile based on AC status";
    wantedBy = [ "multi-user.target" ];
    after = [ "power-profiles-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --no-block start power-profile-switcher.service";
    };
  };
  
  # Consolidated udev rules for USB, power management and Framework-specific fixes
  services.udev.extraRules = ''
    # Framework-specific USB fixes (prevents error messages)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="pci", TEST!="class", ATTR{power/control}="auto"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{class}=="0x0c0330", ATTR{power/control}="on"
    
    # Prevent unwanted wakeups in backpack (screen flex)
    SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled", ATTR{driver/1-1.1.1.4/power/wakeup}="disabled"
    SUBSYSTEM=="usb", DRIVERS=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0014", ATTR{power/wakeup}="disabled", ATTR{driver/1-1.1.1.4/power/wakeup}="disabled"
    
    # Allow battery to charge up to 100%
    # Removed restrictive battery threshold rules
    
    # Trigger power profile changes
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${pkgs.systemd}/bin/systemctl start power-profile-switcher.service"
    
    # NVMe power saving
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x144d", ATTR{device}=="0xa808", ATTR{power/control}="auto"
    
    # Audio power saving - 1 second timeout
    ACTION=="add", SUBSYSTEM=="module", KERNEL=="snd_*", RUN+="${pkgs.bash}/bin/sh -c 'echo 1 > /sys/module/snd_hda_intel/parameters/power_save'"
    
    # SATA power savings
    ACTION=="add", SUBSYSTEM=="scsi_host", ATTR{link_power_management_policy}="med_power_with_dipm"
  '';
  
  # Wireless power management - using the correct option
  networking.networkmanager = {
    wifi.powersave = true;
    # Enable WiFi power saving features
    wifi.scanRandMacAddress = true;
  };
  
  # Prevent the cros-usbpd-charger errors
  boot.extraModprobeConfig = ''
    blacklist cros_ec_typec
    
    # Audio powersaving
    options snd_hda_intel power_save=1
    options snd_ac97_codec power_save=1
    
    # NVMe powersaving
    options nvme_core default_ps_max_latency_us=5500
  '';
  
  # Improve SSD lifespan with less frequent TRIM
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };
  
  # Brightness control and automatic dimming
  programs.light.enable = true;
  
  # === Framework-specific Packages ==========================================
  environment.systemPackages = with pkgs; [
    # Power management tools
    powertop
    fwupd
    brightnessctl
    power-profiles-daemon
    acpi
    
    # Battery monitoring and power saving
    upower
    auto-cpufreq
    s-tui
    
    # System monitoring
    lm_sensors
    htop
    nvme-cli
    
    # Network management
    networkmanagerapplet
    iw
  ];
  
  # Configure automatic suspend for better battery life
  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "lock";  # Lock when lid closed on AC power
    extraConfig = ''
      HandlePowerKey=suspend
      IdleAction=suspend
      IdleActionSec=300
      LidSwitchIgnoreInhibited=no
      HoldoffTimeoutSec=10
    '';
  };
  
  # Enable networking services
  systemd.services.NetworkManager-wait-online.enable = true;
  
  # Reduce swappiness to improve performance
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.laptop_mode" = 5;
    "vm.dirty_writeback_centisecs" = 1500;
  };
} 
