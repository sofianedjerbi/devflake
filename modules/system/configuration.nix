{ config, pkgs, lib, hostname ? "framework", username ? "sofiane", ... }: 

let
  userFullName = "Sofiane Djerbi";
  locale = "en_US.UTF-8";
  timeZone = "Europe/Paris";
in {
  # === Nix System Settings ===================================================
  system = {
    stateVersion = "24.11"; # Do not change after initial setup
  };
  
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    # Garbage collection settings
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
    };
  };

  # === Bootloader ============================================================
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # === Networking ============================================================
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    # Use DHCP by default
    useDHCP = lib.mkDefault true;
  };

  # === Locale & Timezone =====================================================
  time.timeZone = timeZone;
  i18n = {
    defaultLocale = locale;
    extraLocaleSettings.LC_ALL = locale;
  };

  # === Desktop Environment ===================================================
  # --- Hyprland ---
  programs.hyprland.enable = true;
  
  # --- Display and Input Configuration ---
  services.xserver = {
    enable = true;  # Needed for input driver support
    libinput.enable = true;  # Touchpad support
    xkb = {
      layout = "us";
      variant = "intl";
    };
  };
  
  # --- Login Manager ---
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # === Desktop Environment Packages ==========================================
  environment.systemPackages = with pkgs; [
    # Login manager
    greetd.tuigreet
    
    # Wayland utilities
    waybar          # Status bar
    wofi            # Application launcher
    wl-clipboard    # Clipboard manager
    swaylock        # Screen locker
    swayidle        # Idle management
    
    # Terminal and UI
    kitty
    fuzzel
    dunst           # Notification daemon
    
    # System utilities
    networkmanagerapplet
    brightnessctl   # Brightness control
    
    # Screen capture
    grim            # Screenshot utility
    slurp           # Region selection
  ];

  # === Screen Sharing Support ===============================================
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  # === Audio ================================================================
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # === Hardware Management ==================================================
  # --- Bluetooth ---
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # --- Power Management ---
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;
  powerManagement.enable = true;

  # === User Account =========================================================
  users.users.${username} = {
    isNormalUser = true;
    description = userFullName;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Enable ZSH for user shell
  programs.zsh.enable = true;
}

