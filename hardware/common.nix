{
  system.stateVersion = "23.05";

  services.openssh.enable = true;
  services.openssh.listenAddresses = [
    {
      addr = "0.0.0.0";
      port = 22;
    }
  ];
}