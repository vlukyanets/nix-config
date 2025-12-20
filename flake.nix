{
  description = "My NixOS config with flakes + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    mkHost = { host, system ? "x86_64-linux", username, extraModules ? [ ] }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # ./modules/nixos/common.nix
          ./hosts/${host}/configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-bak";
            home-manager.users.${username} = import ./home/${host}/${username}.nix;
          }
        ] ++ extraModules;
      };
  in {
    nixosConfigurations = {
      echo-server = mkHost { host="echo-server"; username="valentinl"; };
    };
  };
}
