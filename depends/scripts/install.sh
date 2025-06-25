#!/bin/sh

# Ensure root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!" 1>&2
    exit 1
fi

# Welcome message
dialog --msgbox "Welcome to NexisOS Installer" 6 40

# Select disk for installation
DISK=$(dialog --stdout --menu "Select the disk to install NexisOS" 15 50 4 \
  /dev/sda "Disk 1 (Primary)" \
  /dev/sdb "Disk 2 (Secondary)" \
  /dev/sdc "Disk 3 (External)" \
  /dev/nvme0n1 "NVMe SSD")

# Partition the disk (using `fdisk` or `parted`)
dialog --infobox "Partitioning the disk..." 3 30
echo -e "o\nn\np\n1\n\n\nw" | fdisk $DISK

# Format the new partition to ext4
dialog --infobox "Formatting the partition..." 3 30
mkfs.ext4 ${DISK}1

# Mount the new partition
MOUNT_DIR="/mnt/nexisos"
mkdir -p $MOUNT_DIR
mount ${DISK}1 $MOUNT_DIR

# Download the root filesystem (optional - if you want to fetch a tarball)
dialog --infobox "Downloading the root filesystem..." 3 40
wget -O $MOUNT_DIR/rootfs.tar.gz http://your-server-ip/rootfs.tar.gz

# Extract the root filesystem
dialog --infobox "Extracting the root filesystem..." 3 40
tar -xzf $MOUNT_DIR/rootfs.tar.gz -C $MOUNT_DIR

# Kernel selection: Vanilla or Hardened?
KERNEL_TYPE=$(dialog --stdout --menu "Select the Kernel" 15 50 2 \
  vanilla "Vanilla Kernel" \
  hardened "Hardened Kernel")

case $KERNEL_TYPE in
    vanilla)
        dialog --infobox "Installing Vanilla Kernel..." 3 30
        wget -O $MOUNT_DIR/boot/vmlinuz http://your-server-ip/vanilla-vmlinuz
        ;;
    hardened)
        dialog --infobox "Installing Hardened Kernel..." 3 30
        wget -O $MOUNT_DIR/boot/vmlinuz http://your-server-ip/hardened-vmlinuz
        ;;
    *)
        dialog --msgbox "Invalid option selected, exiting installer." 6 40
        exit 1
        ;;
esac

# Install dinit (the init system)
dialog --infobox "Installing dinit..." 3 30
wget -O $MOUNT_DIR/dinit.tar.gz http://your-server-ip/dinit.tar.gz

# Extract dinit
tar -xzf $MOUNT_DIR/dinit.tar.gz -C $MOUNT_DIR

# Create symlink for dinit to be the init system
ln -s /dinit/dinit /mnt/nexisos/init

# Window Manager or Desktop Environment Selection
DE_TYPE=$(dialog --stdout --menu "Select your Window Manager or Desktop Environment" 15 50 4 \
  i3 "i3 (Window Manager)" \
  openbox "Openbox (Window Manager)" \
  xfce "Xfce (Desktop Environment)" \
  gnome "GNOME (Desktop Environment)" \
  kde "KDE Plasma (Desktop Environment)")

case $DE_TYPE in
    i3)
        dialog --infobox "Installing i3 Window Manager..." 3 30
        # Install i3 and required packages
        apt-get install -y i3 i3status i3lock
        ;;
    openbox)
        dialog --infobox "Installing Openbox Window Manager..." 3 30
        # Install Openbox and required packages
        apt-get install -y openbox obconf tint2
        ;;
    xfce)
        dialog --infobox "Installing Xfce Desktop Environment..." 3 30
        # Install XFCE and required packages
        apt-get install -y xfce4 xfce4-goodies lightdm
        ;;
    gnome)
        dialog --infobox "Installing GNOME Desktop Environment..." 3 30
        # Install GNOME and required packages
        apt-get install -y gnome-shell gdm3
        ;;
    kde)
        dialog --infobox "Installing KDE Plasma Desktop Environment..." 3 30
        # Install KDE Plasma and required packages
        apt-get install -y kde-plasma-desktop sddm
        ;;
    *)
        dialog --msgbox "Invalid option selected, exiting installer." 6 40
        exit 1
        ;;
esac

# Install the bootloader (GRUB or Syslinux)
dialog --infobox "Installing bootloader..." 3 30
grub-install --target=i386-pc --boot-directory=$MOUNT_DIR/boot $DISK

# Create the GRUB configuration
cat > $MOUNT_DIR/boot/grub/grub.cfg <<EOF
set default=0
set timeout=5

menuentry "NexisOS" {
    linux /boot/vmlinuz
    initrd /boot/initrd.img
}
EOF

# Finalize installation
dialog --msgbox "Installation complete! Please reboot." 6 40
reboot
