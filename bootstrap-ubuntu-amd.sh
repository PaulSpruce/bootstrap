#!/bin/bash

# Ubuntu Bootstrap
# Creates a sudo user, configures SSHD

if [ $# -ne 3 ]; then
	echo "usage: $(basename $0) username password sshdport"
	exit 1
fi

user="$1"
password="$2"
ssh_port="$3"

sudo ln -sf /usr/share/zoneinfo/Australia/Adelaide /etc/localtime
echo "fs.inotify.max_user_watches=204800" | sudo tee -a /etc/sysctl.conf
sudo hwclock --systohc --utc


# Add sudo user
sudo useradd -m -U -s /bin/bash -G sudo $user
sudo sh -c 'echo "$user:$password | chpasswd'
sudo sh -c 'echo -e "$user ALL=(ALL) NOPASSWD: ALL\nDefaults lecture = never" > /etc/sudoers.d/00_$user'
sudo cp -r .ssh/ /home/administrator/
sudo chown administrator:administrator /home/administrator/.ssh

# Set up sshd: disable root login, change port, disable password auth
sudo cat << EOF > /etc/ssh/sshd_config.d/50-local.conf
Port $ssh_port
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
EOF
sudo systemctl enable --now sshd.service
sudo systemctl restart sshd.service

# Install dotfiles and apps
sudo apt-get -y purge needrestart
sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get install -y git

echo "Upload vps SSH keys to $user account (sftp ${user}@ip.address) and press Enter to continue:"
read -r
echo "Continuing..."


sudo su $user -c "GIT_SSH_COMMAND='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no' git clone git@$git_site:$git_user/dotfiles.git /home/$user/.dotfiles"

if [ -f /home/$user/.dotfiles/.local/bin/dotfiles.sh ]; then
	sudo su $user -c "/home/$user/.dotfiles/.local/bin/dotfiles.sh vps"
	#sudo su $user -c "/home/$user/.dotfiles/.local/bin/debian-install.sh vps | tee /tmp/debian-install.log"
fi

echo ""
echo "#########################################################################"
echo "### Complete! Now log in as user.                                     ###"
echo "### If required generate an SSH key:                                  ###"
echo '### $ ssh-keygen                                                      ###'
echo "### Add key to https://gitlab.com                                     ###"
echo "### Clone or sync dotfiles:                                           ###"
echo '### $ git clone git@gitlab.com:namalsk/dotfiles.git ~/.dotfiles       ###'
echo "#########################################################################"

