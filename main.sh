#!/bin/bash


# Klavyeyi Türkçe yapar
echo "Klavye Turkce yapiliyor"
loadkeys trq
sleep 1
clear

# Efiyi kontrol eder
# Şu anlık sadece UEFI destekli, yardımlarınızı bekliyorum!
echo "UEFI kontrol ediliyor"
ls /sys/firmware/efi/efivars
sleep 2
clear

# Şu anlık sadece kablolu dhcp kurulumlar destekli
# İnterneti kontrol eder
echo "Internet kontrol ediliyor"
ping -c 5 archlinux.org
sleep 2
clear

# Sistem saatini günceller
echo "Sistem saati guncelleniyor"
timedatectl set-ntp true
sleep 2
clear

# Şu anlık sadece sanal makine desteği var
# Diski gösterir
#fdisk /dev/nvme0n1 -l
#fdisk /dev/sda -l
echo "Şu anlık sadece sanal makine destegi var \
Diski gösteriyor"
fdisk /dev/vda -l
sleep 2
clear

# diski şu şekilde biçimlendirir:
# 512MB UEFI disk bölümü (1)
# 1GB Swap (takas) alanı (2)
# Diskin kalanı ise Kök (/) bölümü (3)

echo "Disk bu bicimde bicimlendiriliyor: \
 512MB UEFI disk bolumu (1) \
 1GB Swap (takas) alani (2) \
 Diskin kalani ise Kok (/) bolumu (3)"
sleep 2
clear

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
clear

# Gerekli paketleri /mnt ye kuruyoruz
pacstrap -K /mnt base linux linux-firmware

# Fstab dosyasını oluşturma
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
arch-chroot /mnt

# Zaman dilimi
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
arch-chroot /mnt hwclock --systohc

# Lokalizasyon
arch-chroot /mnt echo tr_TR.UTF-8 UTF-8 > /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt touch /etc/locale.conf
arch-chroot /mnt echo LANG=tr_TR.UTF-8 > /etc/locale.conf
arch-chroot /mnt touch  /etc/vconsole.conf
arch-chroot /mnt echo KEYMAP=trq > /etc/vconsole.conf
clear

# Ağ Konfigürasyonu
arch-chroot /mnt touch /etc/hostname
arch-chroot /mnt echo archlinux > /etc/hostname
arch-chroot /mnt echo 127.0.0.1        archlinux localhost \
::1              archlinux localhost \
127.0.1.1        archlinux localhost > /etc/hosts
clear


# İnitramfs
arch-chroot /mnt mkinitcpio -P

# Önyükleyici
arch-chroot /mnt pacman -S grub 
arch-chroot /mnt mkdir /boot/efi
arch-chroot /mnt mount /dev/vda1 /boot/efi
arch-chroot /mnt grub-install --target=x86_64-efi --bootloader-id=arch
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
clear

# Parola
arch-chroot /mnt echo "Lütfen root kullanıcısı için bir şifre girin: "
arch-chroot /mnt passwd
clear

# Kapanış (geçici)
arch-chroot /mnt exit
umount -R /mnt

read -p "Sistem yeniden başlatılsın mı? (evet/hayır) " secim

if [ "$secim" = "evet" ] 
then
    echo "Sistem yeniden başlatılıyor..."
    reboot
elif [ "$secim" = "hayır" ] 
then
    echo "Sistem yeniden başlatılmayacak."
else 
    echo "Geçersiz seçim. Lütfen evet veya hayır girin."
    exit
fi

# Son!
