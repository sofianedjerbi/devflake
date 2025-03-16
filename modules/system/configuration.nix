{ config, pkgs, lib, ... }: 

{
  # === System Settings ======================================================
  # Override garbage collection settings from common config
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = lib.mkForce "--delete-older-than 14d";
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
} 