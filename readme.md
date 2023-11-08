# Creating a new VM:

Make a machine based on the NIX CT template in proxmox. Set hostname, password, and public key. Be sure to use DHCP, not static DNS. 

At the router, configure DCHP to give the machine a static IP.

Find the machine IP in the router. SSH root@ip. 


```
nix-channel --update
cd /etc/nixos
nix-shell -p git
git clone https://github.com/JJ-Atkinson/homelab-config.git .
nixos-rebuild switch
```

### To generate secret keys on the remote machine:

```bash
nix-shell -p age
mkdir -p ~/.config/sops/age # Create the location sops will query for the key file
age-keygen -o ~/.config/sops/age/keys.txt
cp ~/.config/sops/age/keys.txt /var/lib/sops-nix/keys.txt

# Copy the public key to .sops.yaml and re-gen the appropriate secret-containing files
```