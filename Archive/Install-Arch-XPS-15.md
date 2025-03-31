# 1. Arch Linux on Dell XPS 15 (9570)

Table of Contents:

- [1. Arch Linux on Dell XPS 15 (9570)](#1-Arch-Linux-on-Dell-XPS-15-9570)
  - [1.1. Downlading Image](#11-Downlading-Image)
  - [1.2. Installing Arch Linux](#12-Installing-Arch-Linux)
    - [1.2.1. Booting](#121-Booting)
    - [1.2.2. Setting Keyboard layout](#122-Setting-Keyboard-layout)
    - [1.2.3. Setting WIFI network](#123-Setting-WIFI-network)
    - [1.2.4. Update the System Clock](#124-Update-the-System-Clock)
    - [1.2.5. Partition the disks](#125-Partition-the-disks)
    - [1.2.6. Example Layouts](#126-Example-Layouts)
    - [1.2.7. Creating Partions](#127-Creating-Partions)
    - [1.2.8. Format disks](#128-Format-disks)
    - [1.2.9. Create Encrypted Drive](#129-Create-Encrypted-Drive)
    - [1.2.10. Create encrypted partitions](#1210-Create-encrypted-partitions)
    - [1.2.11. Create filesystems on encrypted partitions](#1211-Create-filesystems-on-encrypted-partitions)
    - [1.2.12. Mount the new system](#1212-Mount-the-new-system)
  - [1.3. Installation](#13-Installation)
    - [1.3.1. Install the base package](#131-Install-the-base-package)
  - [1.4. Configure the System](#14-Configure-the-System)
    - [1.4.1. Fstab](#141-Fstab)
    - [1.4.2. Chroot](#142-Chroot)
    - [1.4.3. Time zone](#143-Time-zone)
    - [1.4.4. Set the hostname](#144-Set-the-hostname)
    - [1.4.5. Localization](#145-Localization)
    - [1.4.6. Set password for root](#146-Set-password-for-root)
    - [1.4.7. Add user to the system](#147-Add-user-to-the-system)
    - [1.4.8. Configure mkinitcpio modules](#148-Configure-mkinitcpio-modules)
  - [1.5. Setup grub](#15-Setup-grub)
    - [1.5.1. Grub Encryption](#151-Grub-Encryption)
    - [1.5.2. Select acpi parameters](#152-Select-acpi-parameters)
    - [1.5.3. Make Grub CFG](#153-Make-Grub-CFG)
  - [1.6. Exit the system](#16-Exit-the-system)
  - [1.7. Unmount all partitions](#17-Unmount-all-partitions)
  - [1.8. Reboot into the new system](#18-Reboot-into-the-new-system)
  - [1.9. Log in to the new system](#19-Log-in-to-the-new-system)
  - [1.10. Escalate to root](#110-Escalate-to-root)
  - [1.11. Exit root](#111-Exit-root)
  - [1.12. connect to wifi](#112-connect-to-wifi)
  - [1.13. Update](#113-Update)
  - [1.14. Install linux headers](#114-Install-linux-headers)
  - [1.15. Install AUR](#115-Install-AUR)
  - [1.16. Install AURMAN](#116-Install-AURMAN)
  - [1.17. Install xorg](#117-Install-xorg)
  - [1.18. Install nvidia driver](#118-Install-nvidia-driver)
  - [1.19. Install tilix, nautilus, gnome-control-center and python-nautilus](#119-Install-tilix-nautilus-gnome-control-center-and-python-nautilus)
  - [1.20. Install bumblebee and enable the service](#120-Install-bumblebee-and-enable-the-service)
  - [1.21. Install Graphical Desktop](#121-Install-Graphical-Desktop)
    - [1.21.1. Configure Deeping Display manager](#1211-Configure-Deeping-Display-manager)
  - [1.22. Reboot Arch](#122-Reboot-Arch)
  - [1.23. Resources](#123-Resources)

## 1.1. Downlading Image

Arch Linux image can be found on: <https://www.archlinux.org/>

Creating Bootable USB-Drive on Linux

`dd if=archlinux.img of=/dev/sdX bs=16M && sync`

## 1.2. Installing Arch Linux

### 1.2.1. Booting

Boot the Live Environment from USB flash drive.

### 1.2.2. Setting Keyboard layout

Default console keymap is US.
`loadkeys us`

Available layouts can be listed with:
`ls /usr/share/kbd/keymaps/**/*.map.gz`

Filter available layouts:
`ls /usr/share/kbd/keymaps/**/*.map.gz | grep "us"`

### 1.2.3. Setting WIFI network

On XPS 9570 WIFI Driver is available on the Live Image. And we can directly select WIFI network:
`wifi-menu`

### 1.2.4. Update the System Clock

We need to ensure the accuracy of the system clock. We can do so via `timedatectl`:
`timedatectl set-ntp true`

Additional commands:
`timedatectl  status`
`timedatectl list-timezones`
`timedatectl list-timezones | grep "Europe"`
`timedatectl list-timezones | egrep -o "Europe/S.*"`
`timedatectl set-timezone "Europe/Sofia"`

### 1.2.5. Partition the disks

List all disks on the system:
`fdisk -l`

### 1.2.6. Example Layouts

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

### 1.2.7. Creating Partions

`cgdisk /dev/nvme0n1`

### 1.2.8. Format disks

Format Boot drive:
`mkfs.ext2 /dev/nvme0n1p2`

### 1.2.9. Create Encrypted Drive

```bash
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/nvme0n1p10
cryptsetup luksOpen /dev/nvme0n1p10 luks
```

### 1.2.10. Create encrypted partitions

```bash
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 16G vg0 --name swap
lvcreate -l +100%FREE vg0 --name root
```

### 1.2.11. Create filesystems on encrypted partitions

```bash
mkfs.ext4 /dev/mapper/vg0-root
mkswap /dev/mapper/vg0-swap
```

### 1.2.12. Mount the new system

```bash
mount /dev/mapper/vg0-root /mnt
swapon /dev/mapper/vg0-swap
mkdir /mnt/boot
mount /dev/nvme0n1p6 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/nvme0n1p2 /mnt/boot/efi
```

## 1.3. Installation

### 1.3.1. Install the base package

`pacstrap /mnt base base-devel grub-efi-x86_64 zsh vim git efibootmgr dialog wpa_supplicant`

## 1.4. Configure the System

### 1.4.1. Fstab

Generate fstab file:
`genfstab -pU /mnt >> /mnt/etc/fstab`

Usefull changes in Fstab file:

Make /tmp a ramdisk (add the following line to /mnt/etc/fstab)
`tmpfs  /tmp    tmpfs   defaults,noatime,mode=1777  0 0`

In case of using SSD in the same file Change `relatime` on all non-boot partitions to `noatime`

### 1.4.2. Chroot

Change root into the new system:
`arch-chroot /mnt /bin/bash`

### 1.4.3. Time zone

Set the time zone:
`ln -s /usr/share/zoneinfo/Europe/Sofia /etc/localtime`

Run hwclock to generate /etc/adjtime:
`hwclock --systohc --utc`

### 1.4.4. Set the hostname

`echo MYHOSTNAME > /etc/hostname`

### 1.4.5. Localization

`echo LANG=en_GB.UTF-8 >> /etc/locale.conf`
`echo LANGUAGE=en_US >> /etc/locale.conf`
`echo LC_ALL=C >> /etc/locale.conf`

### 1.4.6. Set password for root

`passwd`

### 1.4.7. Add user to the system

Create user:
`useradd -m -g users -G wheel -s /bin/zsh username`

Set password of the new user:
`passwd username`

### 1.4.8. Configure mkinitcpio modules

`vim /etc/mkinitcpio.conf`

- Add 'ext4' to MODULES
- Add 'encrypt' and 'lvm2' to HOOKS before filesystems

Regenerate initrd image
`mkinitcpio -p linux`

## 1.5. Setup grub

`grub-install`

### 1.5.1. Grub Encryption

`vim /etc/default/grub`

Change `GRUB_CMDLINE_LINUX` to:
`GRUB_CMDLINE_LINUX="cryptdevice=/dev/nvme0n1p3:luks:allow-discards"`

### 1.5.2. Select acpi parameters

`vim /etc/default/grub`

Change `GRUB_CMDLINE_LINUX_DEFAULT` to:
`GRUB_CMDLINE_LINUX_DEFAULT="acpi_rev_override=5"`

<https://forum.manjaro.org/t/how-to-choose-the-proper-acpi-kernel-argument/80035>

```text
Note for Dell Laptops

Sometimes the above kernel parameters will not work properly on some Dell laptops. If that is the case, you can try the following: acpi_rev_override=# Replace the “#” with a number between 1 to 5. In order to have this kernel parameter applied properly, cold booting (shutting your system down completely before restarting) your laptop twice may be required.
```

### 1.5.3. Make Grub CFG

`grub-mkconfig -o /boot/grub/grub.cfg`

## 1.6. Exit the system

`exit`

## 1.7. Unmount all partitions

`umount -R /mnt`
`swapoff -a`

## 1.8. Reboot into the new system

`reboot`

## 1.9. Log in to the new system

`username`
`password`

## 1.10. Escalate to root

`su`

Add user to sudoers file:
`visudo`

Uncommment line:
`%wheel ALL=(ALL) ALL`

## 1.11. Exit root

`exit`

## 1.12. connect to wifi

`sudo wifi-menu`

## 1.13. Update

`sudo pacman -Fy`
`sudo pacman -Syu`

## 1.14. Install linux headers

`sudo pacman -S linux-headers`

## 1.15. Install AUR

```bash
git clone https://aur.archlinux.org/aurman.git
cd aurman
makepkg -Acs
```

## 1.16. Install AURMAN

`sudo pacman -U aurman-<version>-any.pkg.tar.xz`

## 1.17. Install xorg

`sudo pacman -S xorg xorg-server xorg-xrandr`

## 1.18. Install nvidia driver

`sudo pacman -S nvidia`

## 1.19. Install tilix, nautilus, gnome-control-center and python-nautilus

`sudo pacman -S nautilus python-nautilus tilix gnome-control-center`

## 1.20. Install bumblebee and enable the service

`sudo pacman -S bumblebee mesa xf86-video-intel`

Add user to bumblebee group:
`sudo gpasswd -a <username> bumblebee`

Enable bumblebee service:
`sudo systemctl enable bumblebeed.service`

## 1.21. Install Graphical Desktop

Deeping Desktop:
`sudo pacman -S deepin`
`sudo pacman -S deepin-extra`

Install `lightdm`
`sudo pacman -S lightdm lightdm-gtk-greeter`

### 1.21.1. Configure Deeping Display manager

`sudo vi /etc/lightdm/lightdm.conf`

Find the following line:
`#greeter-session=`
And change it to:
`greeter-session=lightdm-deepin-greeter`

Start `lightdm` service
`sudo systemctl start lightdm.service`

Enable `lightdm` service
`sudo systemctl enable lightdm.service`

## 1.22. Reboot Arch

Reboot arch, System is ready!

## 1.23. Resources

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
