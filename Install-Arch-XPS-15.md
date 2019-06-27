# Arch Linux on Dell XPS 15 (9570)

Table of Contents:

<!-- TOC -->autoauto- [Arch Linux on Dell XPS 15 (9570)](#arch-linux-on-dell-xps-15-9570)auto    - [Downlading Image](#downlading-image)auto    - [Installing Arch Linux](#installing-arch-linux)auto        - [Booting](#booting)auto        - [Setting Keyboard layout](#setting-keyboard-layout)auto        - [Setting WIFI network](#setting-wifi-network)auto        - [Update the System Clock](#update-the-system-clock)auto        - [Partition the disks](#partition-the-disks)auto        - [Example Layouts](#example-layouts)auto        - [Creating Partions](#creating-partions)auto        - [Format disks](#format-disks)auto        - [Create Encrypted Drive:](#create-encrypted-drive)auto        - [Create encrypted partitions](#create-encrypted-partitions)auto        - [Create filesystems on encrypted partitions](#create-filesystems-on-encrypted-partitions)auto        - [Mount the new system](#mount-the-new-system)auto    - [Installation](#installation)auto        - [Install the base package](#install-the-base-package)auto    - [Configure the System](#configure-the-system)auto        - [Fstab](#fstab)auto        - [Chroot](#chroot)auto        - [Time zone](#time-zone)auto        - [Set the hostname](#set-the-hostname)auto        - [Localization](#localization)auto        - [Set password for root](#set-password-for-root)auto        - [Add user to the system](#add-user-to-the-system)auto        - [Configure mkinitcpio modules](#configure-mkinitcpio-modules)auto    - [Setup grub](#setup-grub)auto        - [Grub Encryption](#grub-encryption)auto        - [Select acpi parameters](#select-acpi-parameters)auto        - [Make Grub CFG](#make-grub-cfg)auto    - [Exit the system](#exit-the-system)auto    - [Unmount all partitions](#unmount-all-partitions)auto    - [Reboot into the new system](#reboot-into-the-new-system)auto    - [Log in to the new system](#log-in-to-the-new-system)auto    - [Escalate to root](#escalate-to-root)auto    - [Exit root](#exit-root)auto    - [connect to wifi](#connect-to-wifi)auto    - [Update](#update)auto    - [Install linux headers](#install-linux-headers)auto    - [Install AUR](#install-aur)auto    - [Install AURMAN](#install-aurman)auto    - [Install xorg](#install-xorg)auto    - [Install nvidia driver](#install-nvidia-driver)auto    - [Install tilix, nautilus, gnome-control-center and python-nautilus](#install-tilix-nautilus-gnome-control-center-and-python-nautilus)auto    - [Install bumblebee and enable the service](#install-bumblebee-and-enable-the-service)auto    - [Install Graphical Desktop](#install-graphical-desktop)auto        - [Configure Deeping Display manager](#configure-deeping-display-manager)auto    - [Reboot Arch](#reboot-arch)auto    - [Resources](#resources)autoauto<!-- /TOC -->

## Downlading Image

Arch Linux image can be found on: <https://www.archlinux.org/>

Creating Bootable USB-Drive on Linux

`dd if=archlinux.img of=/dev/sdX bs=16M && sync`

## Installing Arch Linux

### Booting

Boot the Live Environment from USB flash drive.

### Setting Keyboard layout

Default console keymap is US.
`loadkeys us`

Available layouts can be listed with:
`ls /usr/share/kbd/keymaps/**/*.map.gz`

Filter available layouts:
`ls /usr/share/kbd/keymaps/**/*.map.gz | grep "us"`

### Setting WIFI network

On XPS 9570 WIFI Driver is available on the Live Image. And we can directly select WIFI network:
`wifi-menu`

### Update the System Clock

We need to ensure the accuracy of the system clock. We can do so via `timedatectl`:
`timedatectl set-ntp true`

Additional commands:
`timedatectl  status`
`timedatectl list-timezones`
`timedatectl list-timezones | grep "Europe"`
`timedatectl list-timezones | egrep -o "Europe/S.*"`
`timedatectl set-timezone "Europe/Sofia"`

### Partition the disks

List all disks on the system:
`fdisk -l`

### Example Layouts

| Device          | Mount Point   | Partition type               | Size  |
|-----------------|---------------|------------------------------|-------|
| /dev/nvme0n1p1  |               | Microsoft reserved           |       |
| /dev/nvme0n1p2  | /mnt/boot/EFI | EFI System                   |       |
| /dev/nvme0n1p3  |               | Microsoft basic data         |       |
| /dev/nvme0n1p4  |               | Windows recovery environment |       |
| /dev/nvme0n1p5  |               | BIOS boot                    |       |
| /dev/nvme0n1p6  | /mnt/boot     | Linux filesystem             | 500M  |
| /dev/nvme0n1p7  |               | Windows recovery environment |       |
| /dev/nvme0n1p8  |               | Windows recovery environment |       |
| /dev/nvme0n1p9  |               | Windows recovery environment |       |
| /dev/nvme0n1p10 | /mnt          | Linux filesystem             | 79.5G |

### Creating Partions

`cgdisk /dev/nvme0n1`

### Format disks

Format Boot drive:
`mkfs.ext2 /dev/nvme0n1p2`

### Create Encrypted Drive:

```bash
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/nvme0n1p10
cryptsetup luksOpen /dev/nvme0n1p10 luks
```

### Create encrypted partitions

```bash
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 16G vg0 --name swap
lvcreate -l +100%FREE vg0 --name root
```

### Create filesystems on encrypted partitions

```bash
mkfs.ext4 /dev/mapper/vg0-root
mkswap /dev/mapper/vg0-swap
```

### Mount the new system

```bash
mount /dev/mapper/vg0-root /mnt
swapon /dev/mapper/vg0-swap
mkdir /mnt/boot
mount /dev/nvme0n1p6 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/nvme0n1p2 /mnt/boot/efi
```

## Installation

### Install the base package

`pacstrap /mnt base base-devel grub-efi-x86_64 zsh vim git efibootmgr dialog wpa_supplicant`

## Configure the System

### Fstab

Generate fstab file:
`genfstab -pU /mnt >> /mnt/etc/fstab`

Usefull changes in Fstab file:

Make /tmp a ramdisk (add the following line to /mnt/etc/fstab)
`tmpfs  /tmp    tmpfs   defaults,noatime,mode=1777  0 0`

In case of using SSD in the same file Change `relatime` on all non-boot partitions to `noatime`

### Chroot

Change root into the new system:
`arch-chroot /mnt /bin/bash`

### Time zone

Set the time zone:
`ln -s /usr/share/zoneinfo/Europe/Sofia /etc/localtime`

Run hwclock to generate /etc/adjtime:
`hwclock --systohc --utc`

### Set the hostname

`echo MYHOSTNAME > /etc/hostname`

### Localization

`echo LANG=en_GB.UTF-8 >> /etc/locale.conf`
`echo LANGUAGE=en_US >> /etc/locale.conf`
`echo LC_ALL=C >> /etc/locale.conf`

### Set password for root

`passwd`

### Add user to the system

Create user:
`useradd -m -g users -G wheel -s /bin/zsh username`

Set password of the new user:
`passwd username`

### Configure mkinitcpio modules

`vim /etc/mkinitcpio.conf`

- Add 'ext4' to MODULES
- Add 'encrypt' and 'lvm2' to HOOKS before filesystems

Regenerate initrd image
`mkinitcpio -p linux`

## Setup grub

`grub-install`

### Grub Encryption

`vim /etc/default/grub`

Change `GRUB_CMDLINE_LINUX` to:
`GRUB_CMDLINE_LINUX="cryptdevice=/dev/nvme0n1p3:luks:allow-discards"`

### Select acpi parameters

`vim /etc/default/grub`

Change `GRUB_CMDLINE_LINUX_DEFAULT` to:
`GRUB_CMDLINE_LINUX_DEFAULT="acpi_rev_override=5"`

<https://forum.manjaro.org/t/how-to-choose-the-proper-acpi-kernel-argument/80035>

```text
Note for Dell Laptops

Sometimes the above kernel parameters will not work properly on some Dell laptops. If that is the case, you can try the following: acpi_rev_override=# Replace the “#” with a number between 1 to 5. In order to have this kernel parameter applied properly, cold booting (shutting your system down completely before restarting) your laptop twice may be required.
```

### Make Grub CFG

`grub-mkconfig -o /boot/grub/grub.cfg`

## Exit the system

`exit`

## Unmount all partitions

`umount -R /mnt`
`swapoff -a`

## Reboot into the new system

`reboot`

## Log in to the new system

`username`
`password`

## Escalate to root 

`su`

Add user to sudoers file:
`visudo`

Uncommment line:
`%wheel ALL=(ALL) ALL`

## Exit root

`exit`

## connect to wifi

`sudo wifi-menu`

## Update

`sudo pacman -Fy`
`sudo pacman -Syu`

## Install linux headers

`sudo pacman -S linux-headers`

## Install AUR

```bash
git clone https://aur.archlinux.org/aurman.git
cd aurman
makepkg -Acs
```

## Install AURMAN

`sudo pacman -U aurman-<version>-any.pkg.tar.xz`

## Install xorg

`sudo pacman -S xorg xorg-server xorg-xrandr`

## Install nvidia driver

`sudo pacman -S nvidia`

## Install tilix, nautilus, gnome-control-center and python-nautilus

`sudo pacman -S nautilus python-nautilus tilix gnome-control-center`

## Install bumblebee and enable the service

`sudo pacman -S bumblebee mesa xf86-video-intel`

Add user to bumblebee group:
`sudo gpasswd -a <username> bumblebee`

Enable bumblebee service:
`sudo systemctl enable bumblebeed.service`

## Install Graphical Desktop

Deeping Desktop:
`sudo pacman -S deepin`
`sudo pacman -S deepin-extra`

Install `lightdm`
`sudo pacman -S lightdm lightdm-gtk-greeter`

### Configure Deeping Display manager

`sudo vi /etc/lightdm/lightdm.conf`

Find the following line:
`#greeter-session=`
And change it to:
`greeter-session=lightdm-deepin-greeter`

Start `lightdm` service
`sudo systemctl start lightdm.service`

Enable `lightdm` service
`sudo systemctl enable lightdm.service`

## Reboot Arch

Reboot arch, System is ready!

## Resources

- [The official installation guide](https://wiki.archlinux.org/index.php/Installation_Guide)
- [Arch wiki page on XPS 15](https://wiki.archlinux.org/index.php/Dell_XPS_15_9560)
- [Wireless network configuration](https://wiki.archlinux.org/index.php/Wireless_network_configuration)
- [USB flash installation media](https://wiki.archlinux.org/index.php/USB_flash_installation_media)
- [TIMEDATECTL Manual](https://jlk.fjfi.cvut.cz/arch/manpages/man/timedatectl.1)
- [Device Encryption](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption)
- [fstab file](https://wiki.archlinux.org/index.php/Fstab)
- [Change root](https://wiki.archlinux.org/index.php/Change_root)
- [Install Deepin Desktop Environment In Arch Linux](https://www.ostechnix.com/install-deepin-desktop-environment-arch-linux/)
- [Bumblebee Installation](https://wiki.archlinux.org/index.php/Bumblebee#Installation)
