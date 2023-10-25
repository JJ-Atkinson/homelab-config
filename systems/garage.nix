{
  networking.hostName = "garage-ct";
  services.garage = {
    enable = true;
    settings = {
      replication_mode = "none";
      metadata_dir = "/var/lib/garage/metadata";
      data_dir = "/var/lib/garage/data";
    };
  };
}