{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.nixos-generators
    pkgs.sops
    pkgs.ssh-to-pgp
    pkgs.age
    pkgs.deploy-rs
  ];
}
