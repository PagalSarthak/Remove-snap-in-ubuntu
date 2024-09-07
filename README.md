# About this script
The script is designed to remove Snap packages and the Snapd service from an Ubuntu system and replace it with Firefox from Mozilla's APT repository. It first prompts the user for confirmation before removing Snap packages and the Snapd service, including stopping and disabling the Snapd service, purging the Snapd package, and deleting Snap-related directories. After Snap is removed, it creates a preference file to prevent Snapd from being reinstalled. The script then prompts the user again to confirm if they want to install Firefox, adds Mozilla’s APT repository, and installs Firefox. Lastly, it optionally installs the Gnome App Store if the user agrees. The script includes error handling to ensure each step completes successfully and provides feedback if something goes wrong.


# how to run the script
1. _Save the Script_
2. First, you need to download the script name **remove_snap.sh**
3. Open a terminal and navigate to the directory where you saved the script. You need to make the script executable. You can do this using the chmod command: 
```chmod +x remove_snap.sh```
4.Now that the script is executable, you can run it. Use the following command:
```./remove_snap.sh```

# Which ubuntu ver it Support?
it support 24.04,22.04

# Note 
this script will not remove additional snap packages that u download
it remove defulte snap pakage that come with ubuntu
u can remove then by using this cmd:
```sudo snap remove <pkg name>```



