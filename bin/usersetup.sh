#!/bin/bash
# Config changes to make for the primary user of the desktop system.

# This script absolutely must be run as root.
if [ $USER != "root" ]
then
   echo "You must be root to run this script -- exiting."
   exit 0
fi

# This collects the HutchNet ID.
mainuser=""
while [ -z $mainuser ]
do
   echo; read -p "Please enter the HutchNet ID of the primary user of this desktop: " mainuser
done

# Make a home directory.
cp -R /etc/skel /home/$mainuser

# Make a partial Samba credentials file.
mkdir -p /home/${mainuser}/.samba
cat >/home/${mainuser}/.samba/creds <<EndSamba
user=${mainuser}
password=HutchNet_ID_password
domain=FHCRC
EndSamba

chmod 700 /home/${mainuser}/.samba
chmod 600 /home/${mainuser}/.samba/creds

# Give them an SSH "config" file.
mkdir -p /home/${mainuser}/.ssh
cat >/home/${mainuser}/.ssh/config <<EndSsh
ForwardX11 yes
ForwardX11Trusted yes
Host *rhino*
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
Host *gizmo*
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
EndSsh

chmod 700 /home/${mainuser}/.ssh
chmod 600 /home/${mainuser}/.ssh/config

# Make sure they own everything in their homedir.
chown -R ${mainuser}:g_${mainuser} /home/${mainuser}

# Give the user some special group memberships.
usermod -aG adm,cdrom,sudo,dip,plugdev,lpadmin $mainuser

# Remove the local service user stwohats.
deluser --remove-home stwohats

exit 0
