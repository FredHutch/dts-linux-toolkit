#!/bin/bash
# Add a Linux desktop to the AD domain.
# NOTE: You have to put a real password in here, or it won't work!

echo " "
echo "This script joins a Linux desktop to the AD domain."
echo "It can be run more than once if necessary."
echo " "

# This script absolutely must be run as root.
if [ $USER != "root" ]
then
   echo "You must be root to run this script -- exiting."
   exit 0
fi

# Until Chef does this right, just download a working krb5.conf.
echo ; echo "Downloading a working /etc/krb5.conf."
rm -f /etc/krb5.conf
wget http://cuttlefish.fhcrc.org/misc/krb5.conf -O /etc/krb5.conf

if ! `which msktutil >/dev/null 2>&1`
then
   echo ; echo "Installing the msktutil package."
   apt-get -y -q install msktutil
fi

rm -f /usr/local/sbin/msktjoin
echo ; echo "Downloading the msktjoin script."
wget http://cuttlefish.fhcrc.org/misc/msktjoin -O /usr/local/sbin/msktjoin
chmod +x /usr/local/sbin/msktjoin

# Remove the krb5.keytab from any prior attempts.
rm -f /etc/krb5.keytab

# This needs to collect the HutchNet ID of an admin who can join
# a system to the domain, then do kinit <HutchNet ID>
adminid=""
while [ -z $adminid ]
do
   echo; read -p "Enter your HutchNet ID: " adminid
done

kinit $adminid

# Pause for AD to settle?
sleep 4

echo ; echo "Attempting to join the system to the AD domain."
msktjoin

echo " "
echo "If results of klist -k -t -e do not look right, run msktjoin now."
echo "You may need to authenticate first, using kinit with your HutchNet ID."

exit 0
