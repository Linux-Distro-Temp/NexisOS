# NexisOS
Main repo for distro

## Possible Directory Layout
NexisOS/
├── buildroot/ # Official Buildroot source tree (cloned)
│ ├── package/ # Buildroot packages (includes dialog)
│ │ ├── dialog/ # dialog package directory
│ │ │ ├── Config.in # Buildroot package config for dialog
│ │ │ ├── dialog.mk # Buildroot package Makefile for dialog
│ │ │ └── ... # Other package files (patches, etc.)
│ │ ├── busybox/
│ │ ├── ...
│ ├── configs/ # Buildroot configuration files (.config, defconfigs)
│ ├── output/ # Build output files (ISO, rootfs, kernel, etc.)
│ ├── board/ # Board support packages (optional)
│ └── ... # Other Buildroot files and directories
│
├── board/<your_board>/ # Board-specific files and overlays
│ └── rootfs_overlay/ # Files to include in root filesystem
│ ├── usr/bin/install.sh # Installer script (uses dialog)
│ └── etc/systemd/system/ # Optional systemd service files
│
├── scripts/ # Development scripts (e.g. install.sh using dialog)
│
├── package_manager/ # Custom packages or external Buildroot packages
│
├── configs/ # Custom Buildroot defconfig files
│
├── README.md
├── LICENSE
└── .gitignore
