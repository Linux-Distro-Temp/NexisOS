# NexisOS
Main repo for distro

## 📁 Possible Directory Layout

<details>
<summary>Click to see possible directory structure</summary>

```text
NexisOS/
├── buildroot/                  # Official Buildroot source tree (cloned)
│   ├── package/                # Buildroot packages (includes dialog)
│   │   ├── dialog/             # dialog package directory
│   │   │   ├── Config.in       # Buildroot package config for dialog
│   │   │   ├── dialog.mk       # Buildroot package Makefile for dialog
│   │   │   └── ...             # Other package files (patches, etc.)
│   │   ├── busybox/
│   │   ├── ...
│   ├── configs/                # Buildroot configuration files (.config, defconfigs)
│   ├── output/                 # Build output files (ISO, rootfs, kernel, etc.)
│   ├── board/                  # Board support packages (optional)
│   └── ...                     # Other Buildroot files and directories
│
├── board/<your_board>/         # Board-specific files and overlays
│   └── rootfs_overlay/         # Files to include in root filesystem
│       ├── usr/bin/install.sh  # Installer script (uses dialog)
│       └── etc/systemd/system/ # Optional systemd service files
│
├── scripts/                    # Development scripts (e.g. install.sh using dialog)
│
├── package_manager/            # Custom package manager source code
│   ├── Cargo.toml              # Rust project manifest
│   └── src/                    # Rust source files
│       ├── cli.rs
│       ├── config.rs
│       ├── main.rs
│       ├── manifest.rs
│       ├── packages.rs
│       ├── rollback.rs
│       ├── store.rs
│       ├── types.rs
│       └── util.rs
│
├── configs/                    # Custom Buildroot defconfig files
│
├── README.md
├── LICENSE
└── .gitignore
```

</details>

##  ⚙️ Possible toml config

<details>
<summary>Click to see possible TOML config example</summary>

```text
[system]
hostname = "myhost"
timezone = "UTC"
version = "0.1.0"               # System release version
kernel = "linux-6.9.2"          # Kernel version or build target (from package repo or tarball)
kernel_source = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.9.2.tar.xz"
kernel_config = "configs/kernel-default.config"  # Optional path to a custom .config

[users.root]
password_hash = "..."  # SHA512 crypt

[includes]
paths = [
  "packages/hardware.toml",
  "packages/editors.toml",
  "packages/devtools.toml"
]

[[packages]]
name = "vim"
version = "9.0"
prebuilt = "https://cdn.mydistro.org/vim-9.0-x86_64.tar.gz"
context_file = "contexts/vim.cil"

[[packages]]
name = "libpng"
version = "1.6.40"
source = "https://download.sourceforge.net/libpng/libpng-1.6.40.tar.gz"
hash = "sha256:abc123..."
build_system = "configure"
build_flags = ["--enable-static"]
dependencies = ["zlib"]
# build_profile removed; inferred automatically

[config_files.suricata]
path = "/etc/suricata/suricata.yaml"
source = "templates/suricata.yaml.tpl"
owner = "root"
group = "root"
mode = "0640"
variables = { rule_path = "/var/lib/suricata/rules", detect_threads = 4 }

[config_files.ansible]
path = "/etc/ansible/ansible.cfg"
source = "templates/ansible.cfg.tpl"
owner = "root"
group = "root"
mode = "0644"
variables = { inventory = "/etc/ansible/hosts" }

[config_files.clamav]
path = "/etc/clamav/clamd.conf"
source = "templates/clamd.conf.tpl"
owner = "clamav"
group = "clamav"
mode = "0640"
variables = { database_dir = "/var/lib/clamav" }

[dinit_services.network]
name = "network"
type = "scripted"
command = "/etc/dinit.d/network.sh"
depends = []
start_timeout = 20

[dinit_services.sshd]
name = "sshd"
type = "process"
command = "/usr/sbin/sshd"
depends = ["network"]
working_directory = "/"
log_file = "/var/log/sshd.log"
restart = "true"
```

</details>
