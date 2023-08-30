#!/bin/bash
curl -o /usr/bin/setup https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/startup.sh
chmod +x /usr/bin/setup
curl -o /usr/bin/gch https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/gch.sh
chmod +x /usr/bin/gch
curl -o /usr/bin/get-vagrant https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/get-vagrant.sh
chmod +x /usr/bin/get-vagrant
curl -o /usr/bin/start https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/start
chmod +x /usr/bin/start
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list
wget https://github.com/Glatt-Air-Techniques-Inc/public/raw/master/navigator_1_amd64.deb
sudo apt update
sudo apt install -y genisoimage
sudo apt install -y tailscale
sudo apt install -y ./navigator_1_amd64.deb
sudo virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"
sudo virsh pool-start default
sudo virsh pool-autostart default
#update users
sudo adduser glatt libvirt 
sudo adduser glatt libvirt-qemu
sudo adduser glatt kvm

echo 'Changing netplan to NetowrkManager on all interfaces'
# backup existing yaml file
cd /etc/netplan
cp 01-netcfg.yaml 01-netcfg.yaml.BAK

# re-write the yaml file
cat << EOF > /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: NetworkManager
EOF

# setup netplan for NM
netplan generate
netplan apply
# make sure NM is running
systemctl enable NetworkManager.service
systemctl restart NetworkManager.service

echo 'Done!'
