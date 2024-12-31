{
  system.stateVersion = "24.11";

  services.openssh.enable = true;
  services.openssh.listenAddresses = [{
    addr = "0.0.0.0";
    port = 22;
  }];

  networking.firewall = {
    # let you SSH in over the public internet
    allowedTCPPorts = [ 22 ];
  };
}
