{
  description = "deploy-intent: deployment intent orchestrator and NixOS agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.deploy-intent = pkgs.rustPlatform.buildRustPackage {
          pname = "deploy-intent";
          version = "0.2.0";
          src = ./.;
          cargoLock.lockFile = ./Cargo.lock;
        };

        packages.default = self.packages.${system}.deploy-intent;

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.deploy-intent}/bin/deploy-intent";
        };
      }) // {
        nixosModules.deploy-intent-agent = import ./nix/modules/deploy-intent-agent.nix;
        nixosModules.ota-vm = import ./nix/hosts/ota-vm.nix;

        nixosConfigurations.ota-vm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit self; };
          modules = [
            self.nixosModules.deploy-intent-agent
            self.nixosModules.ota-vm
          ];
        };
      };
}
