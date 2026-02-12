# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake-based configuration for a Proxmox LXC container. The configuration uses:
- **nixpkgs**: NixOS 25.11
- **home-manager**: User-level package management for `root` and `joemitz` users
- **claude-code**: Installed via home-manager for both users

## Architecture

### Configuration Structure

- **flake.nix**: Main flake definition with inputs (nixpkgs, home-manager, claude-code) and the `nixosConfigurations.default` output
- **configuration.nix**: Main system configuration that imports `proxmox.nix`. Defines system packages, SSH settings, users, and DNS caching
- **proxmox.nix**: Proxmox LXC-specific settings (privileged container, sandbox disabled, network management)

The flake defines a single NixOS configuration called `default` that combines all modules.

### Proxmox LXC Considerations

This configuration is designed for a privileged Proxmox LXC container:
- Nix sandbox is disabled (`nix.settings.sandbox = false`) due to LXC container limitations
- Network management is delegated to Proxmox (`proxmoxLXC.manageNetwork = false`)
- `fstrim` is disabled as the host handles it

## Common Commands

### Building and Deploying

Apply configuration changes (rebuild and switch):
```bash
sudo nixos-rebuild switch --flake .#default
```

Test configuration without making it the boot default:
```bash
sudo nixos-rebuild test --flake .#default
```

Build configuration without activating:
```bash
sudo nixos-rebuild build --flake .#default
```

### Flake Management

Update all flake inputs:
```bash
nix flake update
```

Update specific input (e.g., nixpkgs):
```bash
nix flake lock --update-input nixpkgs
```

Validate flake syntax:
```bash
nix flake check
```

Show flake outputs:
```bash
nix flake show
```

### Troubleshooting

View build logs with more detail:
```bash
sudo nixos-rebuild switch --flake .#default --show-trace
```

Rollback to previous generation:
```bash
sudo nixos-rebuild switch --rollback
```

List system generations:
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Development Notes

- The system uses flakes, so `nix-command` and `flakes` experimental features are enabled
- When modifying configurations, test with `nixos-rebuild test` before committing to `switch`
- The configuration targets a privileged LXC container, so avoid adding features that require full VM capabilities
