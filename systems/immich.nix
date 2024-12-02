{ pkgs-unstable, inputs, lib, pkgs, config, ... }:

{

  services.immich = {
    # enable = true;
    # environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
    
    # managed in this file
    user = "immich-user"; 
    group = "immich-group";

    # database.user = "immich-user";
  };

  services.postgresql.dataDir = "/mnt/immich-bulk-store/postgres";


  networking.firewall.allowedTCPPorts = [
  ];

  environment.systemPackages = [ ]; 


  users.users.immich-user = {
    isNormalUser = true;
    uid = 1003;
    group = "immich-group"; 
  };

  users.groups.immich-group.gid = 1003;
}
