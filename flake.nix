{
  description = "Sofiane Djerbi's NixOS configuration";

  # === Inputs ================================================================
  inputs = {
    # Package sources
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # === Outputs ===============================================================
  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Define user parameters
      username = "sofiane";
      hostname = "framework";
      
      # Helper function to create NixOS configuration
      mkNixosConfig = { hostname }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit hostname username;
          inherit inputs;
        };
        modules = [
          ./modules/system/configuration.nix
          ./hosts/${hostname}/hardware.nix

          # Allow unfree packages globally
          { nixpkgs.config.allowUnfree = true; }

          # Home Manager integration
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit username;
                inherit inputs;
              };
            };
          }
        ];
      };
    in {
      # === System Configuration =================================================
      nixosConfigurations.${hostname} = mkNixosConfig { inherit hostname; };

      # === Home Manager Configuration (Standalone) ==============================
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = {
          inherit username;
          inherit inputs;
        };
      };
    };
}
