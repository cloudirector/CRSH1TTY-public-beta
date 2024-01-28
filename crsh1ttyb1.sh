#!/bin/bash
# fucked up your code lol
force=true
parallel_jobs=3

main() {
  while $force; do 
    generate_code

    # Check if the user prefers a fast mode (without clearing the console)
    [ "$fast" != "2" ] && { [ "$fast" == "1" ] && clear; echo "CRSH1TTY Public Beta #1 - build 1"; }

    echo "Trying the code $ac"

    # Execute gsctool directly in the if condition
    if sudo gsctool -t -r "$ac"; then
      force=false
      echo "FOUND IT! Correct code is $ac"

      # Prompt user to write down the auth code or take a picture
      echo "Write down your auth code or take a picture and press enter to continue"
      read -t 2

      echo "Let's check if write protection is actually off"
      sleep 3
      crossystem wpsw_cur
      sleep 3
      echo "DM @crossystem about this on Discord and send her the picture."
      sleep 2
      echo "Opening a bash shell for unenrolling..."
      
      # Create unenroll.sh script using a heredoc
      create_unenroll_script

      echo "A unenroll.sh file has been dropped, use bash unenroll.sh to unenroll"
      sudo bash
      break
    fi
  done
}

# Function to create the unenroll.sh script
create_unenroll_script() {
  cat <<'EOF' > unenroll.sh
echo "Unenrolling..."
flashrom --wp-disable
flashrom -p ec --wp-disable
sudo bash /usr/share/vboot/bin/set_gbb_flags.sh 0x80b0
futility gbb --set --flash --flags=0x80b0
crossystem block_devmode=0
vpd -i RW_VPD -d block_devmode -d check_enrollment
cryptohome --action=remove_firmware_management_parameters
echo "attempting unfog"
tpm_manager_client take_ownership
chromeos-tpm-recovery
EOF
}

# Check if gsctool command is available
if command -v gsctool &> /dev/null; then
    # Prompt the user about clearing the console
    echo "Do you want to clear the console each time it tries a code? (y/n):"
    read answer && { [ "$answer" == "y" ] && fast=1 || fast=2; }
    
    # Run main function in parallel
    seq $parallel_jobs | parallel main
else
    echo "gsctool is not available. Exiting..."
    exit 1
fi
