.DEFAULT_GOAL := build

# === Variables ===

ARCH ?= x86_64
DEFCONFIG := NexisOS_$(ARCH)_defconfig
CONFIG_FILE := $(abspath depends/configs/$(DEFCONFIG))
KERNEL_CONFIG := $(abspath depends/kernel-configs/linux-$(ARCH).config)
BUILDROOT_VERSION := 2025.xx.xx
BUILDROOT_DIR := ../buildroot
OUTPUT_DIR := output-$(ARCH)

BACKUP_CONFIG := $(BUILDROOT_DIR)/package/Config.in.bak
BUILDROOT_CONFIG := $(BUILDROOT_DIR)/package/Config.in

# === Targets ===

.PHONY: fetch-buildroot
fetch-buildroot:
	@if [ ! -d $(BUILDROOT_DIR) ]; then \
		echo "Cloning Buildroot $(BUILDROOT_VERSION)..."; \
		git clone --depth 1 --branch $(BUILDROOT_VERSION) https://git.buildroot.org/buildroot.git $(BUILDROOT_DIR); \
	else \
		echo "Buildroot already exists at $(BUILDROOT_DIR)."; \
	fi

.PHONY: validate-kernel-config
validate-kernel-config:
	@if [ ! -f $(KERNEL_CONFIG) ]; then \
		echo "ERROR: Kernel config file missing for architecture '$(ARCH)': $(KERNEL_CONFIG)"; \
		exit 1; \
	fi

.PHONY: validate
validate: validate-kernel-config
	@if [ ! -f $(CONFIG_FILE) ]; then \
		echo "ERROR: Architecture '$(ARCH)' defconfig missing: $(CONFIG_FILE)"; \
		echo "Valid options are:"; \
		ls depends/configs/NexisOS_*_defconfig | sed 's/.*NexisOS_\(.*\)_defconfig/\1/' | xargs -n1 echo " -"; \
		exit 1; \
	fi

.PHONY: prepare
prepare: fetch-buildroot validate
	@echo "Ready to configure Buildroot for $(ARCH)"

.PHONY: copy-kernel-config
copy-kernel-config: validate-kernel-config
	@mkdir -p $(BUILDROOT_DIR)/board/nexisos
	@cp $(KERNEL_CONFIG) $(BUILDROOT_DIR)/board/nexisos/
	@echo "Copied kernel config for $(ARCH) to Buildroot board/nexisos"

.PHONY: copy-nexpm-package
copy-nexpm-package:
	@mkdir -p $(BUILDROOT_DIR)/package/nexpm
	@cp depends/package/nexpm/nexpm.mk $(BUILDROOT_DIR)/package/nexpm/
	@cp depends/package/nexpm/Config.in $(BUILDROOT_DIR)/package/nexpm/
	@echo "Copied nexpm package files to Buildroot package directory"

.PHONY: patch-config
patch-config:
	@if ! grep -Fq "# Begin nexpm Config.in patch" $(BUILDROOT_CONFIG) 2>/dev/null; then \
		if [ ! -f $(BACKUP_CONFIG) ]; then \
			cp $(BUILDROOT_CONFIG) $(BACKUP_CONFIG); \
		fi; \
		echo "# Begin nexpm Config.in patch" >> $(BUILDROOT_CONFIG); \
		cat depends/package/Config.in >> $(BUILDROOT_CONFIG); \
		echo "# End nexpm Config.in patch" >> $(BUILDROOT_CONFIG); \
		echo "Appended nexpm Config.in to Buildroot package/Config.in"; \
	else \
		echo "nexpm Config.in patch already applied to Buildroot package/Config.in"; \
	fi

.PHONY: restore-config
restore-config:
	@if [ -f $(BACKUP_CONFIG) ]; then \
		mv $(BACKUP_CONFIG) $(BUILDROOT_CONFIG); \
		echo "Restored original Buildroot package/Config.in"; \
	fi

.PHONY: cleanup
cleanup:
	@rm -rf $(BUILDROOT_DIR)/package/nexpm
	$(MAKE) restore-config
	@echo "Cleaned up copied nexpm package files and restored Buildroot config"

.PHONY: build
build: prepare copy-kernel-config copy-nexpm-package patch-config
	@echo "Building NexisOS for $(ARCH)..."
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) BR2_DEFCONFIG=$(CONFIG_FILE) defconfig -j$(shell nproc)
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) -j$(shell nproc)
	$(MAKE) cleanup

.PHONY: clean
clean:
	@if [ -d $(BUILDROOT_DIR) ]; then \
		$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) clean; \
	fi

.PHONY: distclean
distclean: clean
	@rm -rf $(OUTPUT_DIR) $(BACKUP_CONFIG)
	@echo "Removed output directory and backup config"

.PHONY: help
help:
	@echo "NexisOS Makefile Commands:"
	@echo ""
	@echo "  make [ARCH=arch]     Build image for specified arch (default: x86_64)"
	@echo "  make clean           Clean build output for selected arch"
	@echo "  make distclean       Remove output directory for selected arch and backup config"
	@echo "  make fetch-buildroot Download Buildroot (into ../buildroot)"
	@echo ""
	@echo "Available architectures:"
	@ls depends/configs/NexisOS_*_defconfig | sed 's/.*NexisOS_\(.*\)_defconfig/\1/' | xargs -n1 echo " -"
