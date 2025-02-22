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
      host = "vivobook";
    in {
    
    # === System Configuration =================================================
    nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit host; };
      modules = [
        ./modules/system/configuration.nix
        ./host/${host}/hardware.nix # Change on different hardware

        # Allow unfree packages globally
        { nixpkgs.config.allowUnfree = true; }

        # Home Manager integration
        home.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.sofiane = import ./home.nix;
        }

      ];
    };

    # === Home Manager Configuration (Standalone) ==============================
    homeConfigurations.sofiane = home.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
    };

  };
}
