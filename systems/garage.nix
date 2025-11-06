{ pkgs-unstable, lib, pkgs, config, ... }:

let
  logLevel = "info";
  pkg = pkgs-unstable.garage_2;
  cleartextConfig = ./garage/garage.toml;
  defaultSopsFile = ../secrets/garage.yaml;

  rpcSecretFile = config.sops.secrets.rpc_secret.path;
  adminTokenFile = config.sops.secrets.admin_token.path;
  metricsTokenFile = config.sops.secrets.metrics_token.path;

  garageOverlay = pkgs.writeShellApplication {
    name = "garage";
    runtimeInputs = [ pkg ];
    text = ''
      set -euo pipefail
      export RUST_LOG="garage=${logLevel}"
      export GARAGE_RPC_SECRET_FILE="${rpcSecretFile}"
      export GARAGE_ADMIN_TOKEN_FILE="${adminTokenFile}"
      export GARAGE_METRICS_TOKEN_FILE="${metricsTokenFile}"
      export GARAGE_CONFIG_FILE="/etc/garage.toml"
      exec garage "$@"
    '';
  };

in {
  sops.defaultSopsFile = defaultSopsFile;
  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";
  sops.secrets = {
    rpc_secret = { };
    admin_token = { };
    metrics_token = { };
  };

  networking.firewall.allowedTCPPorts =
    [ # Must be updated when the toml file is updated
      3900
      3901
      3902
      3903
      4317
    ];

  networking.hostName = "garage-ct";

  environment.etc."garage.toml".source = cleartextConfig;

  environment.systemPackages = [ garageOverlay ];

  systemd.services.garage = {
    description = "Garage Object Storage (S3 compatible)";
    after = [ "network.target" "network-online.target" ];
    wants = [ "network.target" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [
      (builtins.hashFile "sha256" defaultSopsFile)
      (builtins.hashFile "sha256" cleartextConfig)
    ];
    serviceConfig = {
      ExecStart = lib.mkForce "${pkg}/bin/garage server";

      StateDirectory = "garage";
      # DynamicUser = true;
      # ProtectHome = true;
      # NoNewPrivileges = true;
    };
    environment = {
      RUST_LOG = "garage=${logLevel}";
      GARAGE_RPC_SECRET_FILE = config.sops.secrets.rpc_secret.path;
      GARAGE_ADMIN_TOKEN_FILE = config.sops.secrets.admin_token.path;
      GARAGE_METRICS_TOKEN_FILE = config.sops.secrets.metrics_token.path;
    };
  };
}
