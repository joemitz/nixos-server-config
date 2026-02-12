{ config, modulesPath, pkgs, lib, ... }:
{
  imports = [ ./proxmox.nix ];

  # Nix configuration
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System configuration
  networking.hostName = "nixos-server";

  # System packages
  environment.systemPackages = with pkgs; [
    git
  ];
  
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

  users.users.joemitz = {
    isNormalUser = true;
    description = "joemitz";
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
