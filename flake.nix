{
  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    deploy.url = "github:serokell/deploy-rs";
    rss-server.url = "github:JJ-Atkinson/personal-rss-reserver";
  };


  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, flake-utils,
              sops-nix, deploy, rss-server }@inputs: 

    let
      system = "x86_64-linux";

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

      baseModules = [
        sops-nix.nixosModules.sops
      ];

      vmHostModules = [
        "${nixpkgs}/nixos/modules/virtualisation/lxc-container.nix"
        ./hardware/proxmox-lxc.nix
        ./hardware/common.nix
      ];

      jarrettModules = [
        ./users/common.nix
        ./users/jarrett.nix
      ];

    in {
      nixosConfigurations = {
        garage-ct = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = baseModules ++ jarrettModules ++ vmHostModules ++ [./systems/garage.nix];
        };

        rss-server = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = baseModules ++ jarrettModules ++ vmHostModules ++
           [./systems/rss-server.nix];
        };
      };

      deploy = import ./deploy.nix (inputs // {
        inherit inputs;
      });
    };
}
