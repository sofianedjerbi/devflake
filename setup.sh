#!/usr/bin/env bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored text
print_color() {
  local color=$1
  local text=$2
  echo -e "${color}${text}${NC}"
}

print_help() {
  echo "NixOS Configuration Setup Script"
  echo ""
  echo "Usage:"
  echo "  $0 [command] [options]"
  echo ""
  echo "Commands:"
  echo "  add-host [hostname]       Add a new host configuration"
  echo "  add-user [username]       Add a new user configuration"
  echo "  deploy [hostname]         Deploy configuration to a specific host"
  echo "  help                      Show this help message"
  echo ""
}

add_host() {
  local hostname=$1
  
  if [ -z "$hostname" ]; then
    print_color "$RED" "Error: You must provide a hostname"
    print_help
    exit 1
  fi
  
  # Check if host already exists
  if [ -d "hosts/$hostname" ]; then
    print_color "$YELLOW" "Host '$hostname' already exists. Aborting."
    exit 1
  fi
  
  print_color "$BLUE" "Creating host configuration for '$hostname'..."
  
  # Create the host directory
  mkdir -p "hosts/$hostname"
  
  # Create default.nix
  cat > "hosts/$hostname/default.nix" << EOF
{ config, pkgs, lib, hostname, inputs, usersPath, ... }:

let
  # Define enabled users for this host
  enabledUsers = [
    "sofiane"
    # Add other users as needed
  ];

  # Convert users list to home-manager configs
  userConfigs = map (username: {
    name = username;
    value = import (usersPath + "/\${username}/default.nix");
  }) enabledUsers;
in {
  imports = [
    # Import any host-specific modules here
    ../../modules/system/configuration.nix
  ];

  # === Host-specific settings ================================================
  networking.hostName = hostname;

  # Configure users for this host
  home-manager.users = builtins.listToAttrs userConfigs;

  # Add your host-specific configuration here
}
EOF
  
  # Create an empty hardware.nix
  cat > "hosts/$hostname/hardware.nix" << EOF
# Hardware configuration for $hostname
# This file should be generated with 'nixos-generate-config --show-hardware-config'
# and then customized as needed.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Add your hardware-specific configuration here
  # Example:
  # boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  # boot.initrd.kernelModules = [ ];
  # boot.kernelModules = [ "kvm-intel" ];
  # boot.extraModulePackages = [ ];
}
EOF
  
  print_color "$GREEN" "Host '$hostname' created successfully."
  print_color "$YELLOW" "Don't forget to:"
  print_color "$YELLOW" "1. Generate hardware configuration with 'nixos-generate-config --show-hardware-config'"
  print_color "$YELLOW" "2. Update the hardware.nix file with your specific hardware configuration"
  print_color "$YELLOW" "3. Add host-specific settings in default.nix"
}

add_user() {
  local username=$1
  
  if [ -z "$username" ]; then
    print_color "$RED" "Error: You must provide a username"
    print_help
    exit 1
  fi
  
  # Check if user already exists
  if [ -d "users/$username" ]; then
    print_color "$YELLOW" "User '$username' already exists. Aborting."
    exit 1
  fi
  
  print_color "$BLUE" "Creating user configuration for '$username'..."
  
  # Create the user directory
  mkdir -p "users/$username"
  
  # Create default.nix
  cat > "users/$username/default.nix" << EOF
{ config, pkgs, lib, username, inputs, ... }:

let
  # Define personal information
  userFullName = "$username";
  userEmail = "$username@example.com";
  homeDir = "/home/\${username}";
in {
  imports = [
    # Import user-specific modules here
  ];

  # === Home Manager Configuration ============================================
  home = {
    inherit username;
    homeDirectory = homeDir;
    stateVersion = "24.11"; # Do not change after initial setup
    
    # === Packages ============================================================
    packages = with pkgs; [
      # Terminal utilities
      neofetch
      htop
      
      # Add your preferred packages here
    ];
    
    # Environment variables
    sessionVariables = {
      EDITOR = "vim";
    };
  };

  # === Program Configurations ================================================
  
  # Shell configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -lah";
      update = "sudo nixos-rebuild switch";
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = userFullName;
    userEmail = userEmail;
  };

  # Add more program configurations as needed
}
EOF
  
  print_color "$GREEN" "User '$username' created successfully."
  print_color "$YELLOW" "Don't forget to:"
  print_color "$YELLOW" "1. Update the user information in users/$username/default.nix"
  print_color "$YELLOW" "2. Add the user to the enabledUsers list in the appropriate host configuration"
}

deploy() {
  local hostname=$1
  
  if [ -z "$hostname" ]; then
    print_color "$RED" "Error: You must provide a hostname"
    print_help
    exit 1
  fi
  
  # Check if host exists
  if [ ! -d "hosts/$hostname" ]; then
    print_color "$RED" "Error: Host '$hostname' does not exist"
    exit 1
  fi
  
  print_color "$BLUE" "Deploying configuration to '$hostname'..."
  
  sudo nixos-rebuild switch --flake ".#$hostname"
  
  print_color "$GREEN" "Configuration deployed successfully."
}

case "$1" in
  add-host)
    add_host "$2"
    ;;
  add-user)
    add_user "$2"
    ;;
  deploy)
    deploy "$2"
    ;;
  help)
    print_help
    ;;
  *)
    print_help
    exit 1
    ;;
esac 