#!/bin/bash

# Verify that the folder name is passed as a parameter
if [ -z "$1" ]; then
  echo "Error: Specify the folder name."
  echo "Usage: $0 <folder_name>"
  exit 1
fi

# Error log
LOG_FILE="/var/log/script_permissions.log"
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Script execution started: $(date)"

# Variables
FOLDER_NAME="$1"
BASE_FOLDER="/usr/local/lsws"
SITE_FOLDER="$BASE_FOLDER/$FOLDER_NAME"
WP_CACHE="$SITE_FOLDER/public/wp-content/cache"
WP_UPLOADS="$SITE_FOLDER/public/wp-content/uploads"

# Generate a shortened and valid username and group name
USER_NAME=$(echo "$FOLDER_NAME" | sed 's/[^a-zA-Z0-9_-]//g' | cut -c1-20)  # Remove invalid characters and limit to 20 characters
GROUP_HASH=$(echo "$FOLDER_NAME" | md5sum | cut -c1-8)  # 8-character hash
GROUP_NAME="${USER_NAME}-${GROUP_HASH}"  # Username + group hash

# Check if the user already exists
if id "$USER_NAME" &>/dev/null; then
  echo "User $USER_NAME already exists, skipping user creation."
else
  # Create the user and group
  echo "Creating user $USER_NAME and group $GROUP_NAME..."
  sudo adduser "$USER_NAME" --shell /usr/sbin/nologin --gecos "" --disabled-password
  sudo groupadd "$GROUP_NAME"
  sudo usermod -aG "$GROUP_NAME" "$USER_NAME"
fi

# Add nobody to the group
echo "Adding nobody to group $GROUP_NAME..."
sudo usermod -aG "$GROUP_NAME" nobody

# Assign permissions to the public folder
if [ -d "$SITE_FOLDER/public" ]; then
  echo "Assigning permissions for $SITE_FOLDER/public..."
  sudo chown -R "$USER_NAME:$GROUP_NAME" "$SITE_FOLDER/public"
  find "$SITE_FOLDER/public" -type d -exec sudo chmod 750 {} \;
  find "$SITE_FOLDER/public" -type f -exec sudo chmod 640 {} \;

  # Configure the wp-config.php file
  if [ -f "$SITE_FOLDER/public/wp-config.php" ]; then
    sudo chmod 640 "$SITE_FOLDER/public/wp-config.php"
  fi
else
  echo "Error: Folder $SITE_FOLDER/public does not exist."
  exit 1
fi

# Configure cache and upload directories
for DIR in "$WP_CACHE" "$WP_UPLOADS"; do
  if [ -d "$DIR" ]; then
    echo "Configuring permissions for $DIR..."
    sudo chmod -R 770 "$DIR"
    sudo chown -R "$USER_NAME:$GROUP_NAME" "$DIR"
  else
    echo "Creating directory $DIR..."
    sudo mkdir -p "$DIR"
    sudo chmod -R 770 "$DIR"
    sudo chown -R "$USER_NAME:$GROUP_NAME" "$DIR"
  fi
done

# Add the current user to the group
echo "Adding current user matteo to group $GROUP_NAME..."
sudo usermod -a -G "$GROUP_NAME" "yourusername"

# Restart the LiteSpeed server
echo "Restarting LiteSpeed server..."
sudo systemctl restart lsws

# Final instructions
echo -e "\nConfiguration completed for $SITE_FOLDER."
echo "1. Go to the OpenLiteSpeed panel and assign the user $USER_NAME and group $GROUP_NAME to the Virtual Host."
echo "2. Restore the .htaccess file, if necessary, with the default WordPress content."
