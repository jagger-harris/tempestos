#!/bin/sh

dialog_width=50
dialog_height=15

official_extra="official_extra.txt"
official_required="official_required.txt"
aur_extra="aur_extra.txt"
aur_required="aur_required.txt"

get_sudo_password() {
  password=$(dialog --title "Sudo Password" --clear --insecure --passwordbox "Enter your sudo password:" "$dialog_height" "$dialog_width" 3>&1- 1>&2- 2>&3-)
  echo "$password"
}

check_sudo_password() {
  echo "$1" | sudo -S -k -v >/dev/null 2>&1
}

show_yesno() {
  dialog --title "$1" --clear --yesno "$2" "$dialog_height" "$dialog_width"
}

show_message() {
  dialog --title "$1" --clear --msgbox "$2" "$dialog_height" "$dialog_width"
}

show_install_packages() {
  if [ ! -f "$1" ]; then
    dialog --title "TempestOS - File Not Found" --clear --msgbox "Package file $1 not found!" "$dialog_height" "$dialog_width"
    exit 1
  fi
}

show_message "TempestOS" "Welcome to the TempestOS Arch Linux post-installation script!\n\nPress enter to continue..."

password=$(get_sudo_password)

show_password_dialog() {
  if [ -z "$password" ]; then
    show_message "Error" "No password entered. Please try again."
    show_password_dialog
  fi

  if check_sudo_password "$password"; then
    show_message "TempestOS - Correct Password" "The sudo password is correct.\n\nPress enter to continue"
    #echo "$password" | sudo -S your_command_here
  else
    show_message "TempestOS - Incorrect Password" "The sudo password is incorrect. Please try again."
  fi
}

show_password_dialog

# Check if the package file exists
#if [ ! -f "$OFFICIAL_REQUIRED" ]; then
#dialog --msgbox "Package file $OFFICIAL_REQUIRED not found!" "$DIALOG_HEIGHT" "$DIALOG_WIDTH"
#clear
#exit 1
#fi

show_install_packages "$official_required"
