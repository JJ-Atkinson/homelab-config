{ pkgs-unstable, lib, pkgs, config, ... }:

let 
  cleartextConfig = ./rss-server/rss-server-config.edn;
  defaultSopsFile = ../secrets/rss-server.yaml;
in
{
  sops.defaultSopsFile = defaultSopsFile;
  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";
  sops.secrets = {
     lotus_eaters_username = {};
     lotus_eaters_password = {};
     s3_secret_access_key = {};
     s3_public_s3_prefix = {};
  };
  sops.templates.rss_server.content = ''
   {:lotus-eaters/username "${config.sops.placeholder.lotus_eaters_username}"
    :lotus-eaters/password "${config.sops.placeholder.lotus_eaters_password}"
    :s3/secret-access-key "${config.sops.placeholder.s3_secret_access_key}"
    :s3/public-s3-prefix "${config.sops.placeholder.s3_public_s3_prefix}"}
    '';

  networking.firewall.allowedTCPPorts = [
    3000
  ];

  environment.etc."rss-server-config.edn".source = cleartextConfig;
  environment.etc."rss-server-secrets.edn".source = config.sops.templates.rss_server.path;

  networking.hostName = "rss-server";

}
