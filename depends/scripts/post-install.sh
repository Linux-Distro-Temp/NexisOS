#!/bin/bash

# Helper function for error handling
function error_exit {
    echo "Error: $1"
    exit 1
}

# Step 1: Set up directories and permissions
echo "Setting up necessary directories..."

# Ensure /etc/NexisOS exists (this will store your TOML configuration files)
if [ ! -d "/etc/NexisOS" ]; then
    mkdir -p /etc/NexisOS || error_exit "Failed to create /etc/NexisOS"
fi

# Set appropriate permissions for the directory
chmod 755 /etc/NexisOS

# Step 2: Copy the default configuration file (TOML format)
echo "Setting up default configuration files..."

# Assuming we have a template configuration file stored in /usr/share/nexis/config.toml
if [ -f "/usr/share/nexis/config.toml" ]; then
    cp /usr/share/nexis/config.toml /etc/NexisOS/config.toml || error_exit "Failed to copy configuration file"
else
    echo "Warning: Default config.toml not found, skipping."
fi

# Set permissions for the configuration file
chmod 644 /etc/NexisOS/config.toml

# Step 3: Install essential system packages (using your custom Rust-based package manager)
echo "Installing essential system packages..."

# Example: Install a package called "core-tools" using your package manager (adjust the command for your package manager)
nexis-pkg install core-tools || error_exit "Failed to install core-tools"

# Step 4: Set up users and groups (if necessary)
echo "Setting up system users and groups..."

# Example: Creating a system user for running services
if ! id "nexisuser" &>/dev/null; then
    useradd -r -m -s /bin/bash nexisuser || error_exit "Failed to create user nexisuser"
    echo "User nexisuser created successfully"
fi

# Step 5: Set up system services
echo "Setting up system services..."

# Assuming your package manager has a way to register services with systemd or another init system
# Example: Enable and start a service called "nexis-service"
systemctl enable nexis-service || error_exit "Failed to enable nexis-service"
systemctl start nexis-service || error_exit "Failed to start nexis-service"

# Step 6: Handle dependency resolution (preventing dependency hell)
echo "Handling dependencies..."

# Assuming you have a custom tool to resolve and install dependencies in a non-conflicting manner
nexis-pkg resolve-deps || error_exit "Failed to resolve dependencies"

# Step 7: Clean up temporary files
echo "Cleaning up temporary installation files..."

# Remove installation leftovers, logs, or temporary files created during installation
rm -rf /tmp/nexis-install || error_exit "Failed to clean temporary files"

# Step 8: Finalizing installation (optional tasks like database setup)
echo "Finalizing installation tasks..."

# Example: Running a database migration script or any final setup steps
nexis-setup --finalize || error_exit "Failed to complete final setup"

# Step 9: Log installation success
echo "Installation completed successfully" >> /var/log/nexis-install.log

# Step 10: Notify user (optional)
echo "Installation of NexisOS is complete! Please reboot your system."

# End of script
