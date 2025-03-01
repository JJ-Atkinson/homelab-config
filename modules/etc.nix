{
  # Set a maximum journalctl log size for the system. Motivated by the fact that I found >3.5gb of logs on 
  # the rss server machine
  services.journald.extraConfig = "SystemMaxUse=1000M";
}
