{
  description = "DevFlake: Multi-User NixOS Configuration";

  # Input sources
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # System configuration
  outputs = { self, nixpkgs, home-manager, catppuccin, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];
      
      # Directory scanning functions
      getAllHosts = dir:
        let
          getSubDirs = dir:
            nixpkgs.lib.filterAttrs
              (name: type: type == "directory" && name != "_modules")
              (builtins.readDir dir);
        in getSubDirs dir;

      getAllUsers = dir:
        let
          getSubDirs = dir:
            nixpkgs.lib.filterAttrs
              (name: type: type == "directory" && name != "_modules")
              (builtins.readDir dir);
        in getSubDirs dir;
      
      # Custom packages overlay
      overlay = final: prev: 
        (import ./pkgs { pkgs = prev; }).importAll final;
      
      # NixOS configuration builder
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          inherit hostname inputs;
          hostPath = ./hosts + "/${hostname}";
          usersPath = ./users;
        };
        modules = [
          ./hosts/_modules/default.nix
          (./hosts + "/${hostname}/hardware.nix")
          (./hosts + "/${hostname}/default.nix")
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          { 
            nixpkgs.overlays = [ overlay ];
            nixpkgs.config.allowUnfree = true;
          }
        ];
      };

      # Find all hosts and users
      hosts = getAllHosts ./hosts;
      users = getAllUsers ./users;

      # Home-manager overlay configuration
      hmOverlays = { config, ... }: {
        nixpkgs.overlays = [ overlay ];
      };
    in {
      # Home Manager configurations for each user
      homeConfigurations = nixpkgs.lib.mapAttrs
        (username: _:
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = { 
              inherit username inputs;
              usersPath = ./users;
            };
            modules = [
              ./users/_modules/default.nix
              (./users + "/${username}/default.nix")
              catppuccin.homeManagerModules.catppuccin
              hmOverlays
            ];
          })
        users;
          
      # NixOS configurations for each host
      nixosConfigurations = nixpkgs.lib.mapAttrs
        (hostname: _: mkHost hostname)
        hosts;
      
      # Development environment
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
      
      # Code formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
