.DEFAULT_GOAL := build

# === Variables ===

# Default architecture
ARCH ?= x86_64

# Defconfig name
DEFCONFIG = NexisOS_$(ARCH)_defconfig

# Paths
BUILDROOT_VERSION = 2025.xx.xx
BUILDROOT_DIR = buildroot
CONFIG_FILE = depends/configs/$(DEFCONFIG)
DEPS_DIR = depends
PKG_MANAGER_DIR = $(DEPS_DIR)/package_manager
SCRIPTS_DIR = $(DEPS_DIR)/scripts

# === Targets ===

.PHONY: fetch-buildroot
fetch-buildroot:
	@if [ ! -d $(BUILDROOT_DIR) ]; then \
		echo "Cloning Buildroot..."; \
		git clone --depth 1 --branch $(BUILDROOT_VERSION) https://git.buildroot.org/buildroot.git $(BUILDROOT_DIR); \
	else \
		echo "Buildroot already exists."; \
	fi

.PHONY: validate
validate:
	@if [ ! -f $(CONFIG_FILE) ]; then \
		echo "ERROR: Architecture '$(ARCH)' not supported or config file missing."; \
		echo "Valid options are:"; \
		ls depends/configs/NexisOS_*_defconfig | sed 's/.*NexisOS_\(.*\)_defconfig/\1/' | xargs -n1 echo " -"; \
		exit 1; \
	fi

.PHONY: prepare
prepare: fetch-buildroot validate
	@echo "Preparing buildroot with defconfig: $(DEFCONFIG)"
	mkdir -p $(BUILDROOT_DIR)/configs/
	cp $(CONFIG_FILE) $(BUILDROOT_DIR)/configs/

	@echo "Copying package manager and scripts..."
	mkdir -p $(BUILDROOT_DIR)/package/nexisos/
	cp -r $(PKG_MANAGER_DIR) $(BUILDROOT_DIR)/package/nexisos/
	cp -r $(SCRIPTS_DIR) $(BUILDROOT_DIR)/package/nexisos/

.PHONY: build
build: prepare
	@echo "Running Buildroot with $(DEFCONFIG)..."
	$(MAKE) -C $(BUILDROOT_DIR) $(DEFCONFIG)
	$(MAKE) -C $(BUILDROOT_DIR)

.PHONY: clean
clean:
	$(MAKE) -C $(BUILDROOT_DIR) clean

.PHONY: distclean
distclean: clean
	rm -rf $(BUILDROOT_DIR)

.PHONY: help
help:
	@echo "NexisOS Makefile Commands:"
	@echo ""
	@echo "  make [ARCH=arch]     Build image for specified arch (default: x86_64)"
	@echo "  make clean           Clean build output"
	@echo "  make distclean       Remove buildroot entirely"
	@echo "  make prepare         Prepare buildroot with configs and dependencies"
	@echo "  make fetch-buildroot Clone buildroot if not already present"
	@echo "  make help            Show this help message"
	@echo ""
	@echo "Available architectures:"
	@ls depends/configs/NexisOS_*_defconfig | sed 's/.*NexisOS_\(.*\)_defconfig/\1/' | xargs -n1 echo " -"
