#!/bin/bash
curl -o /usr/bin/setup https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/startup.sh
chmod +x /usr/bin/startup
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
curl -sSL  https://repo.45drives.com/setup -o setup-repo.sh
bash setup-repo.sh
apt update
apt install -y cockpit-navigator
