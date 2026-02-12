{ config, modulesPath, pkgs, lib, ... }:
{
  imports = [
    ./proxmox.nix
    ./containers/plex.nix
  ];

  # Nix configuration
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable nix-ld for running unpatched dynamic binaries
  programs.nix-ld.enable = true;

  # System configuration
  networking.hostName = "nixos-server";

  # Mount TrueNAS Plex share via NFS (read-only)
  # nofail: Continue boot even if mount fails
  fileSystems."/mnt/truenas/plex" = {
    device = "192.168.0.55:/mnt/main-pool/plex";
    fsType = "nfs";
    options = [
      "ro"
      "nofail"
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = true;
        PermitEmptyPasswords = "no";
    };
  };
  # Cache DNS lookups to improve performance
  services.resolved = {
    extraConfig = ''
      Cache=true
      CacheFromLocalhost=true
    '';
  };

  # Enable Tailscale VPN
  services.tailscale.enable = true;

  # Open firewall ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 32400 ];  # Plex
  };

  users.users.joemitz = {
    isNormalUser = true;
    description = "joemitz";
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
