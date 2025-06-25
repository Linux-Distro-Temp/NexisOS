# NexisOS
Main repository for the NexisOS Linux distribution, containing core build infrastructure, package manager source, configuration examples, and tooling.

---

## 🔽 Download ISO

You can try the latest ISO build of NexisOS by downloading it from SourceForge:

👉 [Download NexisOS ISO](https://sourceforge.net/projects/nexisos/files/latest/download)

> ⚠️ *Note: The ISO is currently experimental and intended for testing and feedback. Expect rapid iteration and updates.*

---

## 📁 Possible Directory Layout

<details>
<summary>Click to see possible directory structure</summary>

```text
NexisOS/
├── buildroot/                # Buildroot source tree
│   ├── board/
│   │   └── nexisos/
│   │       ├── install.sh    # Installer script (uses dialog)
│   │       └── post-build.sh # Hook to modify final image
│   ├── configs/
│   │   └── NexisOS_defconfig # Minimal config to build NexisOS ISO
│   └── ...                   # Other Buildroot internals
│
├── package_manager/          # NexisOS package manager (Rust)
│   ├── Cargo.toml
│   └── src/
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
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── SECURITY.md
└── VERSION
```

</details>

## 🛠️ Build the NexisOS ISO
To build the ISO using one of the provided Buildroot defconfig files:
```sh
cd buildroot
make BR2_DEFCONFIG=configs/NexisOS_defconfig defconfig
make
```

After the build completes, the ISO and related images will be located in:
```sh
ls output/images
```

## ⚙️ Possible toml config

<details>
<summary>Click to see possible TOML config example</summary>

```toml
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
