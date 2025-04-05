#! /usr/bin/env nix-shell
#! nix-shell -i bash -p libnotify mdevctl libvirt pciutils looking-glass-client

# while getopts "fugH:" flag; do
#     case $flag in
#     f) force=true ;;
#     u) update=true ;;
#     g) garbageCollect=true ;;
#     H) host=$OPTARG ;;
#     esac
# done

set -e

function handleExit() {
    notify-send -e "Could not start Merlin-CL-06" --icon=dialog-error
    exit 1
}

# Handle exit signals
trap handleExit SIGINT

if test "$SPECIALISATION" == "gaming"; then
    notify-send -e "Cannot start Merlin-CL-06 in Gaming specialisation" --icon=dialog-error
    exit 1
fi

if test "$(lspci | grep 01:00.0)" == ""; then
    notify-send -e "NVIDIA GPU not found" --icon=dialog-error
    exit 1
fi

if test "$(lspci | grep 40:00.0)" == ""; then
    notify-send -e "NVME SSD not found" --icon=dialog-error
    exit 1
fi

$MERLIN_STATUS= $(sudo virsh domstate Merlin-CL-06) || $MERLIN_STATUS = ""

if test "$MERLIN_STATUS" == ""; then
    notify-send -e "Merlin-CL-06 is not running" --icon=dialog-error
    exit 1
elif test "$MERLIN_STATUS" == "running"; then
    notify-send -e "Merlin-CL-06 is already running" --icon=dialog-error
    exit 1
fi

if test "$(mdevctl list | grep 1433f6b5-6ebf-4aa5-8733-938e68d00f18)" == ""; then
    echo "Creating vGPU..."
    # Create vGPU before starting VM
    sudo mdevctl start -u 1433f6b5-6ebf-4aa5-8733-938e68d00f18 -p 0000:01:00.0 --type nvidia-334
fi

# Start the VM
echo "Starting VM..."
sudo virsh start Merlin-CL-06 || (
    echo "Failed to start VM"
    handleExit
)

# Start Looking Glass
echo "Starting Looking Glass..."
looking-glass-client -d -F
