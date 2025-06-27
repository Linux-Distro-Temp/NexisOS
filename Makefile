.DEFAULT_GOAL := build

# === Variables ===

ARCH ?= x86_64
DEFCONFIG := NexisOS_$(ARCH)_defconfig
CONFIG_FILE := $(abspath depends/configs/$(DEFCONFIG))
KERNEL_CONFIG := $(abspath depends/kernel-configs/linux-$(ARCH).config)
BUILDROOT_VERSION := 2025.xx.xx
BUILDROOT_DIR := ../buildroot
OUTPUT_DIR := output-$(ARCH)

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

.PHONY: build
build: prepare copy-kernel-config
	@echo "Building NexisOS for $(ARCH)..."
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) BR2_DEFCONFIG=$(CONFIG_FILE) defconfig
	$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR)

.PHONY: clean
clean:
	@if [ -d $(BUILDROOT_DIR) ]; then \
		$(MAKE) -C $(BUILDROOT_DIR) O=$(OUTPUT_DIR) clean; \
	fi

.PHONY: distclean
distclean:
	rm -rf $(OUTPUT_DIR)

.PHONY: help
help:
	@echo "NexisOS Makefile Commands:"
	@echo ""
	@echo "  make [ARCH=arch]     Build image for specified arch (default: x86_64)"
	@echo "  make clean           Clean build output for selected arch"
	@echo "  make distclean       Remove output directory for selected arch"
	@echo "  make fetch-buildroot Download Buildroot (into ../buildroot)"
	@echo ""
	@echo "Available architectures:"
	@ls depends/configs/NexisOS_*_defconfig | sed 's/.*NexisOS_\(.*\)_defconfig/\1/' | xargs -n1 echo " -"
