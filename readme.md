To generate secret keys on the remote machine:

```bash
nix-shell -p age
mkdir -p ~/.config/sops/age # Create the location sops will query for the key file
age-keygen -o ~/.config/sops/age/keys.txt

# /var/lib/sops-nix/keys.txt

# Copy the public key to .sops.yaml and re-gen the appropriate files
```