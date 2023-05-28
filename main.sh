#!/bin/bash


# Klavyeyi Türkçe yapar
loadkeys trq

# Efiyi kontrol eder
# Şu anlık sadece UEFI destekli, yardımlarınızı bekliyorum!
ls /sys/firmware/efi/efivars

# Şu anlık sadece kablolu dhcp kurulumlar destekli
#İnterneti kontrol eder
ping -c 5 archlinux.org

# Sistem saatini günceller
timedatectl set-ntp true

# Şu anlık sadece sanal makine desteği var
# Diski gösterir
#fdisk /dev/nvme0n1 -l
#fdisk /dev/sda -l
fdisk /dev/vda -l

# diski şu şekilde biçimlendirir:
# 512MB UEFI disk bölümü (1)
# 1GB Swap (takas) alanı (2)
# Diskin kalanı ise Kök (/) bölümü (3)

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << FDISK_CMDS  | fdisk /dev/vda
g      # Yeni GPT bölümü oluşturur
n      # yeni bölüm ekler
1      # Bölüm numarası
       # Varsayılan olarak ilk sektör alanını boş bırakıyoruz 
+512MB # Bölüm boyutu
n      # 
2      # 
       #  
+1GB   #  
t      # Bölüm tipini değiştirir
1      # 
uefi   # EFI bölümü
t      # 
2      # 
swap   # Takas alanı
n      #
3      #
       #
       # Geriye kalan bütün alan
w      # bölümlendirme tablosunu yazar ve çıkar
FDISK_CMDS

# Dosya sistemleri
mkfs.fat -F 32 /dev/vda1    # UEFI bölümü
mkswap /dev/vda2            # SWAP oluşturma
swapon /dev/vda2            # SWAP etkinleştirme
mkfs.ext4 /dev/vda3         # Kök (/)

# Bağlama (mount) aşaması
mount /dev/vda3 /mnt

# Gerekli paketleri /mnt ye kuruyoruz
pacstrap -K /mnt base linux linux-firmware

# Fstab dosyasını oluşturma
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot işlemi
arch-chroot /mnt

# Zaman dilimi
ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc

# Lokalizasyon
echo tr_TR.UTF-8 UTF-8 > /etc/locale.gen
locale-gen
touch /etc/locale.conf
echo LANG=tr_TR.UTF-8 > /etc/locale.conf
touch  /etc/vconsole.conf
echo KEYMAP=trq > /etc/vconsole.conf

# Ağ Konfigürasyonu
touch /etc/hostname
echo archlinux > /etc/hostname
echo 127.0.0.1        archlinux localhost \
::1              archlinux localhost \
127.0.1.1        archlinux localhost > /etc/hosts


# İnitramfs
mkinitcpio -P

# Önyükleyici
pacman -S grub 
mkdir /boot/efi
mount /dev/vda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg

# Parola
echo "Lütfen root kullanıcısı için bir şifre girin: "
passwd

# Kapanış (geçici)
exit
umount -R /mnt
echo "Lütfen sistemi (reboot) yazarak yeniden başlatınız!"

# Son!
