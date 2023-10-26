{ pkgs-unstable, lib, pkgs, config, ... }:

let 
  logLevel = "info";
  cleartextConfig = ./garage/garage.toml;
  pkg = pkgs-unstable.garage_0_9_0;
in
{
  sops.defaultSopsFile = ../secrets/garage.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";
  sops.secrets = {
     rpc_secret = {};
  };
  sops.templates.garage_toml.content = ''
    ${builtins.readFile cleartextConfig}

    # Begin Secrets
    rpc_secret = "${config.sops.placeholder.rpc_secret}"
  '';


  networking.hostName = "garage-ct";

  environment.etc."garage.toml" = {
    source = lib.mkForce config.sops.templates.garage_toml.path;
  };

  environment.systemPackages = [ pkg ]; 

  systemd.services.garage = {
    description = "Garage Object Storage (S3 compatible)";
    after = [ "network.target" "network-online.target" ];
    wants = [ "network.target" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ config.sops.templates.garage_toml.path ];
    serviceConfig = {
      ExecStart = lib.mkForce "${pkg}/bin/garage server";

      StateDirectory = "garage";
      # DynamicUser = true;
      # ProtectHome = true;
      # NoNewPrivileges = true;
    };
    environment = {
      RUST_LOG = "garage=${logLevel}";
    };
  };
}