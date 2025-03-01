# Creating a new VM:

Make a machine based on the NIX CT template in proxmox. Set hostname, password, and public key. Be sure to use DHCP, not static DNS. 

At the router, configure DCHP to give the machine a static IP.

> In proxmox, set tty to /dev/console so you can see boot logs. See `Options` on the VM config.


```
# SSH root@ip. 
nix-channel --update
cd /etc/nixos
nix-shell -p git

# shell change!!

git clone https://github.com/JJ-Atkinson/homelab-config.git .
nixos-rebuild boot
# As a fallback, if hostname is incorrect, you can use

nixos-rebuild switch --flake .#nixosvmr

```

Reboot the vm. To speed the process, you can set the config for the machine to just `blank` reducing the number of things pulled from the nix cache. 

### Tailscale


https://tailscale.com/kb/1130/lxc-unprivileged


You need to add the following to the container conf in `/etc/pve/lxc/ct-id.conf` and reboot

```
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file
```

Edit `deploy.nix` to contain the new machine name & ip. Test deploy with `deploy .#machine-hostname` from this directory.

### To generate secret keys on the remote machine:

```bash
nix-shell -p age

# shell change!!

mkdir -p ~/.config/sops/age # Create the location sops will query for the key file
age-keygen -o ~/.config/sops/age/keys.txt
mkdir -p /var/lib/sops-nix
cp ~/.config/sops/age/keys.txt /var/lib/sops-nix/keys.txt

# Copy the public key to .sops.yaml and re-gen the appropriate secret-containing files
```


https://nixos.wiki/wiki/Flakes#Using_nix_flakes_with_NixOS