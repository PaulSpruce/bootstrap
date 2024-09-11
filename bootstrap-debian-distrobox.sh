#!/bin/bash

#Debian Distrobox Bootstrap

# Add sudo user
echo -e "$USER ALL=(ALL) NOPASSWD: ALL\nDefaults lecture = never" | sudo tee /etc/sudoers.d/00_${USER} > /dev/null

# Apt
sudo apt-get -y update && sudo apt-get -y upgrade
