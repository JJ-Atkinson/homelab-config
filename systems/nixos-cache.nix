{ pkgs-unstable, inputs, lib, pkgs, config, ... }:

{
  imports = [
    inputs.nixos-passthru-cache.nixosModules.default
  ];

  networking.hostName = "nixos-cache";

  # Configure the passthrough cache for LAN use
  services.nixos-passthru-cache = {
    enable = true;
    lanMode = true;  # Enable mDNS auto-discovery, no SSL, allow non-local stats access

    # Cache configuration
    cacheSize = "200G";     # Default cache size
    inactivity = "90d";      # Evict unused items after 30 days

    # Upstream cache
    upstream = "https://cache.nixos.org";
  };

  # Firewall is already handled by nixos-passthru-cache module
  # Opens ports 80 and 443 automatically
}
