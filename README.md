# debianUSBflashSwapSetup
Script to automatically set up a USB flash drive as swap on debian with failback 


How to use this script:
* Run the script as root: Execute it with sudo ./autoUSBswapSetup.sh
* Follow the prompts: Unplug your USB drive, plug it back in, and let the script handle the rest.
* This script captures the UUID of your USB drive by comparing the state of block devices before and after you plug the drive in. It then creates a udev rule and a management script to handle the swap dynamically based on the drive's presence. Ensure the device path /dev/disk/by-uuid/$ID_FS_UUID in the script matches your system's configuration; this is a universal approach that should work across different Linux systems.
