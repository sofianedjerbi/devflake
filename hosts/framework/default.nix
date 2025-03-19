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
  };
  
  # === Power Management Strategy ============================================
  # Use power-profiles-daemon (recommended for AMD) with auto-switching
  services.power-profiles-daemon.enable = true;
  
  # Thermal management
  services.thermald.enable = true;
  
  # AMD-specific settings for CPU power management
  boot.kernelParams = [
    "mem_sleep_default=deep"     # Better sleep mode
    "pcie_aspm=off"              # USB-C stability
    "amdgpu.sg_display=0"        # Fix display flickering
    "amdgpu.abmlevel=0"          # Better color accuracy
    "nvme_core.default_ps_max_latency_us=0"  # NVMe stability
    "amd_pstate=active"          # Enable AMD pstate driver 
    "amd_pstate.shared_mem=1"    # Enable shared memory for pstate
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
    
    # Battery charge thresholds (75% start, 80% stop)
    SUBSYSTEM=="power_supply", ATTR{status}=="Charging", ATTR{capacity}=="[80-100]", RUN+="${pkgs.bash}/bin/sh -c 'echo 0 > /sys/class/power_supply/BAT0/charge_control_end_threshold'"
    SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-75]", RUN+="${pkgs.bash}/bin/sh -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold'"
    
    # Trigger power profile changes
    ACTION=="change", SUBSYSTEM=="power_supply", ATTR{type}=="Mains", RUN+="${pkgs.systemd}/bin/systemctl start power-profile-switcher.service"
  '';
  
  # Prevent the cros-usbpd-charger errors
  boot.extraModprobeConfig = "blacklist cros_ec_typec";
  
  # Brightness control
  programs.light.enable = true;
  
  # === Framework-specific Packages ==========================================
  environment.systemPackages = with pkgs; [
    powertop
    fwupd
    networkmanagerapplet
    brightnessctl
    auto-cpufreq
    power-profiles-daemon
    acpi
  ];

  # This value determines the NixOS release from which the default
} 
