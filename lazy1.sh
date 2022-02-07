#!/bin/bash

systemctl stop gdm3
apt -y purge gdm3 ubuntu-desktop ifupdown
rm -rf /etc/network/interfaces.d
apt -y install xubuntu-desktop
apt -y autoremove

# This is to remediate OMIgod.
wget https://packages.microsoft.com/keys/microsoft.asc
apt-key add microsoft.asc
apt-add-repository https://packages.microsoft.com/ubuntu/18.04/prod
apt update
# If you don't do the next step, password changing etc stop working.
apt-mark hold linux-azure linux-cloud-tools-azure linux-headers-azure linux-image-azure linux-tools-azure ubuntu-advantage-tools
apt -y full-upgrade

apt-add-repository -y ppa:x2go/stable
apt -y install x2goserver
systemctl enable x2goserver

systemctl stop lightdm
apt -y install libegl1-mesa
wget https://sourceforge.net/projects/virtualgl/files/3.0/virtualgl_3.0_amd64.deb/download
mv download virtualgl_3.0_amd64.deb
dpkg -i virtualgl_3.0_amd64.deb
nvidia-xconfig --query-gpu-info
echo ""
echo "==================================================================================="
echo "Note the PCI Bus ID and carefully edit PCIBUSID at the top of lazy2.sh to match it."
echo "==================================================================================="
echo ""
read -p "Press ENTER to return to the command line."
