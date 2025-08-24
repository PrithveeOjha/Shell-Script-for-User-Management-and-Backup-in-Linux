#!/bin/bash

# This is a simple shell script for user management and backup in Linux.
# --- Functions ---

# Function to add a new user
add_user() {
    echo "--- Add New User ---"
    read -p "Enter username: " USERNAME
    read -p "Enter full name (optional): " FULLNAME

    # Check if username is empty
    if [ -z "$USERNAME" ]; then
        echo "Error: Username cannot be empty."
        return 1 # Exit function with an error status
    fi

    # Check if user already exists
    if id "$USERNAME" &>/dev/null; then
        echo "Error: User '$USERNAME' already exists."
        return 1
    fi

    # Add the user.
    # -m: creates home directory
    # -c "$FULLNAME": adds a comment (full name)
    # -s /bin/bash: sets default shell to Bash
    sudo useradd -m -c "$FULLNAME" -s /bin/bash "$USERNAME"

    # Check the exit status of the previous command (`useradd`)
    if [ $? -eq 0 ]; then
        echo "User '$USERNAME' added successfully."
        # Set password for the new user
        echo "Setting password for '$USERNAME'..."
        sudo passwd "$USERNAME" # Prompts for password twice
    else
        echo "Failed to add user '$USERNAME'."
    fi
}

# Function to delete a user
delete_user() {
    echo "--- Delete User ---"
    read -p "Enter username to delete: " USERNAME

    if [ -z "$USERNAME" ]; then
        echo "Error: Username cannot be empty."
        return 1
    fi

    # Check if user exists
    if ! id "$USERNAME" &>/dev/null; then # `! id` checks if user does NOT exist
        echo "Error: User '$USERNAME' does not exist."
        return 1
    fi

    # Delete the user.
    # -r: removes the user's home directory and mail spool
    sudo userdel -r "$USERNAME"

    if [ $? -eq 0 ]; then
        echo "User '$USERNAME' deleted successfully."
    else
        echo "Failed to delete user '$USERNAME'."
    fi
}

# Function to create a simple backup
create_backup() {
    echo "--- Create Backup ---"
    read -p "Enter directory to backup (e.g., /home/youruser/documents): " SOURCE_DIR
    read -p "Enter backup destination directory (e.g., /var/backups): " DEST_DIR

    # Check if source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then # `-d` checks if it's a directory
        echo "Error: Source directory '$SOURCE_DIR' does not exist."
        return 1
    fi

    # Create destination directory if it doesn't exist
    if [ ! -d "$DEST_DIR" ]; then
        sudo mkdir -p "$DEST_DIR" # `-p` creates parent directories if needed
        if [ $? -ne 0 ]; then # Check if mkdir failed
            echo "Error: Failed to create destination directory '$DEST_DIR'."
            return 1
        fi
    fi

    # Generate a timestamp for the backup filename
    TIMESTAMP=$(date +%Y%m%d_%H%M%S) # Formats date like 20250717_020624
    HOSTNAME=$(hostname) # Gets the system's hostname
    BACKUP_FILE="${DEST_DIR}/backup_${HOSTNAME}_${TIMESTAMP}.tar.gz"

    echo "Creating backup of '$SOURCE_DIR' to '$BACKUP_FILE'..."
    # `tar` command for archiving and compressing
    # -c: create archive
    # -z: gzip compress the archive
    # -v: verbose output (show files being added)
    # -f "$BACKUP_FILE": specifies the archive filename
    sudo tar -czvf "$BACKUP_FILE" "$SOURCE_DIR"

    if [ $? -eq 0 ]; then
        echo "Backup created successfully: $BACKUP_FILE"
    else
        echo "Backup failed."
    fi
}

# --- Main Script Logic ---

# Infinite loop to display the menu until the user chooses to exit
while true; do
    echo ""
    echo "--- User Management and Backup Script ---"
    echo "1. Add User"
    echo "2. Delete User"
    echo "3. Create Backup"
    echo "4. Exit"
    read -p "Choose an option: " CHOICE # Read user's choice

    # Case statement to execute functions based on user's choice
    case "$CHOICE" in
        1) add_user ;;      # Call the add_user function
        2) delete_user ;;   # Call the delete_user function
        3) create_backup ;; # Call the create_backup function
        4) echo "Exiting script. Goodbye!"; exit 0 ;; # Exit the script
        *) echo "Invalid option. Please choose a number between 1 and 4." ;; # Handle invalid input
    esac
done
