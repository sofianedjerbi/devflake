{ config, pkgs, lib, host, ... }: {
  # === Nix System ============================================================
  system.stateVersion = "24.11"; 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # === Bootloader ============================================================
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # === Networking ============================================================
  networking = {
    hostName = host;
    networkmanager.enable = true;
  };

  # === Locale & Timezone =====================================================
  time.timeZone = "Europe/Paris";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings.LC_ALL = "en_US.UTF-8";
  };

  # === Hyprland Setup ========================================================
  programs.hyprland = {
    enable = true;
  };
  
  # === Display Manager (greetd + tuigreet) ==================================
  services.xserver = {
    enable = true;  # Still needed for input driver support
    libinput.enable = true;  # Touchpad support
    xkb = {
      layout = "us";
      variant = "intl";
    };
  };
  
  # Configure greetd with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # === Hyprland Utilities ===================================================
  environment.systemPackages = with pkgs; [
    greetd.tuigreet  # Add tuigreet
    
    # Core Wayland utilities
    waybar          # Status bar
    wofi            # Application launcher
    wl-clipboard    # Clipboard manager
    swaylock        # Screen locker
    swayidle        # Idle management
    
    # Useful utilities
    kitty
    fuzzel
    dunst           # Notification daemon
    networkmanagerapplet
    brightnessctl   # Brightness control
    
    # Screenshots and screen recording
    grim            # Screenshot utility
    slurp           # Region selection
  ];

  # === XDG Desktop Portal (for screen sharing) ==============================
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  # === Sound (PipeWire) ======================================================
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

  # === Bluetooth =============================================================
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # === Power Management ======================================================
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = false;
  powerManagement.enable = true;

  # === Misc ==================================================================
  programs.zsh.enable = true;

  # === Garbage Collection ====================================================
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  # === User Account ==========================================================
  users.users.sofiane = {
    isNormalUser = true;
    description = "Sofiane Djerbi";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
}

