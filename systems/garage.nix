{ pkgs-unstable, lib, pkgs, config, ... }:

let
  logLevel = "info";
  cleartextConfig = ./garage/garage.toml;
  pkg = pkgs.garage_0_9;
  defaultSopsFile = ../secrets/garage.yaml;
in {
  sops.defaultSopsFile = defaultSopsFile;
  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";
  sops.secrets = {
    rpc_secret = { };
    admin_token = { };
    metrics_token = { };
  };
  sops.templates.garage_toml.content = ''
    # Begin Secrets
    rpc_secret = "${config.sops.placeholder.rpc_secret}"
    admin.admin_token = "${config.sops.placeholder.admin_token}"
    admin.metrics_token = "${config.sops.placeholder.metrics_token}"
    # End Secrets

    ${builtins.readFile cleartextConfig}
  '';

  networking.firewall.allowedTCPPorts =
    [ # Must be updated when the toml file is updated
      3900
      3901
      3902
      3903
      4317
    ];

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
    environment = { RUST_LOG = "garage=${logLevel}"; };
  };
}
