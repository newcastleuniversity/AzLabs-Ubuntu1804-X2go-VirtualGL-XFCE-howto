# Azure Lab Services GPU visualisation on Ubuntu 18.04 with VirtualGL, XFCE, and X2goserver

Author: Helen Griffiths, Newcastle University IT Service.
Built on prior work by John Snowdon, Newcastle University IT Service.

## Purpose

To be able to run GL-enabled applications over X2go without breaking `apt autoremove`.  A deeper explanation is under "Why follow this process?" at the bottom of this page.

## You need

- Access to an Azure Lab Services subscription with the ability to export templates to a shared gallery. You do not need to be able to create Azure VMs outwith Labs.
- An SSH client on your local machine.
- An X2go client on your local machine.

## How to create the template

10. Start by making a lab from the Canonical Ubuntu Server 18.04 image. Choose a VM size that has GPU visualisation and say "yes" to the NVidia drivers being installed.  Make note of the username you chose as you will reuse it later.
20. Start the template and login over SSH, then `sudo -i` to get root.
30. `git clone` this repo to /root and `cd` into the repo directory.
40. Run `bash lazy1.sh` and answer any questions that appear.
50. Edit the variable at the top of lazy2.sh based on the last output from lazy1.sh, and run `bash lazy2.sh`.
60. Reboot and login using X2go.  Go through the first-run wizards to set up Xpanel and make any changes needed to the desktop environment, e.g. wallpaper, font size, etc.  I removed all the buttons bar "logout" from the panel widget that has poweroff etc because stopping the OS doesn't stop the VM; the student still must stop the VM in https://labs.azure.com.

## How to use GL applications

10. Launch a terminal emulator in your X2go session.
20. Prepend `vglrun` to the command that launches your application, e.g. `vglrun glxgears` instead of `glxgears`.  **If you omit `vglrun`, your whole X session will terminate instantly** leaving a core dump file in your home folder.

Consider using wrapper scripts and modifying menu items to make your students less likely to crash their sessions.  I enclose examples in the *glwrappers* directory.

## Caveats when exporting to image and publishing to lab

- **Untick "install GPU drivers"** when you use an image created this way to make a new lab. The drivers are already in the image. If you tick this box, you will end up reinstalling *ubuntu-desktop*, which you really don't want.
- Make sure that you reuse the username from template creation when you make a new lab. This is because images made from Lab templates keep the user account information.  For example, when I make this template, I use the username "student". When I publish that template to a gallery image and then reuse that gallery image for further labs, I make sure to always use "student" as the username.
- Turn off both of the "automatic shutdown & disconnect" settings during lab creation, before exporting the template to a compute gallery image, and before publishing to a lab. This is to stop the automatic shutdown scripts from interfering with the copying processes. You can turn automatic shutdown on after the lab is published.

## Why follow this process?

The package *cloud-init* is installed on Ubuntu 18.04 to enable automatic shutdown and password resets. [*Cloud-init* requires exactly one of *ifupdown* or *netplan.io*.](https://bugs.launchpad.net/ubuntu/+source/cloud-init/+bug/1832381)  The [task package *ubuntu-minimal* depends on *netplan.io* via *nplan*](https://packages.ubuntu.com/bionic-updates/ubuntu-minimal), so a basic Ubuntu 18.04 lab template has *netplan.io* installed.

When you tick the box during GPU lab creation to install NVidia drivers, Microsoft's Azure platform adds the *ubuntu-desktop* task onto the template, which in turn drags *ifupdown* onto the template as a dependency.  If both *netplan.io* and *ifupdown* exist on the same template, *cloud-init* will not work properly, giving the following symptoms:
- When the template is exported to a custom image and the image then used to make a new lab, the new lab fails with a message saying that the template is in a failed state.
- When you publish the lab, attempts to change the VM password never finish, you get a "spinning wheel" that never ends.

The [official Microsoft workaround](https://raw.githubusercontent.com/Azure/azure-devtestlab/master/samples/ClassroomLabs/Scripts/LinuxGraphicalDesktopSetup/GNOME_MATE/Ubuntu/x2go-mate.sh) is to remove *netplan.io*, which also removes the *ubuntu-minimal* task package.  This leaves some packages marked as "automatically installed" without being depended upon by a manually-installed package, making them candidates for removal using `apt autoremove`.  By contrast, *ubuntu-desktop* installs GNOME, which is [known not to work well with X2go](https://wiki.x2go.org/doku.php/doc:de-compat), so I think it makes more sense to remove *ubuntu-desktop* and *ifupdown*, leaving *ubuntu-minimal* in place.

The process contained in this repository removes *ubuntu-desktop* and *ifupdown* and provisions *xubuntu-desktop* instead to provide a graphical desktop that works with *netplan.io*, allowing *cloud-init* to work.
