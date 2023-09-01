#!/bin/bash
gch2_pub_git='https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/'
tailscale_repo='https://pkgs.tailscale.com/stable/ubuntu/'

# GCH2 public repo shell gets
curl -o /usr/bin/setup "${gch2_pub_git}startup.sh"
chmod +x /usr/bin/setup
curl -o /usr/bin/gch "${gch2_pub_git}gch.sh"
chmod +x /usr/bin/gch
curl -o /usr/bin/get-vagrant "${gch2_pub_git}get-vagrant.sh"
chmod +x /usr/bin/get-vagrant
curl -o /usr/bin/start "${gch2_pub_git}start"
chmod +x /usr/bin/start

# Tailscale and Cockpit
curl -fsSL "${tailscale_repo}jammy.noarmor.gpg" | \
 sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL "${tailscale_repo}jammy.tailscale-keyring.list" | \
 sudo tee /etc/apt/sources.list.d/tailscale.list
wget "${gch2_pub_git}"pkg/navigator_1_amd64.deb
sudo apt update
sudo apt install -y genisoimage
sudo apt install -y tailscale
sudo apt install -y ./navigator_1_amd64.deb

# Virsh
sudo virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"
sudo virsh pool-start default
sudo virsh pool-autostart default

# Udate users
sudo adduser glatt libvirt 
sudo adduser glatt libvirt-qemu
sudo adduser glatt kvm

# Networking
# backup existing yaml file
echo 'Changing netplan to NetworkManager on all interfaces'
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

# Remove message-of-the-day advertisements
sudo sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news

# Add 'Please Run Setup' warning
curl "${gch2_pub_git}profile" | sudo tee -a '/home/glatt/.profile'

echo 'finalize.sh Done!'
