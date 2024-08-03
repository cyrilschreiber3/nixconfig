#!/bin/bash

# Set the path to your config directory
CONFIG_DIR="./../../modules/dotfiles/cinnamon/"

# Set the output file path
OUTPUT_FILE="$CONFIG_DIR/directory_structure.json"

# Function to process a directory
process_directory() {
    local dir="$1"
    local prefix="$2"
    local first_entry="$3"
    
    for entry in "$dir"/*; do
        if [ -d "$entry" ]; then
            local dirname=$(basename "$entry")
            if [ "$first_entry" = "false" ]; then
                echo "," >> "$OUTPUT_FILE"
            fi
            echo -n "$prefix\"$dirname\": {" >> "$OUTPUT_FILE"
            process_directory "$entry" "$prefix  " "true"
            echo -n "$prefix}" >> "$OUTPUT_FILE"
            first_entry="false"
        elif [ -f "$entry" ] && [[ "$entry" == *.json ]]; then
            local filename=$(basename "$entry")
            if [ "$first_entry" = "false" ]; then
                echo "," >> "$OUTPUT_FILE"
            fi
            echo -n "$prefix\"$filename\": true" >> "$OUTPUT_FILE"
            first_entry="false"
        fi
    done
}

# Start the JSON file
echo "{" > "$OUTPUT_FILE"

# Process the config directory
process_directory "$CONFIG_DIR" "  " "true"

# Close the JSON file
echo -e "\n}" >> "$OUTPUT_FILE"

echo "Directory structure has been written to $OUTPUT_FILE"