# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS flake-based configuration for a Proxmox LXC container. The configuration uses:
- **nixpkgs**: NixOS 25.11
- **home-manager**: User-level package management for `root` and `joemitz` users
- **claude-code**: Installed via home-manager for both users

## Architecture

### Configuration Structure

- **flake.nix**: Main flake definition with inputs (nixpkgs, home-manager, claude-code) and the `nixosConfigurations.default` output. Imports `configuration.nix` and `home.nix` modules.
- **configuration.nix**: Main system configuration that imports `proxmox.nix` and `containers/plex.nix`. Defines system-level settings including:
  - SSH configuration (root login disabled)
  - NFS mount for TrueNAS Plex share (`/mnt/truenas/plex` mounted read-only)
  - Firewall rules (Plex port 32400)
  - Tailscale VPN
  - DNS caching via systemd-resolved
  - User accounts (joemitz with wheel group, passwordless sudo)
- **home.nix**: Home-manager configuration for the `joemitz` user. Manages user-level packages and programs using a modular pattern:
  - Packages: claude-code, gh, jq
  - Git configuration with custom aliases and GitHub CLI credential helper
  - Tmux configuration with custom keybindings
- **proxmox.nix**: Proxmox LXC-specific settings (privileged container, sandbox disabled, network management)
- **containers/plex.nix**: Declarative NixOS container running Plex Media Server
  - Ephemeral container (starts fresh each boot)
  - Host networking mode for Plex discovery
  - Persistent config via bind mount to `/home/joemitz/containers/plex/config`
  - Multiple read-only media directories bound from TrueNAS NFS share
  - Custom UID/GID (1000:1000) for permission matching

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

## Package Management

### Adding New Packages

**User-level packages** (recommended for most tools): Edit `home.nix` and add to `home.packages`:
```nix
home.packages = [
  claude-code.packages.x86_64-linux.default
  pkgs.gh
  pkgs.jq
  pkgs.your-new-package  # Add here
];
```

**System-level packages**: Only for system services or when needed globally. Edit `configuration.nix`:
```nix
environment.systemPackages = with pkgs; [
  your-system-package
];
```

After adding packages, rebuild with:
```bash
sudo nixos-rebuild switch --flake .#default
```

### Working with Containers

**Plex container management:**
```bash
# Check container status
sudo systemctl status container@plex

# Restart container
sudo systemctl restart container@plex

# View container logs
sudo journalctl -u container@plex -f

# Enter container shell
sudo nixos-container root-login plex
```

Container configuration is stored in `/home/joemitz/containers/plex/config` and persists across reboots (ephemeral container).

## Development Notes

- The system uses flakes, so `nix-command` and `flakes` experimental features are enabled
- When modifying configurations, test with `nixos-rebuild test` before committing to `switch`
- The configuration targets a privileged LXC container, so avoid adding features that require full VM capabilities
- Use home-manager for user packages following the module pattern in `home.nix`
- The Plex container uses host networking, so port conflicts with host services are possible
