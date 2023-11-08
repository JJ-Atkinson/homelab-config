# Creating a new VM:

Make a machine based on the NIX CT template in proxmox. Set hostname, password, and public key. Be sure to use DHCP, not static DNS. 

Find the machine IP in the router. SSH root@ip. 


```

```

### To generate secret keys on the remote machine:

```bash
nix-shell -p age
mkdir -p ~/.config/sops/age # Create the location sops will query for the key file
age-keygen -o ~/.config/sops/age/keys.txt
cp ~/.config/sops/age/keys.txt /var/lib/sops-nix/keys.txt

# Copy the public key to .sops.yaml and re-gen the appropriate secret-containing files
```