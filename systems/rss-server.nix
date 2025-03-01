{ pkgs-unstable, inputs, lib, pkgs, config, ... }:

let 
  cleartextConfig = ./rss-server/rss-server-config.edn;
  defaultSopsFile = ../secrets/rss-server.yaml;
  pkg = inputs.rss-server.packages.x86_64-linux.default;
in
{
  sops.defaultSopsFile = defaultSopsFile;
  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";
  sops.secrets = {
     lotus_eaters_username = {};
     lotus_eaters_password = {};
     s3_secret_access_key = {};
     s3_public_s3_prefix = {};
     feed_secret_path_segment = {};
     feed_public_feed_address = {};
     auth_jwt_secret = {};
  };
  sops.templates.rss_server.content = ''
   {:lotus-eaters/username "${config.sops.placeholder.lotus_eaters_username}"
    :lotus-eaters/password "${config.sops.placeholder.lotus_eaters_password}"
    :s3/secret-access-key "${config.sops.placeholder.s3_secret_access_key}"
    :s3/public-s3-prefix "${config.sops.placeholder.s3_public_s3_prefix}"
    :feed/secret-path-segment "${config.sops.placeholder.feed_secret_path_segment}"
    :feed/public-feed-address "${config.sops.placeholder.feed_public_feed_address}"
    :auth/jwt-secret "${config.sops.placeholder.auth_jwt_secret}"
   }
    '';

  networking.firewall.allowedTCPPorts = [
    3001   # http-kit
    8001   # nrepl
  ];

  environment.etc."rss-feed-config.edn".source = cleartextConfig;
  environment.etc."rss-feed-secrets.edn".source = config.sops.templates.rss_server.path;

  networking.hostName = "rss-server";

  environment.systemPackages = [ pkg ]; 

  systemd.services.rss-server = {
    description = "Personal rss re-server";
    after = [ "network.target" "network-online.target" ];
    wants = [ "network.target" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ (builtins.hashFile "sha256" defaultSopsFile)
                        (builtins.hashFile "sha256" cleartextConfig) ];
    serviceConfig = {
      ExecStart = lib.mkForce "${pkg}/bin/launch-rss-server";

      StateDirectory = "rss-server";
      # DynamicUser = true;
      # ProtectHome = true;
      # NoNewPrivileges = true;
    };
  };
}
