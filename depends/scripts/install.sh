#!/bin/sh
set -e

# Root check
[ "$(id -u)" -eq 0 ] || { echo "Must run as root" >&2; exit 1; }

whiptail --msgbox "Welcome to NexisOS Installer" 6 40

DISK=$(whiptail --title "Disk Selection" --menu "Select disk" 15 50 4 \
  /dev/sda "Primary Disk" /dev/sdb "Secondary Disk" /dev/nvme0n1 "NVMe SSD" 3>&1 1>&2 2>&3)

KERNEL_TYPE=$(whiptail --title "Kernel" --menu "Select kernel" 10 40 2 \
  vanilla "Vanilla Kernel" hardened "Hardened Kernel" 3>&1 1>&2 2>&3)

DE_TYPE=$(whiptail --title "Desktop Env" --menu "Choose DE / WM" 15 50 5 \
  i3 "i3 WM" xfce "XFCE DE" gnome "GNOME DE" none "No GUI" 3>&1 1>&2 2>&3)

if ! whiptail --yesno "Install NexisOS on $DISK with:\nKernel: $KERNEL_TYPE\nDE: $DE_TYPE\nProceed?" 10 50; then
  whiptail --msgbox "Installation cancelled." 5 40
  exit 0
fi

MNT="/mnt/nexisos"
STEP=0

progress() {
  echo "XXX"
  echo "$1"
  echo "XXX"
  echo "$2"
}

(
progress "Partitioning disk..." $((STEP+=15))
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart primary ext4 1MiB 100%
PART="${DISK}1"
sleep 1

progress "Formatting partition..." $((STEP+=15))
mkfs.ext4 "$PART"

progress "Mounting partition..." $((STEP+=5))
mkdir -p "$MNT"
mount "$PART" "$MNT"

progress "Extracting base system..." $((STEP+=20))
tar -xzf /nexis/rootfs.tar.gz -C "$MNT"

progress "Installing $KERNEL_TYPE kernel..." $((STEP+=10))
cp "/nexis/kernels/${KERNEL_TYPE}-vmlinuz" "$MNT/boot/vmlinuz"

progress "Installing init system..." $((STEP+=10))
tar -xzf /nexis/init/dinit.tar.gz -C "$MNT"
ln -sf /dinit/dinit "$MNT/init"

progress "Installing Desktop Environment..." $((STEP+=20))
chroot "$MNT" /bin/sh -c "
  nexpkg update
  case $DE_TYPE in
    i3) nexpkg install i3 i3status i3lock ;;
    xfce) nexpkg install xfce lightdm ;;
    gnome) nexpkg install gnome gdm ;;
    none) echo 'No GUI selected.' ;;
  esac
"

progress "Installing GRUB bootloader..." $((STEP+=10))
grub-install --target=i386-pc --boot-directory="$MNT/boot" "$DISK"

cat > "$MNT/boot/grub/grub.cfg" <<EOF
set default=0
set timeout=5

menuentry "NexisOS" {
    linux /boot/vmlinuz
    initrd /boot/initrd.img
}
EOF

progress "Finishing installation..." 100

) | whiptail --title "Installing NexisOS..." --gauge "Please wait..." 10 60 0

whiptail --msgbox "Installation complete! Rebooting now." 6 40
reboot
