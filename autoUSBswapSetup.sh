#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

echo "Please unplug the flash drive if it is currently plugged in, then press ENTER."
read -r

# Take a snapshot of currently connected drives
before=$(lsblk -o UUID)

echo "Now, plug in the USB flash drive and press ENTER."
read -r

# Take a snapshot after the drive is connected
after=$(lsblk -o UUID)

# Compare snapshots to find the UUID of the new drive
uuid=$(comm -13 <(echo "$before") <(echo "$after"))

if [ -z "$uuid" ]; then
    echo "No new USB drive detected. Exiting."
    exit 1
fi

# Confirmation of detected drive
echo "Detected USB drive with UUID: $uuid"
echo "Setting up swap configuration..."

# Create the udev rule
udev_rule_path="/etc/udev/rules.d/90-usb-swap.rules"
echo "Creating udev rule at $udev_rule_path"
cat <<EOT > "$udev_rule_path"
ACTION=="add", ENV{ID_FS_UUID}=="$uuid", RUN+="/usr/local/bin/usb-swap.sh add"
ACTION=="remove", ENV{ID_FS_UUID}=="$uuid", RUN+="/usr/local/bin/usb-swap.sh remove"
EOT

# Create the swap script
swap_script_path="/usr/local/bin/usb-swap.sh"
echo "Creating swap management script at $swap_script_path"
cat <<'EOS' > "$swap_script_path"
#!/bin/bash
USB_SWAP="/dev/disk/by-uuid/$ID_FS_UUID"

case "$1" in
    add)
        echo "Adding swap on $USB_SWAP..."
        swapoff "$USB_SWAP" 2>/dev/null
        mkswap "$USB_SWAP"
        swapon "$USB_SWAP"
        ;;
    remove)
        echo "Removing swap from $USB_SWAP..."
        swapoff "$USB_SWAP"
        ;;
    *)
        echo "Usage: /usr/local/bin/usb-swap.sh {add|remove}"
        exit 1
esac
exit 0
EOS

chmod +x "$swap_script_path"

# Reload udev rules
echo "Reloading udev rules..."
udevadm control --reload-rules
udevadm trigger

echo "Setup complete. You can now use your USB flash drive as swap space when plugged in."
