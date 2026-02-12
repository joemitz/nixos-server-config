{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    claude-code.url = "github:sadjow/claude-code-nix";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, claude-code, ... }: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.root = {
            home.stateVersion = "25.11";
            home.packages = [
              claude-code.packages.x86_64-linux.default
            ];
          };
          home-manager.users.joemitz = {
            home.stateVersion = "25.11";
            home.packages = [
              claude-code.packages.x86_64-linux.default
            ];
          };
        }
      ];
    };
  };
}
