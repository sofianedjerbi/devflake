{
  description = "DevFlake: Multi-User NixOS Configuration";

  # === Inputs ================================================================
  inputs = {
    # Package sources
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Catppuccin theme integration
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # === Outputs ===============================================================
  outputs = { self, nixpkgs, home-manager, catppuccin, ... }@inputs:
    let
      # Helper function for systems
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
      
      # Function to get all hosts
      getAllHosts = dir:
        let
          getSubDirs = dir:
            nixpkgs.lib.filterAttrs
              (name: type: type == "directory" && name != "_modules")
              (builtins.readDir dir);
        in getSubDirs dir;

      # Function to get all users
      getAllUsers = dir:
        let
          getSubDirs = dir:
            nixpkgs.lib.filterAttrs
              (name: type: type == "directory" && name != "_modules")
              (builtins.readDir dir);
        in getSubDirs dir;
      
      # Custom overlay for our packages
      overlay = final: prev: 
        (import ./pkgs { pkgs = prev; }).importAll final;
      
      # Helper to create NixOS configuration
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit hostname inputs;
          hostPath = ./hosts + "/${hostname}";
          usersPath = ./users;
        };
        modules = [
          # Common system settings
          ./hosts/_modules/default.nix

          # Host-specific hardware configuration
          (./hosts + "/${hostname}/hardware.nix")
          
          # Host-specific configuration
          (./hosts + "/${hostname}/default.nix")
          
          # Catppuccin theme
          catppuccin.nixosModules.catppuccin
          
          # Home Manager integration
          home-manager.nixosModules.home-manager
          
          # Custom overlays
          { nixpkgs.overlays = [ overlay ]; }
        ];
      };

      # Find all hosts
      hosts = getAllHosts ./hosts;
      
      # Find all users
      users = getAllUsers ./users;

      # Configure overlays for homeConfigurations
      hmOverlays = { config, ... }: {
        nixpkgs.overlays = [ overlay ];
      };
    in {
      # === Home Manager Configurations ========================================
      homeConfigurations = nixpkgs.lib.mapAttrs
        (username: _:
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = { 
              inherit username inputs;
              usersPath = ./users;
            };
            modules = [
              # Common user settings
              ./users/_modules/default.nix
              
              # User-specific configuration
              (./users + "/${username}/default.nix")
              
              # Catppuccin theme (globally configured)
              catppuccin.homeManagerModules.catppuccin
              
              # Apply custom overlays
              hmOverlays
            ];
          })
        users;
          
      # === NixOS Configurations ==============================================
      nixosConfigurations = nixpkgs.lib.mapAttrs
        (hostname: _: mkHost hostname)
        hosts;
      
      # === Development Shell ================================================
      devShells = forAllSystems (system:
        let 
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              nixpkgs-fmt
              nixd # Nix language server
            ];
            shellHook = ''
              echo "DevFlake development shell activated"
              export PS1="\[\e[1;34m\](flake-dev)\[\e[0m\] \w$ "
            '';
          };
        }
      );
      
      # === Formatter ========================================================
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
