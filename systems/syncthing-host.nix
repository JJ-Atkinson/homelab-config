{ pkgs-unstable, inputs, lib, pkgs, config, ... }:

{

  networking.hostName = "syncthing-host";
  environment.systemPackages = [ ];

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "jarrett";

    dataDir = "/home/jarrett/syncthing-datadir";

  };

  systemd.services.syncthing.environment.STNODEFAULTFOLDER =
    "true"; # Don't create default ~/Sync folder

}
