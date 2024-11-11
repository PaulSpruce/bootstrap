#!/bin/bash

#Debian Distrobox Bootstrap

hacking_tools="/home/administrator/builds/debian/debs/hacking-tools/hacking-tools.deb"
hacking_dir="/home/administrator/hacking"

# Add sudo user
if [ ! -f /etc/sudoers.d/zz_${USER} ]; then
	echo -e "$USER ALL=(ALL) NOPASSWD: ALL\nDefaults lecture = never" | sudo tee /etc/sudoers.d/zz_${USER} > /dev/null
fi

/home/administrator/.dotfiles/.local/bin/dotfiles.sh vps
source ~/.bashrc
debian-install.sh vps
ln -s "$hacking_dir" $HOME/hacking
sudo apt install -y --reinstall "$hacking_tools"
