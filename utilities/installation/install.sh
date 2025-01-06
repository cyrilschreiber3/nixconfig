#! /usr/bin/env nix-shell
#! nix-shell -i bash -p git nano diffutils tmux qrencode

# Function to list available drives
list_drives() {
    echo "Available drives:"
    echo "----------------"
    lsblk -d -n -p -o NAME,SIZE,MODEL | grep -E "^/dev/(sd|nvme|vd)"
}

# Function to get current device from config
get_current_device() {
    local config_file=$1
    local device=$(grep -oP 'device = lib\.mkDefault "\K[^"]+' "$config_file")
    echo "$device"
}

# Function to validate device in config file
validate_config_device() {
    local config_file=$1
    local device=$(get_current_device "$config_file")
    
    if [[ ! -b "$device" ]]; then
        echo "Error: $device in config is not a valid block device"
        return 1
    fi
    return 0
}

# Main script
DEFAULT_DISKO_CONFIG="/tmp/nixconfig/hosts/scorpius-cl-01/disko.nix"
DEFAULT_HW_CONFIG="/tmp/nixconfig/hosts/scorpius-cl-01/hardware-configuration.nix"
GENERATED_HW_CONFIG="/mnt/etc/nixos/hardware-configuration.nix"

if [ "$#" -eq 0 ]; then
    CONFIG_FILE=$DEFAULT_DISKO_CONFIG
    echo "No config file specified, using default: $CONFIG_FILE"
elif [ "$#" -eq 1 ]; then
    CONFIG_FILE=$1
else
    echo "Usage: $0 [path-to-disko-config]"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file $CONFIG_FILE does not exist"
    exit 1
fi

# Clone the config repo if it doesn't exist
if [ ! -d /tmp/nixconfig ]; then
    cd /tmp
    echo "Downloading the config repository..."
    git clone https://github.com/cyrilschreiber3/nixconfig.git
    cd nixconfig
else 
    cd /tmp/nixconfig
    echo "Updating the config repository..."
    git pull
fi

# Show available drives
list_drives
echo

# Show current device
current_device=$(get_current_device "$CONFIG_FILE")
echo "Current device in config: $current_device"
echo

# Ask if user wants to change
read -p "Do you want to change the device? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Open file in nano
    nano "$CONFIG_FILE"
    
    # Validate the new configuration
    if validate_config_device "$CONFIG_FILE"; then
        echo "Configuration updated and validated successfully!"
        echo "New device: $(get_current_device "$CONFIG_FILE")"
    else
        echo "Warning: The new configuration contains an invalid device!"
        exit 1
    fi
else
    echo "No changes made to configuration."
fi

# Confirm formatting
echo
read -p "Do you want to format this drive? All data will be lost! (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Formatting the drive..."
    device=$(get_current_device "$CONFIG_FILE")
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount "$CONFIG_FILE"
    mount | grep /mnt
    echo "Drive formatted successfully!"
else
    echo "Drive not formatted."
    exit 1
fi

echo "Generating new hardware configuration..."
sudo nixos-generate-config --no-filesystems --root /mnt

echo "Here are the differences between the generated and current configurations:"
diff -u "$GENERATED_HW_CONFIG" "$DEFAULT_HW_CONFIG" | less

echo
echo "Would you like to:"
echo "1) Interactively merge configurations (recommended)"
echo "2) Keep generated configuration entirely"
echo "3) Keep current configuration entirely"
read -p "Choose an option (1-3): " choice

case $choice in
    1)
        echo "Starting interactive merge with tmux..."

        cp "$DEFAULT_HW_CONFIG" "$DEFAULT_HW_CONFIG.merge"
        
        # Create a new tmux session
        tmux new-session -d -s config_compare

        # Split the window horizontally
        tmux split-window -h

        # Send commands to each pane
        # Left pane: generated config
        tmux send-keys -t 0 "echo 'Tip: use CTRL + b o to change the focused pane'; echo; echo 'Generated config:'; echo '==========='; cat $GENERATED_HW_CONFIG" C-m
        
        # Right pane: current config
        tmux send-keys -t 1 "nano $DEFAULT_HW_CONFIG.merge" C-m
        
        # Attach to the session
        tmux -2 attach-session -t config_compare
        
        # Open vimdiff with three-way merge view
        diff -u "$GENERATED_HW_CONFIG" "$DEFAULT_HW_CONFIG.merge" | less
        
        if [ -f "$merge_config" ]; then
            echo "Would you like to:"
            echo "1) Keep changes"
            echo "2) Discard changes"
            read -p "Choose an option (1-2): " merge_choice
            
            case $merge_choice in
                1)
                    cp "$DEFAULT_HW_CONFIG.merge" "$DEFAULT_HW_CONFIG"
                    echo "Merged configuration saved."
                    ;;
                *)
                    echo "Merged changes discarded."
                    ;;
            esac
        fi
        ;;
    2)
        echo "Copying generated configuration..."
        cp "$GENERATED_HW_CONFIG" "$DEFAULT_HW_CONFIG"
        ;;
    3)
        echo "Keeping current configuration..."
        ;;
    *)
        echo "Invalid choice. Keeping new configuration..."
        ;;
esac

echo "Installing NixOS..."
sudo nixos-install --flake /tmp/nixconfig#scorpius-cl-01

echo "Setting initial password for main user..."
read -p "Enter the username for the main user: " username
nixos-enter --root /mnt -c "passwd $username"

echo "Creating ssh keys and showing QR code..."
nixos-enter --root /mnt -- su - $username -c "ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N '' && qrencode -t ANSI < ~/.ssh/id_ed25519.pub"

echo "Installation complete. You may now reboot."
