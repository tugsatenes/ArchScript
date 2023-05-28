# ArchScript

Türk kullanıcılar için tamamen Türkçe ArchLinux (btw) kurulum scripti!

Sadece kopyala yapıştır yapmak ve uğraşmadan ArchLinux (btw) kurmak istiyorsanız bir deneyin derim!

Hiç uğraşmadan sadece ne görüyorsanız onları terminale yazın ve bitsin bu iş!

Şu anlık sadece bir prototip olduğundan sanal makine içinde ve /dev/vda disklerle denemenizi (şiddetle) tavsiye ederim. 

Başka bir disk türünüz varsa (/dev/sda,/dev/nvme0n1) gerekli yerleri değiştirerek kullanabilirsiniz.

# Kurulumdan önce!

git clone https://github.com/tugsatenes/ArchScript.git

cd ArchScript/

chmod +x main.sh

# Kurulum!

./main.sh

Arkanıza yaslanın ve 10-15dk bekleyin!

# Kurulum sonrası!

Yeni sisteminizde kullanmak için bir root parolasını girmeniz gerekli! Bunun için sadece aşağıdaki adımları uygulayın!

mount /dev/vda3 /mnt

arch-chroot /mnt

passwd yazıp enterlayın (↵) ve şifrenizi girin! (şifreniz gözükmeyecektir!!!)

exit

umount -R /mnt

reboot

# Yeni minimal Arch (btw) sisteminiz hazır!
