# File Replacement and Backup Utility

## Overview
This bash script provides a safe and automated way to replace the contents of a target configuration file. Before any modifications are made, it ensures that you have reliable backups to fall back on in case of errors. 

## Features
- **Privilege Checking:** Ensures the script is run with `root` privileges.
- **Argument Validation:** Verifies that exactly two arguments are provided and that both files exist.
- **Dual Backup System:** 
  - Creates a compressed archive (`.tar.gz`) of the original file.
  - Creates a direct copy (`.rollback`) for immediate restoration if needed.
- **Atomic-style Replacement:** Safely overwrites the target file with the contents of the replacement file.

## Usage

Run the script by providing the target file to be modified, followed by the file containing the new content.

```bash
sudo ./replace_file.sh <target_file> <replacement_file>
```

### Example
```bash
sudo ./replace_file.sh /etc/chrony.conf ./chrony.fix.txt
```

## Rollback Instructions
If the new configuration causes issues, you can easily restore the original file using the generated `.rollback` copy.

```bash
sudo cp /etc/chrony.conf.rollback /etc/chrony.conf
```
*(Replace `/etc/chrony.conf` with your actual target file path).*
