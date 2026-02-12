{ config, modulesPath, lib, ... }:

{
  # Import Proxmox LXC module
  imports = [ (modulesPath + "/virtualisation/proxmox-lxc.nix") ];

  # Proxmox LXC configuration
  proxmoxLXC = {
    manageNetwork = false;    # Let Proxmox handle networking
    manageHostName = true;    # NixOS manages hostname
    privileged = true;        # Run as privileged container
  };

  # Disable sandbox for LXC container compatibility
  # LXC containers often lack kernel features needed for proper sandboxing
  nix.settings.sandbox = false;

  # Disable fstrim - let the Proxmox host handle it
  services.fstrim.enable = false;
}
