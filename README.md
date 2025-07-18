# NixOS Configuration

This repository contains my personal NixOS configuration using Nix Flakes for declarative and reproducible system management.

## What is Nix?

Nix is a powerful package manager and build system that allows for declarative, reproducible, and reliable package management. NixOS is a Linux distribution built around the Nix package manager, where the entire system configuration is declared in Nix files.

Key benefits of Nix/NixOS:

- **Reproducible**: Same configuration produces identical systems
- **Declarative**: System state is described in configuration files
- **Rollback**: Easy rollback to previous configurations
- **Isolation**: Different package versions can coexist without conflicts
- **Atomic upgrades**: System updates are atomic and safe

## Repository Structure

```
.
├── flake.nix               # Main flake configuration
├── flake.lock              # Lock file for reproducible builds
├── hosts/                  # Host-specific configurations
│   ├── scorpius-cl-01/     # Main desktop configuration
│   └── scorpius-cl-01-wsl/ # WSL configuration (No longer used at the moment)
├── modules/                # Reusable configuration modules
│   ├── assets/             # Static assets (wallpapers, icons)
│   ├── bin/                # Custom scripts
│   ├── dotfiles/           # Application configuration files
│   ├── home-manager/       # Home Manager modules
│   ├── nixos/              # NixOS system modules
│   ├── specialisations/    # NixOS specialisations (boot options)
│   └── themes/             # Custom themes and styling
├── overlays/               # Package overlays
└── utilities/              # Utility scripts and tools
    ├── cinnamon-settings/  # Cinnamon settings web interface
    └── installation/       # Installation scripts
```

## Key Features

- **Flake-based configuration**: Modern Nix flakes for better dependency management
- **Multiple host support**: Separate configurations for desktop and WSL
- **Home Manager integration**: Declarative user environment management
- **Windows VM**: VGPU passthrough setup for running Windows applications with maximum performance on the VM and host at the same time
- **Development environment**: Comprehensive VS Code setup with extensions
- **Desktop environment**: Cinnamon desktop with custom themes and configurations
- **Specialisations**: Different boot options for gaming vs. regular use
- **Custom packages**: Integration with personal NUR repository

## NUR Repository

This configuration integrates with my personal [NUR (Nix User Repository)](https://github.com/cyrilschreiber3/nur-packages) which contains:

- Custom packages not available in nixpkgs
- Personal forks and modifications
- Specialized tools and utilities

The NUR packages are imported via the `mypkgs` flake input and made available through overlays.

## Repository Branches

This repository contains multiple branches for different use cases:

- **master**: Desktop/workstation configurations (scorpius-cl-01, more could be added in the future)
- **servers**: Homelab server configurations running NixOS
- **bar-sika**: Raspberry Pi configuration for the bar's firetruck siren I built with a friend for our station [Integrated with the bar-sika repository](https://github.com/cyrilschreiber3/bar-sika)

Each branch maintains its own host configurations and specialized modules for their specific purposes. The **servers** and **bar-sika** branches import this master branch to reuse the common modules and configurations defined here.

## Usage

### Initial Setup

1. Boot from the NixOS live image
2. Run the installation script: `curl -L https://raw.githubusercontent.com/cyrilschreiber3/nixconfig/main/utilities/installation/install.sh | bash`
3. The script will guide you through:
   - Selecting the target drive
   - Formatting and partitioning with disko
   - Configuring hardware settings
   - Installing NixOS with this configuration

For subsequent updates after installation:

```bash
rebuild
```

### Available Tasks

The repository includes VS Code tasks for easy system management:

- **NixOS Rebuild**: Standard system rebuild
- **NixOS Force Rebuild**: Force rebuild ignoring errors
- **NixOS Update and Force Rebuild**: Update flake inputs and rebuild
- **Serve settings app**: Start the Cinnamon settings web interface

### Custom Scripts

- `modules/bin/rebuild.sh`: Automated rebuild script with error handling (aliased as `rebuild`)
- `modules/bin/startMerlin.sh`: Windows VM startup script with vGPU configuration
- `utilities/installation/install.sh`: System installation helper
