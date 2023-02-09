#!/bin/bash
curl -o /usr/bin/setup https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/startup.sh
chmod +x /usr/bin/setup
curl -o /usr/bin/gch https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/gch.sh
chmod +x /usr/bin/gch
curl -o /usr/bin/get-vagrant https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/get-vagrant.sh
chmod +x /usr/bin/get-vagrant
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
wget https://github.com/Glatt-Air-Techniques-Inc/public/raw/master/navigator_1_amd64.deb
apt install -y cockpit-navigator.deb
bash setup-repo.sh
sudo apt update
sudo apt install -y tailscale
sudo apt install -y ./navigator_1_amd64.deb
sudo virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"
sudo virsh pool-start default
sudo virsh pool-autostart default
#update users
sudo adduser glatt libvirt 
sudo adduser glatt libvirt-qemu
sudo adduser glatt kvm