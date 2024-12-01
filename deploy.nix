{ self
, deploy
, ...
}:
let
  mkNode = server: ip: fast: {
    hostname = "${ip}";
    fastConnection = fast;
    profiles.system.path =
      deploy.lib.x86_64-linux.activate.nixos
        self.nixosConfigurations."${server}";
  };
in
{
  user = "root";
  sshUser = "root";
  nodes = {
    garage-ct = mkNode "garage-ct" "192.168.50.35" true;
    rss-server = mkNode "rss-server" "192.168.50.193" true;
    immich = mkNode "immich" "192.168.50.111" true;
  };
}