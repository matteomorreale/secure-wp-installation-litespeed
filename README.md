# WordPress Permission Configuration Script for OpenLiteSpeed

This script automates the setup of permissions for WordPress installations on OpenLiteSpeed servers to ensure that one installation cannot access another one's.

---

## Prerequisites

- Ensure you have OpenLiteSpeed installed and running.
- Verify that you have root or sudo privileges to execute the commands.
- Replace all occurrences of **`yourusername`** with your actual username on the server.

---

## Notes

- Replace **`yourusername`** in the script where necessary to match your server's setup.
- Verify that your Virtual Host is **not using a template** before applying the suEXEC settings, if so instantiate if first.

---

## Features

- Automatically creates a system user and group for each WordPress site.
- Assigns proper permissions to `public`, `wp-content/cache`, and `wp-content/uploads` directories.
- Ensures compatibility with OpenLiteSpeed's **suEXEC User** and **suEXEC Group** settings for enhanced security.

---

## Usage

1. **Download the Script**  
   Save the script to your server, e.g., `/usr/local/lsws/scripts/wp_permission_config.sh`.

2. **Run the Script**  
   ```bash
   sudo bash wp_permission_config.sh <folder_name>
   ```
   Replace `<folder_name>` with the name of the WordPress installation folder, e.g., `example-site`.

3. **Update OpenLiteSpeed Virtual Host Settings**  
   - Log in to the OpenLiteSpeed Web Admin Panel.
   - Navigate to the **Virtual Hosts** section.
   - Select the Virtual Host where your WordPress site is hosted.
   - Go to **Basic > Security**.
   - In the **suEXEC User** and **suEXEC Group** fields, enter:
     - The **username** created by the script.
     - The **group name** created by the script.
   - Save changes and restart the server.

   ⚠️ **Important:**  
   - This method is **only applicable to single Virtual Hosts**.  
   - If you're using a Virtual Host Template, instantiate a single Virtual Host from the template before applying these changes.

4. **Restore .htaccess (Optional)**  
   If necessary, replace the `.htaccess` file in the `public` directory with the default WordPress `.htaccess` content.

---

## Example

### Script Execution
```bash
sudo chmod +x wp_permission_config.sh
sudo bash wp_permission_config.sh example-site
```

- The script will create a user and group based on the folder name.  
  Example:
  - User: `example-site`
  - Group: `example-site-<hash>`

### Virtual Host Configuration
- In the OpenLiteSpeed Admin Panel:
  - **suEXEC User**: `example-site`
  - **suEXEC Group**: `example-site-<hash>`

---

## License

This script is provided under the MIT License. Use at your own risk. Contributions are welcome!
