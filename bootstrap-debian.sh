#!/bin/bash

#Debian Bootstrap
#Creates a sudo user, configures SSHD

if [ -z $4 ]; then
	echo "usage: $(basename $0) hostname username password sshdport"
	exit 1
fi

_HOSTNAME=$1
_USER=$2
PASSWORD=$3
SSHPORT=$4

# Host, time config
hostnamectl hostname $_HOSTNAME
ln -sf /usr/share/zoneinfo/Australia/Adelaide /etc/localtime
hwclock --systohc --utc

# Apt
apt-get -y update && apt-get -y upgrade
apt-get install -y sudo openssh-server

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
echo '### Add key to https://gitlab.com/-/user_settings/ssh_keys            ###'
echo "### Clone or sync dotfiles:                                           ###"
echo '### $ git clone git@gitlab.com:namalsk/dotfiles.git ~/.dotfiles       ###'
echo "#########################################################################"

