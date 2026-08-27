#!/bin/bash

# Function to display usage instructions
show_usage() {
    echo "Usage: $0 <target_file> <replacement_file>"
    echo "Backs up <target_file> and replaces its contents with <replacement_file>."
    echo ""
    echo "Arguments:"
    echo "  <target_file>      The file to be backed up and modified (e.g., /etc/chrony.conf)"
    echo "  <replacement_file> The file containing the new content (e.g., chrony.fix.txt)"
    echo ""
    echo "Example:"
    echo "  $0 /etc/chrony.conf ./chrony.fix.txt"
}

# Show help if the script is run empty or with help flags
if [[ "$#" -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Require exactly 2 arguments for execution
if [[ "$#" -ne 2 ]]; then
    echo "Error: Incorrect number of arguments."
    echo ""
    show_usage
    exit 1
fi

# Ensure script is run as root before proceeding with modifications
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root." 
   exit 1
fi

TARGET_FILE=$1
FIX_FILE=$2

# Validate that both files exist before proceeding
if [[ ! -f "$TARGET_FILE" ]]; then
    echo "Error: Target file '$TARGET_FILE' not found."
    exit 1
fi

if [[ ! -f "$FIX_FILE" ]]; then
    echo "Error: Replacement file '$FIX_FILE' not found."
    exit 1
fi

echo "--- 1. Backing up $TARGET_FILE ---"
# Create a tar archive of the target file
tar -czvf "${TARGET_FILE}.tar.gz" "$TARGET_FILE"
# Create a direct reference copy for rollback
cp "$TARGET_FILE" "${TARGET_FILE}.rollback"
echo "Backups created at ${TARGET_FILE}.tar.gz and ${TARGET_FILE}.rollback"

echo "--- 2. Replacing content of $TARGET_FILE ---"
# Overwrite the target file with the contents of the replacement file
cat "$FIX_FILE" > "$TARGET_FILE"
echo "Success: Content of $TARGET_FILE has been replaced with $FIX_FILE."
