{ pkgs-unstable, inputs, lib, pkgs, config, ... }:

{

  networking.hostName = "immich";
  services.immich = {
    enable = true;
    package = pkgs-unstable.immich;
    # environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";

    # managed in this file, checkout
    # user = "immich-user";
    # group = "immich-group";

    host = "0.0.0.0";
    openFirewall = true;  
    port = 2283;
  };


  environment.systemPackages = [ ];

  users.users.immich-user = {
    isNormalUser = true;
    uid = 1003;
    group = "immich-group";
  };

  users.groups.immich-group.gid = 1003;
}
