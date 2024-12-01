{ pkgs-unstable, inputs, lib, pkgs, config, ... }:

{

  services.immich = {
    enable = true;
    # environment.IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
  };


  networking.firewall.allowedTCPPorts = [

  ];

  environment.systemPackages = [  ]; 

}
