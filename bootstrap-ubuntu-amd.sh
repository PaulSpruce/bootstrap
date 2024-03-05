#!/bin/bash

# Ubuntu Bootstrap
# Creates a sudo user, configures SSHD

if [ -z $4 ]; then
	echo "usage: $(basename $0) username password sshdport"
	exit 1
fi

_USER=$1
PASSWORD=$2
SSHPORT=$3

ln -sf /usr/share/zoneinfo/Australia/Adelaide /etc/localtime
hwclock --systohc --utc

# Apt
sudo apt-get purge needrestart
sudo apt-get -y update && sudo apt-get -y upgrade

# Add sudo user
useradd -m -U -s /bin/bash -G sudo $_USER
echo "$_USER:$PASSWORD" | chpasswd
echo -e "$_USER ALL=(ALL) NOPASSWD: ALL\nDefaults lecture = never" > /etc/sudoers.d/00_$_USER

# Set up sshd: disable root login, change port, disable password auth
cat << EOF > /etc/ssh/sshd_config.d/50-local.conf
Port $SSHPORT
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
EOF
systemctl enable --now sshd.service
systemctl restart sshd.service

echo ""
echo "#########################################################################"
echo "### Complete! Now log in as user.                                     ###"
echo "### If required generate an SSH key:                                  ###"
echo '### $ ssh-keygen                                                      ###'
echo "### Add key to https://gitlab.com                                     ###"
echo "### Clone or sync dotfiles:                                           ###"
echo '### $ git clone git@gitlab.com:namalsk/dotfiles.git ~/.dotfiles       ###'
echo "#########################################################################"

