#!/bin/bash

# Ensure the script is run as root.
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

make

MODULE_NAME="i2c-ch341-usb"
KO_FILE="${MODULE_NAME}.ko"
MODULE_DIR="/lib/modules/$(uname -r)/extra"
MODULE_CONF_DIR="/etc/modules-load.d"
MODULE_CONF_FILE="${MODULE_CONF_DIR}/${MODULE_NAME}.conf"

# Create the extra modules directory if it doesn't exist.
mkdir -p "$MODULE_DIR"

# Copy the .ko file to the modules directory.
if [ -f "$KO_FILE" ]; then
    cp "$KO_FILE" "$MODULE_DIR"
    echo "Copied $KO_FILE to $MODULE_DIR"
else
    echo "Error: $KO_FILE not found in the current directory."
    exit 1
fi

# Update module dependencies.
depmod -a

# Create a config file to load the module on boot.
echo "$MODULE_NAME" >"$MODULE_CONF_FILE"
echo "Created $MODULE_CONF_FILE with module $MODULE_NAME to load at boot."

# Load the module immediately.
modprobe "$MODULE_NAME"
echo "Module $MODULE_NAME loaded successfully."

echo "Module installation complete. $MODULE_NAME will load automatically on boot."
