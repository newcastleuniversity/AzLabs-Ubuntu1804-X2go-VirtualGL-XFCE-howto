#!/bin/bash

PCIBUSID='PCI:0@1:0:0'

nvidia-xconfig -a --allow-empty-initial-configuration --virtual=1920x1080 --busid $PCIBUSID
rmmod nvidia_drm nvidia_modeset nvidia
chmod u+s /usr/lib/libvglfaker.so
chmod u+s /usr/lib/libdlfaker.so
echo ""
echo "======================================================================"
echo "For the next set of questions, answer as follows:"
echo "  * 1) Configure server for use with VirtualGL (GLX + EGL back ends)"
echo "  * n to 'Restrict 3D X server access to vglusers group'"
echo "  * n to 'Restrict framebuffer device access to vglusers group'"
echo "  * y to 'Disable XTEST extension'"
echo "  * x) Exit"
echo "======================================================================"
echo ""
/opt/VirtualGL/bin/vglserver_config

# These packages aren't helpful on a system that has no sound card, no radio hardware, and is remote.
apt -y remove pulseaudio bluez bluez-obexd light-locker

# This stops bug reports.  On a longer-lived VM, I would leave these in place, but for a lab machine they are just an annoyance.
systemctl stop whoopsie.service
systemctl stop apport.service
systemctl disable whoopsie.service
systemctl disable apport.service

apt -y autoremove
cp virtualgl.sh /etc/profile.d
echo ""
echo "======================"
echo "You should now reboot."
echo "======================"
