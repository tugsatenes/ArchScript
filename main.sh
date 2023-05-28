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
