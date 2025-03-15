{ config, pkgs, lib, ... }:

{
  # === Common NixOS settings for all hosts ===================================
  
  # Base system configuration 
  system.stateVersion = "24.11"; # Do not change after initial setup
  
  # Nix package manager settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
    };
    # Common garbage collection settings
    gc = {
      automatic = true;
      dates = lib.mkDefault "weekly";
      options = lib.mkDefault "--delete-older-than 30d";
    };
  };

  # Allow unfree packages globally
  nixpkgs.config.allowUnfree = true;

  # Default boot settings
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
    # Use the latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Common networking settings
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
  };
  
  # Basic localization settings (can be overridden by hosts)
  time.timeZone = "Europe/Paris";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
    };
  };

  # === Common User Configuration =============================================
  # Shared configuration for all users
  users.mutableUsers = lib.mkDefault true;
  
  # Enable zsh as primary shell
  programs.zsh.enable = true;

  # Default packages for all users
  environment.systemPackages = with pkgs; [
    # Core CLI utilities
    vim
    wget
    curl
    git
    htop
    file
    ripgrep
    unzip
    zsh
    neofetch
    bat
    fzf
    jq
    tree
    
    # System maintenance
    smartmontools  # Check drive health
    pciutils       # lspci command
    usbutils       # lsusb command
    
    # Hardware information
    lshw
    dmidecode
    
    # Networking tools
    inetutils
    mtr
    dig
  ];
  
  # Security settings
  security = {
    rtkit.enable = true;   # RealtimeKit for realtime scheduling
    sudo.wheelNeedsPassword = true;
    polkit.enable = true;  # Required for many desktop operations
  };
  
  # Common services on all systems
  services = {
    # Hardware-related services
    fwupd.enable = true;  # Firmware updates service
    
    # Basic system services
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    
    # Time synchronization
    timesyncd.enable = true;
  };
  
  # Console settings
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };
  
  # Program settings
  programs = {
    vim = {
      enable = true;      # Enable vim
      defaultEditor = true; # Use as default editor
    };
    mtr.enable = true;     # Network diagnostic tool
    htop.enable = true;    # System monitor
    iotop.enable = true;   # IO monitor
  };

  # === Audio Configuration ==================================================
  # Disable PulseAudio in favor of PipeWire
  services.pulseaudio.enable = false;
  
  # Enable PipeWire audio server
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
} 