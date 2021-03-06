#!/bin/bash
# Add a Linux desktop to the AD domain.
# NOTE: You have to put a real password in here, or it won't work!

set -e

# Resolve working directory
tld=$(dirname $(dirname ${0}))
# Locate config relative to script
cfg=${tld}/etc/adadd.cfg

. ${cfg} || ( \
	echo "ERROR: Config file ${cfg} is not readable- install may be broken" ;\
	exit 1 ;
)

if [ \! -x  ${msktjoin} ]
then
	echo "ERROR: msktjoin (${msktjoin}) is missing or not executable"
	exit 1
fi

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

if ! `which msktutil >/dev/null 2>&1`
then
   echo ; echo "Installing the msktutil package."
   apt-get -y -q install msktutil
fi

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
${msktjoin}

echo " "
echo "If results of klist -k -t -e do not look right, run msktjoin now."
echo "You may need to authenticate first, using kinit with your HutchNet ID."

exit 0
