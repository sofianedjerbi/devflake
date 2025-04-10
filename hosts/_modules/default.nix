{ config, pkgs, lib, ... }:

{
  imports = [
    # Import common options and home-manager configuration
    ./options.nix
    ./home-manager.nix
    ./desktop-environment.nix
  ];

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

  # === Display Server Configuration =========================================
  services = {
    # Enable X server for input drivers
    xserver = {
      enable = true;  # Needed for input driver support
      xkb = {
        layout = "us";
        variant = "altgr-intl";
      };
    };
    
    # Enable libinput for touchpad/mouse support
    libinput.enable = true;  # Touchpad support
  };

  # Allow unfree packages globally
  nixpkgs.config.allowUnfree = true;

  # Enable Docker daemon
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  # Default boot settings
  boot = {
    # Add terminal color parameters to the kernel command line
    kernelParams = [
      # Catppuccin Mocha color palette for virtual terminal
      "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
      "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
      "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
    ];

    loader = {
      # Disable other bootloaders to avoid conflicts
      systemd-boot.enable = false;
      grub.enable = false;
      
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      
      # Disable unused bootloaders
      generic-extlinux-compatible.enable = false;
      
      # Configure Limine bootloader
      limine = {
        enable = true;
        efiSupport = true;
        biosSupport = false;
        
        # Configure EFI installation behavior
        efiInstallAsRemovable = true;  # Install as removable for more compatibility
        
        # Max number of generations in boot menu
        maxGenerations = 10;
        
        # Allow editing boot entries (useful for troubleshooting)
        enableEditor = true;
        
        # Catppuccin Mocha color palette configuration - no wallpaper or branding
        style = {
          # Explicitly set empty wallpapers
          wallpapers = [];
          backdrop = "1e1e2e"; # Match background color
          
          graphicalTerminal = {
            palette = "1e1e2e;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4";
            brightPalette = "585b70;f38ba8;a6e3a1;f9e2af;89b4fa;f5c2e7;94e2d5;cdd6f4";
            background = "1e1e2e";
            foreground = "cdd6f4";
            brightBackground = "585b70";
            brightForeground = "cdd6f4";
          };
        };
      };
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
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
    # Ensure proper Unicode support for console
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
    ];
  };

  # Set default font packages with good Unicode support
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      # Fonts with good Unicode support
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      dejavu_fonts
      font-awesome
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "DejaVu Serif" "Noto Serif" ];
        sansSerif = [ "DejaVu Sans" "Noto Sans" ];
        monospace = [ "DejaVu Sans Mono" "Fira Code" ];
        emoji = [ "Noto Color Emoji" ];
      };
      # Enable subpixel rendering and hinting
      antialias = true;
      hinting.enable = true;
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
    psmisc
    
    # Development tools
    gcc # Required for compiling some plugins
    gnumake
    nixpkgs-fmt # Nix formatting
    nodePackages.nodejs # For LSP servers
    
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

    # Container tools
    docker

    # Bluetooth GUI utilities
    blueman
    
    # Logitech device utilities
    solaar       # Logitech Unifying Receiver configuration tool
    piper        # GTK application for configuring gaming mice
    libratbag    # DBus daemon for configuring gaming mice
    
    # Bootloader
    limine

    # Catppuccin theme-related packages
    papirus-icon-theme
    catppuccin-gtk
    catppuccin-cursors
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
    
    # Enable ratbagd for gaming mice configuration
    ratbagd.enable = true;
  };

  # Hardware settings
  hardware = {
    # Bluetooth settings
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    
    # Logitech device support
    logitech = {
      wireless = {
        enable = true;
        enableGraphical = true;  # Enable Solaar GUI
      };
    };
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