Shell Script for User Management and Backup in Linux
==================================================================

This repository contains a basic shell script designed to automate user management tasks and provide a simple backup solution in a Linux environment. It's a great starting point for beginners to understand fundamental Linux commands, shell scripting, and basic system administration.

🎯 Objective
------------

The primary goal of this project is to create a shell script that can:

-   Add new user accounts.

-   Delete existing user accounts.

-   Create compressed backups of specified directories.

🛠️ Tools & Technologies Used
-----------------------------

-   **Linux Operating System:** Any popular distribution (e.g., Ubuntu, Fedora, CentOS)

-   **Bash Shell:** The default command-line interpreter on most Linux systems.

-   **Git & GitHub:** For version control and hosting the code repository.

-   **Text Editor:** Any text editor like `Vim`, `Nano`, or `Visual Studio Code`.

✨ Features
----------

-   **User Addition:** Add a new user with a specified username and full name, and set their password.

-   **User Deletion:** Remove an existing user, including their home directory.

-   **Directory Backup:** Create a compressed archive (`.tar.gz`) of a specified source directory to a destination.

⚙️ Prerequisites
----------------

Before you begin, ensure you have:

1.  **A Linux Environment:**

    -   **Recommended for beginners:** Set up a Linux Virtual Machine (e.g., Ubuntu Desktop using VirtualBox or VMware). This provides a safe and isolated environment.

    -   Alternatively, you can use Windows Subsystem for Linux (WSL) on Windows 10/11 or a cloud-based Linux instance.

2.  **Basic understanding of Linux commands:** `ls`, `cd`, `pwd`, `mkdir`, `touch`, `cat`.

3.  **`sudo` privileges:** The script uses `sudo` for user management and backup operations, so your user account must have administrator privileges.

🚀 Getting Started
------------------

Follow these steps to set up and run the script on your Linux system.

### Step 1: Open Your Terminal

-   Once your Linux system is running, open the **Terminal** application. This is where you'll interact with your system using commands.

### Step 2: Clone the Repository (or Create the Script Manually)

#### Option A: Clone from GitHub (Recommended)

If this script is hosted on GitHub, you can clone it directly.

1.  **Install Git** (if not already installed):

    -   On Ubuntu/Debian: `sudo apt update && sudo apt install git -y`

    -   On Fedora/RHEL: `sudo dnf install git -y`

2.  **Clone the repository:**

    Bash

    ```
    git clone https://github.com/LondheShubham153/Shell-Scripting-For-DevOps.git
    cd Shell-Scripting-For-DevOps/Project1

    ```

    (Adjust the `cd` command if the script is in a different subfolder.)

#### Option B: Create the Script Manually

If you prefer to create the script file yourself:

1.  **Create a new directory** for your project:

    Bash

    ```
    mkdir user-management-backup
    cd user-management-backup

    ```

2.  **Create the script file** using a text editor (e.g., `nano`):

    Bash

    ```
    touch user_management.sh
    nano user_management.sh

    ```

3.  **Paste the script code** (provided in the "Code Explanation" section below) into the `nano` editor.

4.  **Save and Exit Nano:** Press `Ctrl + O`, then `Enter` to save, and `Ctrl + X` to exit.

### Step 3: Make the Script Executable

Before running, you need to give the script execution permissions:

Bash

```
chmod +x user_management.sh

```

### Step 4: Run the Script

Execute the script from your terminal:

Bash

```
./user_management.sh

```

The script will present an interactive menu in your terminal. Follow the prompts to add users, delete users, or create backups. You will be asked for your `sudo` password when performing actions that require root privileges.

* * * * *

💻 Code Explanation
-------------------

Here's the detailed breakdown of the `user_management.sh` script:

Bash

```
#!/bin/bash

# This is a simple shell script for user management and backup in Linux.
# Project 1 for absolute beginners.

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

```

### Key Elements of the Script:

-   `#!/bin/bash`: The **shebang** line, tells the system to execute the script using the Bash interpreter.

-   **Functions:** `add_user()`, `delete_user()`, `create_backup()` encapsulate specific tasks, making the code modular and readable.

-   `read -p "Prompt: " VARIABLE`: Prompts the user for input and stores it in `VARIABLE`.

-   `if [ CONDITION ]; then ... else ... fi`: **Conditional statements** for checking conditions (e.g., if a user exists, if a directory exists).

    -   `-z "$VAR"`: Checks if `VAR` is an empty string.

    -   `id "$USERNAME" &>/dev/null`: Attempts to get user information; `&>/dev/null` redirects all output to null, effectively just checking the exit status.

    -   `[ ! -d "$DIR" ]`: Checks if `DIR` is NOT a directory.

-   `sudo command`: Executes a command with **superuser (root)** privileges. You will be prompted for your password.

-   `useradd`, `passwd`, `userdel`: Standard Linux commands for user management.

-   `tar`: Standard Linux command for archiving files.

-   `$?`: A special variable that holds the **exit status** of the *last executed command*. `0` typically means success, any other number indicates an error.

-   `while true; do ... done`: Creates an **infinite loop** to keep the menu running until the user explicitly chooses to exit.

-   `case "$VAR" in OPTION) ... ;; esac`: A **case statement** provides a clean way to handle multiple choices from a menu.

-   `exit 0`: Exits the script with a success status.

* * * * *

🤝 Contributing
---------------

Feel free to fork this repository, suggest improvements, or submit pull requests. Any contributions are welcome!

* * * * *
