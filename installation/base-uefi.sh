#!/bin/bash
#  ____    __  _____  _   _
# |  _ \  /  \|  _  \| | | |   Matteo Danelon
# | | | |/ /\ \ |_| /| | | |   https://github.com/DaruZero/
# | |_| /  __  \ _  \| |_| |
# |____/__/  \__| \__\_____/
# 
# NAME: bash-uefi.sh
# DESC: An installations script for UEFI systems
# WARNING: Run this script at  your own risk

# VARIABLES
CONTINENT='Europe'
COUNTRY='Italy'
HOSTNAME='arch'
TLD_LOCAL='local'
ROOT_PWD='password'
USER='user'
USER_PWD='password'

# LOCALES AND KEYMAP
# see https://man7.org/linux/man-pages/man7/locale.7.html for more information
declare -a LOCALES=("en_US.UTF-8" "it_IT@euro ISO-8859-15")
LANG='${LOCALES[0]}'
ADDRESS='${LOCALES[1]}'
COLLATE='${LOCALES[1]}'
CTYPE='${LOCALES[1]}'
IDENTIFICATION='${LOCALES[1]}'
MONETARY='${LOCALES[1]}'
MESSAGES='${LOCALES[1]}'
MEASUREMENT='${LOCALES[1]}'
NAME='${LOCALES[1]}'
NUMERIC='${LOCALES[1]}'
PAPER='${LOCALES[1]}'
TELEPHONE='${LOCALES[1]}'
TIME='${LOCALES[1]}'
KEYMAP='it'

# Function to print the error and exit the script
error() { \
    clear; printf "[ERROR]\\n%s\\n" "$1" >&2; exit 1;
}


echo "[INFO] Syncing clock and setting timezone"
hwclock --systohc || error "Couldn't  sync clock"
ln -sf /usr/share/zoneinfo/$CONTINENT/$STATE /etc/localtime


generate_locale() { \
	echo "[INFO] Generating locale"
	for LOCALE in "${LOCALES[@]}"
	do
		sed -i $LOCALE/s/\#// /etc/locale.gen
	done

	locale-gen

	echo "[INFO] Copying locale configuration"
	echo "LANG=$LANG" >> /etc/locale.conf
	echo "LC_ADDRESS=$ADDRESS" >> /etc/locale.conf
	echo "LC_COLLATE=$COLLATE" >> /etc/locale.conf
	echo "LC_CTYPE=$CTYPE" >> /etc/locale.conf
	echo "LC_IDENTIFICATION=$IDENTIFICATION" >> /etc/locale.conf
	echo "LC_MONETARY=$MONETARY" >> /etc/locale.conf
	echo "LC_MESSAGES=$MESSAGES" >> /etc/locale.conf
	echo "LC_MEASUREMENT=$MEASUREMENT" >> /etc/locale.conf
	echo "LC_NAME=$NAME" >> /etc/locale.conf
	echo "LC_NUMERIC=$NUMERIC" >> /etc/locale.conf
	echo "LC_PAPER=$PAPER" >> /etc/locale.conf
	echo "LC_TELEPHONE=$TELEPHONE" >> /etc/locale.conf
	echo "LC_TIME=$TIME" >> /etc/locale.conf
	echo "KEYMAP=$KEYMAP" >> /etc/vconsole.conf
}

generate_locale || error "Couldn't generate locale"


echo "[INFO] Setting up hostname"
echo "$HOSTNAME" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.$TLD_LOCAL $HOSTNAME" >> /etc/hosts


setup_users() { \
	echo "[INFO] Setting up users"
	echo root:$ROOT_PWD | chpasswd
	useradd -m $USER
	echo $USER:$USER_PWD | chpasswd
	usermod -aG wheel $USER
	echo "$USER ALL=(ALL) ALL" >> /etc/sudoers.d/$USER
}

setup_users || error "Error while setting up users"


echo "[INFO] Installing packages"
pacman --needed -Sy - < pkglist.txt || error "Couldn't install packages"


gpu_drivers() { \
	echo "[INFO] Installing GPU drivers"
	if lscpi | grep -qi nvidia;
	then
		pacman -S nvidia nvidia-utils nvidia-settings
	elif lscpi | grep -qi amd;
	then
		pacman -S xf86-video-amdgpu
	fi
}

gpu_drivers || error "Couldn't install GPU drivers"


install_grub() { \
	echo "[INFO] Installing grub"
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB #change the directory to /boot/efi if you mounted the EFI partition at /boot/efi
	grub-mkconfig -o /boot/grub/grub.cfg
}

install_grub || error "Couldn's install grub"


enable_services()= { \
	echo "[INFO] Enabling services"
	systemctl enable NetworkManager
	systemctl enable bluetooth
	systemctl enable cups.service
	systemctl enable sshd
	systemctl enable avahi-daemon
	systemctl enable reflector.timer
	systemctl enable fstrim.timer
	systemctl enable libvirtd
	systemctl enable firewalld
	systemctl enable acpid
}

enable_services || error "Couldn't enable the services"


echo "Done! Type exit, umount -R /mnt and reboot."

