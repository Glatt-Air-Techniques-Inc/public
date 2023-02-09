#!/bin/bash

#update users
sudo adduser glatt libvirt 
sudo adduser glatt libvirt-qemu
sudo adduser glatt kvm

#install vagrant
sudo apt -y install vagrant
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate
vagrant plugin install winrm-elevated
