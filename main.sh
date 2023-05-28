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

# Şu anlık sadece nvme desteği var
# Diski gösterir

#fdisk /dev/nvme0n1 -l
fdisk /dev/sda -l
