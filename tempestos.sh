#!/bin/sh

#   _____                              _   _____ _____
#  |_   _|                            | | |  _  /  ___|
#    | | ___ _ __ ___  _ __   ___  ___| |_| | | \ `--.
#    | |/ _ \ '_ ` _ \| '_ \ / _ \/ __| __| | | |`--. \
#    | |  __/ | | | | | |_) |  __/\__ \ |_\ \_/ /\__/ /
#    \_/\___|_| |_| |_| .__/ \___||___/\__|\___/\____/
#                     | |
#                     |_|
#
# TempestOS Arch Linux post-install script
# RUN THIS AT YOUR OWN RISK
# SCRIPT IS SAFE, BUT WILL OVERWRITE YOUR DOTFILES

# Globals
#################################################

arch_extra="arch_extra.txt"
arch_required="arch_required.txt"
aur_extra="aur_extra.txt"
aur_required="aur_required.txt"

# Functions
#################################################

confirm_prompt() {
  prompt="$1"
  while true; do
    echo "$prompt (yes/no)"
    echo -n "Answer: "
    read -r answer
    case "$answer" in
    [Yy] | [Yy][Ee][Ss]) return 1 ;;
    [Nn] | [Nn][Oo]) return 0 ;;
    *) echo "Invalid input. Please enter 'yes' or 'no'." ;;
    esac
  done
}

install_arch_packages() {
  arch_packages_file="$1"
  arch_packages_type="$2"

  if [ -f "$arch_packages_file" ]; then
    confirm_prompt "Install $2 Arch packages?"
    if [ $? -eq 1 ]; then
      echo "Installing $arch_packages_type arch packages..."
      while IFS= read -r package || [ -n "$package" ]; do
        sudo pacman -S --needed --noconfirm "$package"
      done <"$arch_packages_file"
    else
      echo "Skipping $arch_packages_type arch packages..."
    fi
  else
    echo "$arch_packages_file not found"
    confirm_prompt "Continue installation?"
    [ $? -eq 1 ] || exit 0
  fi
}

install_aur_packages() {
  aur_packages_file="$1"
  aur_packages_type="$2"

  if [ -f "$aur_packages_file" ]; then
    confirm_prompt "Install AUR packages?"
    if [ $? -eq 1 ]; then
      echo "Installing $aur_packages_type AUR packages..."
      if ! command -v paru >/dev/null 2>&1; then
        echo "Installing paru AUR helper..."
        git clone https://aur.archlinux.org/paru-bin.git
        (
          cd paru-bin || exit
          makepkg -si --noconfirm
          cd ..
          rm -rf paru-bin
        )
      fi
      while IFS= read -r package || [ -n "$package" ]; do
        paru -S --needed --noconfirm "$package"
      done <"$aur_packages_file"
    else
      echo "Skipping $aur_packages_type AUR packages..."
    fi
  else
    echo "$aur_packages_file not found"
    confirm_prompt "Continue installation?"
    [ $? -eq 1 ] || exit 0
  fi
}

install_dotfiles() {
  echo "*** ANSWERING YES WILL OVERWRITE YOUR CURRENT DOTFILES! ***"
  echo "*** Make sure to back them up before continuing. ***"
  echo

  confirm_prompt "Install dotfiles?"
  if [ $? -eq 1 ]; then
    echo "Cloning dotfiles git repo to temp folder..."
    git clone https://github.com/jagger-harris/dotfiles.git dotfiles_tmp
    echo "Copying dotfiles to home directory..."
    cp -a dotfiles_tmp/. "$HOME"
    echo "Removing temp folder"
    rm -rf dotfiles_tmp
  else
    echo "Skipping dotfiles..."
  fi
}

install_lightdm() {
  echo "Press ENTER to continue..."
  head -n 1 >/dev/null
  sudo pacman -S --needed --noconfirm lightdm lightdm-gtk-greeter
  sudo cp lightdm/lightdm.conf /etc/lightdm/
  sudo chmod 644 /etc/lightdm/lightdm.conf
  sudo chown -c root /etc/lightdm/lightdm.conf
  sudo cp lightdm/lightdm-gtk-greeter.conf /etc/lightdm/
  sudo chmod 644 /etc/lightdm/lightdm-gtk-greeter.conf
  sudo chown -c root /etc/lightdm/lightdm-gtk-greeter.conf
  sudo mkdir -p /usr/share/lightdm
  sudo cp lightdm/blue_tempest.svg /usr/share/lightdm/
  sudo chmod 644 /usr/share/lightdm/blue_tempest.svg
  sudo chown -c root /usr/share/lightdm/blue_tempest.svg
}

# Main script
#################################################

clear
cat logo.txt
echo
echo "Welcome to the TempestOS Arch post-installation script!"
echo

if [ "$(id -u)" = 0 ]; then
  echo "Detected installation script running as the root user."
  echo "DO NOT RUN THE SCRIPT AS THE ROOT USER!"
  exit 0
fi

echo "Follow instructions carefully. There are options to not install packages."
echo "However, it is recommended to answer (y/yes) to all of them."
echo
echo "Press ENTER to continue..."
head -n 1 >/dev/null
clear

# Update system and install necessary packages
cat logo.txt
echo
echo "0. Update system and install required packages"
echo
echo "Updating system and installing necessary packages..."
echo
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git
clear

# Configure LightDM
cat logo.txt
echo
echo "1. Install and Configure LightDM"
echo
install_lightdm
clear

# Install required arch packages
cat logo.txt
echo
echo "2. Install required Arch packages"
echo
echo "**REQUIRED**"
echo "**ANSWERING NO CAN LEAD TO AN UNSTABLE EXPERIENCE**"
echo
install_arch_packages "$arch_required" "required"
clear

# Install extra arch packages
cat logo.txt
echo
echo "3. Install extra Arch packages"
echo
echo "**RECOMMENDED**"
echo "Not required for functionality, but recommonded for the full TempestOS experience."
echo
install_arch_packages "$arch_extra" "extra"
clear

# Install required AUR packages
cat logo.txt
echo
echo "4. Install required AUR packages"
echo
echo "**REQUIRED**"
echo "**ANSWERING NO CAN LEAD TO AN UNSTABLE EXPERIENCE**"
echo
install_aur_packages "$aur_required" "required"
clear

# Install extra AUR packages
cat logo.txt
echo
echo "5. Install extra AUR packages"
echo
echo "**RECOMMENDED**"
echo "Not required for functionality, but recommonded for the full TempestOS experience."
echo
install_aur_packages "$aur_extra" "extra"
clear

# Install dotfiles
cat logo.txt
echo
echo "6. Clone TempestOS dotfiles"
echo
echo "**RECOMMENDED**"
echo "Not required for functionality, but recommonded for the full TempestOS experience."
echo
install_dotfiles
clear

# Completion
cat logo.txt
echo
echo "7. Completion"
echo
echo "TempestOS Arch post-installation script is completed!"
echo
echo "Press ENTER to exit..."
head -n 1 >/dev/null
clear
