{
  description = "@sofianedjerbi dev env";

  # === Inputs ================================================================
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # === Outputs ===============================================================
  outputs = { self, nixpkgs, home, ... }:
    let
      host = "framework";
    in {
    
    # === System Configuration =================================================
    nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit host; };
      modules = [
        "${self}/modules/system/configuration.nix"
        "${self}/hosts/${host}/hardware.nix"

        # Allow unfree packages globally
        { nixpkgs.config.allowUnfree = true; }

        # Home Manager integration
        home.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.sofiane = import "${self}/home.nix";
        }

      ];
    };

    # === Home Manager Configuration (Standalone) ==============================
    homeConfigurations.sofiane = home.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ "${self}/home.nix" ];
    };

  };
}

