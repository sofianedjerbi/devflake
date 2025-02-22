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

  # === X11 & GNOME ===========================================================
  services.xserver = {
    enable = true;
    libinput.enable = true;  # Touchpad support
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "intl";
    };
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
  services.power-profiles-daemon.enable = false; # Disable Gnome eco saver
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
