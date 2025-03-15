{ lib, ... }:

with lib;

{
  # Define custom options for hosts
  options.devflake = {
    # List of users enabled on this host
    enabledUsers = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Users to enable on this host";
      example = [ "alice" "bob" ];
    };
  };
} 