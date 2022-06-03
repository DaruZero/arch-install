#!/bin/bash


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
LANG='en_US.UTF-8'
LC_TIME='it_IT.UTF-8'
KEYMAP='it'


# INITIAL CONFIGURATION
ln -sf /usr/share/zoneinfo/$CONTINENT/$STATE /etc/localtime
hwclock --systohc
sed -i "$LOCALE/s/^#//" /etc/locale.gen
locale-gen
echo "LANG=$LANG" >> /etc/locale.conf
echo "LC_TIME=$LC_TIME" >> /etc/locale.conf
echo "KEYMAP=$KEYMAP" >> /etc/vconsole.conf
echo "$HOSTNAME" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.$TLD_LOCAL $HOSTNAME" >> /etc/hosts
echo root:$ROOT_PWD | chpasswd


# INSTALL PACKAGES
sudo pacman --needed -Sy - < pkglist.txt


# DOWNLOAD GPU DRIVERS
if lscpi | grep -qi nvidia
then
	pacman -S nvidia nvidia-utils nvidia-settings
elif
	pacman -S xf86-video-amdgpu
fi


# INSTALL GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB #change the directory to /boot/efi is you mounted the EFI partition at /boot/efi
grub-mkconfig -o /boot/grub/grub.cfg


# SERVICES
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

# USERS
useradd -m $USER
echo $USER:$USER_PWD | chpasswd
usermod -aG libvirt $USER

echo "$USER ALL=(ALL) ALL" >> /etc/sudoers.d/$USER


printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"
