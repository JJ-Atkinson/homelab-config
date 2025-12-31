{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    deploy.url = "github:serokell/deploy-rs";
    rss-server.url = "github:JJ-Atkinson/personal-rss-reserver";
    nixos-passthru-cache.url = "github:numtide/nixos-passthru-cache";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, flake-utils
    , sops-nix, deploy, rss-server, nixos-passthru-cache }@inputs:

    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      specialArgs = {
        nixpkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };

        inherit nixos-hardware inputs;
      };

      baseModules = [ sops-nix.nixosModules.sops ];

      vmHostModules = [
        "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        ./hardware/proxmox-lxc.nix
        ./hardware/common.nix
        ./modules/etc.nix
      ];

      tailscaleModules = [
                ./modules/tailscale.nix
      ];

      jarrettModules = [ ./users/common.nix ./users/jarrett.nix ];

    in {
      nixosConfigurations = {
        garage-ct = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = baseModules ++ jarrettModules ++ vmHostModules ++ tailscaleModules
            ++ [ ./systems/garage.nix ];
        };

        rss-server = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = baseModules ++ jarrettModules ++ vmHostModules ++ tailscaleModules
            ++ [ ./systems/rss-server.nix ];
        };

        immich = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = baseModules ++ jarrettModules ++ vmHostModules ++ tailscaleModules
            ++ [ ./systems/immich.nix ];
        };

        syncthing-host = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = baseModules ++ jarrettModules ++ vmHostModules ++ tailscaleModules
            ++ [ ./systems/syncthing-host.nix ];
        };

        nixos-cache = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = baseModules ++ jarrettModules ++ vmHostModules
            ++ [ ./systems/nixos-cache.nix ];
        };
      };

      deploy = import ./deploy.nix (inputs // { inherit inputs; });

      devShell."${system}" = pkgs.mkShell {
        buildInputs = [
          pkgs.nixos-generators
          pkgs.sops
          pkgs.ssh-to-pgp
          pkgs.age
          pkgs.deploy-rs
        ];
      };
    };
}
