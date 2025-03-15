{ config, lib, pkgs, inputs, usersPath, ... }:

{
  # This module provides common Home Manager configuration for all hosts
  
  # Function to generate home-manager user configurations
  config.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    
    # This will be applied to all users enabled on a host
    users = lib.mkDefault (
      lib.genAttrs config.devflake.enabledUsers (username: {
        # Import the user's configuration file
        imports = [ (usersPath + "/${username}/default.nix") ];
        
        # Pass the username parameter to the module
        _module.args = { inherit username; };
        
        # User identity - these are required for proper Home Manager operation
        home.username = username;
        home.homeDirectory = "/home/${username}";
        # Note: home.stateVersion is set in users/_modules/default.nix
      })
    );
    
    extraSpecialArgs = {
      inherit inputs usersPath;
      hostname = config.networking.hostName;
    };
  };
} 