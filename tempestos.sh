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
official_extra="official_extra.txt"
official_required="official_required.txt"
aur_extra="aur_extra.txt"
aur_required="aur_required.txt"

# Functions
#################################################

confirm_prompt() {
  prompt="$1"
  while true; do
    echo "$prompt (yes/no)"
    read -r answer
    case "$answer" in
    [Yy] | [Yy][Ee][Ss]) return 1 ;;
    [Nn] | [Nn][Oo]) return 0 ;;
    *) echo "Invalid input. Please enter 'yes' or 'no'." ;;
    esac
  done
}

install_official_packages() {
  official_packages_file="$1"
  official_packages_type="$2"
  
  if [ -f "$official_packages_file" ]; then
    confirm_prompt "Install official Arch packages?"
    if [ $? -eq 1 ]; then
      echo "Installing $official_packages_type official packages..."
      while IFS= read -r package || [ -n "$package" ]; do
        sudo pacman -S --needed --noconfirm "$package"
      done <"$official_packages_file"
    else
      echo "Skipping $official_packages_type official packages..."
    fi
  else
    echo "$official_packages_file not found"
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

# Main script
#################################################

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

# Update system and install necessary packages
echo "0. Update system and install required packages"
echo "----------------------------"
echo
echo "Updating system and installing necessary packages..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git

# Install required official packages
echo
echo "1. Install required official packages"
echo "----------------------------"
install_official_packages "$official_required" "required"

# Install extra official packages
echo
echo "1. Install extra official packages"
echo "----------------------------"
install_official_packages "$official_extra" "extra"

# Install required AUR packages
echo
echo "2. Install required AUR packages"
echo "----------------------------"
echo
install_aur_packages "$aur_required" "required"

# Install extra AUR packages
echo
echo "2. Install extra AUR packages"
echo "----------------------------"
echo
install_aur_packages "$aur_extra" "extra"

# Install dotfiles
echo
echo "3. Clone TempestOS dotfiles"
echo "----------------------------"
echo
install_dotfiles

# Completion
echo
echo "4. Completion"
echo "----------------------------"
echo
echo "TempestOS Arch post-installation script is completed!"
