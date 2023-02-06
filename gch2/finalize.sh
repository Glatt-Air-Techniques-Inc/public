#!/bin/bash
virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"
virsh pool-start default
virsh pool-autostart default
curl -o /usr/bin/setup https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/startup.sh
chmod +x /usr/bin/startup
curl -o /usr/bin/gch https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/gch.sh
chmod +x /usr/bin/gch
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
curl -o cockpit-navigator.deb https://github.com/45Drives/cockpit-navigator/releases/download/v0.5.10/cockpit-navigator_0.5.10-1focal_all.deb
apt install -y cockpit-navigator.deb
bash setup-repo.sh
apt update
apt install -y tailscale
apt install -y cockpit-machines

