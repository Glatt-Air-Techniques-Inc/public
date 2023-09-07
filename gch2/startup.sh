#!/bin/bash

gch2_pub_git='https://raw.githubusercontent.com/Glatt-Air-Techniques-Inc/public/master/gch2/'
tailscale_repo='https://pkgs.tailscale.com/stable/ubuntu/'

SPLocation="https://organization.glatt.com/ptpA/sw/gat/Documents/Deployment/"

LocalServer="192.168.101.150"
LocalPath="ptp"
DeployPath="PAD-Development/GIT"
DeployRepo="Deployment"
RepoPath="PAD-Development/deb_repo"
BLOC="/usr/share"

gui_installed=0


# Define functions


# Get user SMB credentials
get_credentials () {
    if [ "$username" == "" ]; then
    if [[ $graphical == "true" ]]; 
    then
    username=$(zenity --entry --text="Enter your Glatt username (email address)");
    password=$(zenity --password --text="Enter your password" );
    else
        echo "************************************************"
        echo "******Please enter your Glatt credentials.******"
        echo "************************************************"
        echo
        echo
        read -p "Enter your username (email address): " username
        read -s -p "Enter your password: " password
        echo
        fi
    fi
}


# NOT USED
install_gui_remote () {
    # Package installs
    sudo apt install -y ubuntu-desktop-minimal gnome-initial-setup- remote-viewer-
    sudo apt install -y remmina nautilus-admin xrdp gnome-tweaks p7zip virt-manager
    # Teamviewer
    curl -L -o /tmp/teamviewer-host_amd64.deb \
    https://download.teamviewer.com/download/linux/teamviewer-host_amd64.deb
    sudo apt install -y /tmp/teamviewer-host_amd64.deb
    rm -f /tmp/teamviewer-host_amd64.deb
    read -rp $'Enter a Teamviewer password:\n' tvpass
    sudo teamviewer passwd $tvpass
    reboot
}


# Get Glatt-Tools and install Deployment folder from remote network
get_deploy_remote () {
    read -p "Please insert a USB flash drive containing the Glatt-Tools.deb file" resp
    sudo mkdir /media/usb
    mount /dev/sdc1 /media/usb

    sudo cp /media/usb/glatt-tools*.deb /tmp/glatt-tools.deb
    sudo apt install -y /tmp/glatt-tools.deb
    sudo rm /tmp/glatt-tools.deb
    sudo /usr/share/Deployment/scripts/smbsetup.sh
    sudo umount /media/usb

        read -p "Do you want to install the full GUI(y/N)" fullGUI
        fullGUI=${fullGUI:-n}

        if [[ "$fullGUI" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
            #install the GUI
            sudo ${BLOC}/${DeployRepo}/scripts/install-gui.sh --in-script
            gui_installed=1
        fi
}


# Get Glatt-Tools and install Deployment folder from local GAT network
get_deploy_local() {
    get_credentials
    mount_pad

    sudo cp /tmp/pad/${RepoPath}/glatt-tools*.deb /tmp/glatt-tools.deb
    sudo cp /tmp/pad/${RepoPath}/glatt-backup*.deb /tmp/glatt-backup.deb
    sudo apt install -y /tmp/glatt-tools.deb
    sudo rm /tmp/glatt-tools.deb
    sudo chmod +x ${BLOC}/${DeployRepo}/scripts/*.sh
    sudo ${BLOC}/${DeployRepo}/scripts/smbsetup.sh

    unmount_pad

    read -p "Do you want to install the full GUI(y/N)" fullGUI
    fullGUI=${fullGUI:-n}

    if [[ "$fullGUI" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        #install the GUI
        sudo ${BLOC}/${DeployRepo}/scripts/install-gui.sh --in-script
        gui_installed=1
    fi
}


# Unmount PAD Samba share
unmount_pad() {
    umount /tmp/pad
}


# Mount PAD Samba share
mount_pad () {
    read -p "Enter shared folder name: (//${LocalServer}/${LocalPath})" padpath
    padpath=${padpath:-//${LocalServer}/${LocalPath}}
    mkdir /tmp/pad
    umount /tmp/pad

    mountstring="username=${username},password=${password} ${padpath} /tmp/pad"
    sudo mount -t cifs -o $mountstring
}


# Confirm Linux environment. Sets OS and VER global vars
checkEnvironment () {
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/SuSe-release ]; then
        # Older SuSE/etc.
        ...
    elif [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        ...
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s)
        VER=$(uname -r)
    fi

    echo $OS
    echo $VER
}


# Installs for Ubuntu 18.04
deploy_1804 () {
    ##intall additional packages
    apt install -y nfs-common sshpass openssh-server ovmf cifs-utils
    apt install -y -t bionic-backports cockpit cockpit-bridge cockpit-dashboard \
    cockpit-docker cockpit-machines cockpit-networkmanager cockpit-storaged \
    cockpit-system cockpit-ws libguestfs-tools p7zip-full

    ##install TailScale
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/bionic.gpg | sudo apt-key add -
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/bionic.list | sudo tee /etc/apt/sources.list.d/tailscale.list
    apt update
    apt install -y tailscale
    apt install -y qrencode

    #update users
    adduser glatt libvirt 
    adduser glatt libvirt-qemu
    adduser glatt kvm

    #create default storage pool
    virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"
    virsh pool-start default
    virsh pool-autostart default
    }


# Installs for Ubuntu 20.04
deploy_2004 () {
    sudo rm /etc/netplan/00-installer-config.yaml
    sudo curl -o /etc/netplan/00-installer-config.yaml "${gch2_pub_git}00-installer-config.yaml"

    # Install additional packages
    apt update
    apt install -y nfs-common sshpass openssh-server ovmf cifs-utils
    apt install -y cockpit cockpit-bridge cockpit-dashboard cockpit-machines \
    cockpit-networkmanager cockpit-storaged cockpit-system cockpit-ws \
    libguestfs-tools p7zip-full

    # Add docker
    sudo apt install -y docker.io
    sudo usermod -aG docker glatt
    # Newgrp docker
    # ?
    wget 'https://launchpad.net/ubuntu/+source/cockpit/215-1~ubuntu19.10.1'\
    '/+build/18889196/+files/cockpit-docker_215-1~ubuntu19.10.1_all.deb'
    apt install -y ./cockpit-docker_215-1~ubuntu19.10.1_all.deb
    rm -f ./cockpit-docker_215-1~ubuntu19.10.1_all.deb

    # Install TailScale
    curl -fsSL "${tailscale_repo}focal.gpg" | sudo apt-key add -
    curl -fsSL "${tailscale_repo}focal.list" | sudo tee /etc/apt/sources.list.d/tailscale.list
    apt update
    apt install -y tailscale
    apt install -y qrencode

    # Update users
    adduser glatt libvirt 
    adduser glatt libvirt-qemu
    adduser glatt kvm

    # Create default storage pool
    virsh pool-define-as default dir - - - - "/var/lib/libvirt/images"
    virsh pool-start default
    virsh pool-autostart default
}


# Installs for Ubuntu 22.04
deploy_2204 () {
    # Install additional packages
    echo "Setting up 22.04...."
}


# Update hostname (manually)
update_hostname() {
    read -p "Change hostname now?(y/N)" change_hostname
    change_hostname=${change_hostname:-n}
    if  [[ "$change_hostname" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
        while [[ $new_hostname == '' ]] # While string is different or empty...
        do
            echo 'Please enter a valid hostname.'
            read -p "hostname: " new_hostname # Ask the user to enter a string
        done 

        sudo hostnamectl set-hostname $new_hostname    # set hostname
        echo 127.0.0.1 localhost $(hostname) | sudo tee -a /etc/hosts   # add to hosts
        echo -n '(NEW)'; hostnamectl | grep "Static hostname:"
        echo 'Restart for changes to take effect!'
    fi
}


# -- MAIN


# check for root privilege
if [ "$(id -u)" != "0" ]; then
   echo "SETUP FAILED! This script must be run as root."
   echo "Please prepend 'sudo' to command, like below:"
   echo "sudo ${0} ${@}"
   exit 126   # exit code: permissions issue
fi

checkEnvironment

case $VER in
  20.04)
    deploy_2004
    ;;

  22.04)
    deploy_2204
    ;;

  *)
    deploy_1804
    ;;
esac

# Update path
sudo -u glatt echo "export PATH=/usr/share/Deployment/scripts/:$PATH" | tee -a  .bashrc > /dev/null

# See if user is inside GAT
if ping -c 1 ${LocalServer} &> /dev/null
then
  	get_deploy_local
else
  	read -p "can't reach the file server. Are you connected to the Glatt network?(Y/n)" locGAT
	locGat=${locGAT:-y}

	if  [[ "$locGAT" =~ ^([yY][eE][sS]|[yY])$ ]]
    then
		get_deploy_local
	else
        read -p "Are you a Glatt customer?(Y/n)" cust
        cust=${cust:-y}
		if  [[ "$cust" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
			get_deploy_remote
		else
			read -p "Do you want to start tailscale for VPN access?(y/N)" tscale
			tscale=${tscale:-n}
			if  [[ "$tscale" =~ ^([yY][eE][sS]|[yY])$ ]]
            then
				sudo tailscale up --qr --accept-routes --advertise-tags=tag:customer,tag:hypervisor
				get_deploy_local
			else
				get_deploy_remote
			fi
		fi
	fi
fi

# update hostname if user chooses to
update_hostname

sudo touch /etc/cloud/cloud-init.disabled   # disable cloud-init

# Remove setup warning (that was created in finalize.sh)
sudo sed -i 's/setup_warning=1/setup_warning=0/g' '/home/glatt/.profile'

if $gui_installed -eq 1; then
    reboot
fi