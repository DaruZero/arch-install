#!/bin/bash
#  ____    __  _____  _   _
# |  _ \  /  \|  _  \| | | |   Matteo Danelon
# | | | |/ /\ \ |_| /| | | |   https://github.com/DaruZero/
# | |_| /  __  \ _  \| |_| |
# |____/__/  \__| \__\_____/
# 
# NAME: kde.sh
# DESC: A post-installations script to install the KDE Plasma desktop environment
# WARNING: Run this script at  your own risk


# VARIABLES
COUNTRY='Italy'

# SET TIME
sudo timedatectl set-ntp true
sudo hwclock --systohc

# SYNC MIRRORLIST
sudo reflector -c $COUNTRY -a 6 --sort rate --save /etc/pacman.d/mirrorlist

# INSTALL YAY
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# INSTALL PLASMA
sudo pacman -Sy --noconfirm xorg sddm plasma materia-kde

# INSTALL OTHER PROGRAMS
sudo pacman -Sy - < pkglist.txt
yay -S - < aurlist.txt

# FINALIZE INSTALLATION
sudo systemctl enable sddm
/bin/echo -e "\e[1;32mREBOOTING IN 5..4..3..2..1..\e[0m"
sleep 5
reboot
