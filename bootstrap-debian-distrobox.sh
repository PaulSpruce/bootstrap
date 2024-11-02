#!/bin/bash

#Debian Distrobox Bootstrap

# Add sudo user
if [ ! -f /etc/sudoers.d/zz_${USER} ]; then
	echo -e "$USER ALL=(ALL) NOPASSWD: ALL\nDefaults lecture = never" | sudo tee /etc/sudoers.d/zz_${USER} > /dev/null
fi

"/home/administrator/.dotfiles/.local/bin/dotfiles.sh" vps
"/home/administrator/.dotfiles/.local/bin/debian-install.sh" vps
ln -s /home/administrator/hacking/ ${HOME}/hacking
sudo apt install --reinstall "/home/administrator/builds/debian/debs/hacking-tools/hacking-tools.deb"
