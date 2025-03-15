# DevFlake: Multi-User NixOS Configuration

A parameterized NixOS configuration using flakes that supports multiple hosts and users.

## Quick Start

```bash
# Deploy to your current host
sudo nixos-rebuild switch --flake .#hostname

# Update all packages
nix flake update

# Add a new host
./setup.sh add-host hostname

# Add a new user
./setup.sh add-user username
```

## Features

- ✅ Automatic discovery of hosts and users
- ✅ Common settings shared across machines
- ✅ Per-user configurations
- ✅ Easy extension with modules

## Structure

```
├── flake.nix            # Main entry point
├── hosts/               # Host-specific configs
│   ├── _modules/        # Common host settings
│   └── framework/       # Example host
├── users/               # User configs
│   ├── _modules/        # Common user settings
│   └── sofiane/         # Example user
└── modules/             # Shared modules
```

## Adding Users to a Host

Edit the `enabledUsers` list in a host's config:

```nix
# hosts/framework/default.nix
enabledUsers = [
  "sofiane"
  "user1"
  "user2"
];
```

## Common Tasks

```bash
# Update specific input
nix flake lock --update-input nixpkgs

# Build Home Manager configuration for a user
home-manager switch --flake .#username

# Deploy to specific host
./setup.sh deploy hostname
```

## Development

```bash
# Enter development shell
nix develop
```
