{
  inputs = { 
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

  };


  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware }@inputs: 

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
        
        inherit nixos-hardware;
      };

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
          modules = jarrettModules ++ vmHostModules ++ [./systems/garage.nix];
        };
      };
    };
}
