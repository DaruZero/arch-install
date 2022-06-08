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


# Function to print the error and exit the script
error() { \
    clear; printf "[ERROR]\\n%s\\n" "$1" >&2; exit 1;
}


set_time() { \
    echo "[INFO] Syncing time"
    sudo timedatectl set-ntp true
    sudo hwclock --systohc
}

set_time || error "Could not synchronize time"


echo "[INFO] Updating mirrorlist"
sudo reflector -c $COUNTRY -a 6 --sort rate --save /etc/pacman.d/mirrorlist || error "Updating mirrorlist with reflector"
echo "[INFO] Updating packages"
sudo pacman -Syy --needed || error "Syncing packages"


install_yay() { \
    echo "[INFO] Installing yay"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
}

install_yay || Error "While installing yay"


echo "[INFO] Installing Plasma"
sudo pacman -Sy --noconfirm xorg sddm plasma materia-kde || error "Could not install Plasma"


echo "[INFO] Installing other packages"
sudo pacman -Sy - < pkglist.txt || error "Could not install the other packages"
echo "[INFO] Installing other AUR packages"
yay -S - < aurlist.txt


echo "[INFO] Enabling sddm"
sudo systemctl enable sddm
echo "REBOOTING IN 5..4..3..2..1.."
sleep 5
reboot
