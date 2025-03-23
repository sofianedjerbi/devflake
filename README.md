# DevFlake: Multi-User NixOS Configuration

A modular NixOS configuration using flakes that supports multiple hosts and users.

## Quick Start

```bash
# Deploy to current host
sudo nixos-rebuild switch --flake .#hostname

# Update packages
nix flake update

# Add host/user
./setup.sh add-host hostname
./setup.sh add-user username
```

## Features

- Automatic discovery of hosts and users
- Common settings shared across machines
- Per-user configurations
- Modular structure for easy extension

## Project Structure

```
├── flake.nix            # Main entry point
├── hosts/               # Host-specific configs
│   ├── _modules/        # Common host settings
│   └── hostname/        # Host configuration
├── users/               # User configs
│   ├── _modules/        # Common user settings
│   └── username/        # User configuration
├── modules/             # Shared modules
│   ├── desktop/         # Desktop environment modules
│   └── home/            # Home-manager modules
└── resources/           # Shared resources
```

## Adding Users to a Host

Edit the `enabledUsers` list in a host's config:

```nix
# hosts/hostname/default.nix
enabledUsers = [
  "sofiane"
  "newuser"
];
```

## Common Tasks

```bash
# Update specific input
nix flake lock --update-input nixpkgs

# Build Home Manager configuration
home-manager switch --flake .#username

# Deploy to specific host
./setup.sh deploy hostname
```

## Development

```bash
# Enter development shell
nix develop
```
