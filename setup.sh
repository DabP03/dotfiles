#!/usr/bin/env bash

# enable chaotic-aur
echo "Enabling Chaotic-Aur"
echo "[chaotic-aur]" | sudo tee -a /etc/pacman.conf
echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

# download packages
echo "Downloading packages"
sudo pacman -Syy
sudo pacman -S paru
paru -S --needed neovim gcc npm nodejs python zsh tmux zoxide pamixer spotify steam vesktop stow git rsync lazygit btop eza wezterm zen-browser spicetify-cli qbittorrent tidal-hifi gparted vlc gamemode starship inter-font kdeconnect fastfetch fzf unzip firewalld sshfs darkly gamemode gamescope yazi fd jq 7zip power-profiles-daemon arm-none-linux-gnueabihf-toolchain-bin ttc-iosevka eww waybar swww hyprland hypridle hyprcursor hyprlock hyprshot thunar fuzzel mako networkmanager_dmenu archlinux-xdg-menu qt6ct-kde xdg-desktop-portal-gtk xdg-desktop-portal-hyprland

# setup zsh
echo "Setting up zsh"
chsh -s "$(which zsh)"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
mkdir -p ~/.zsh
cd ~/.gitclone || exit 1
git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
cd zsh-syntax-highlighting/themes/ || exit 1
cp -v catppuccin_frappe-zsh-syntax-highlighting.zsh ~/.zsh

# install fonts
echo "Installing nerd fonts"
cd ~/.gitclone || exit 1
git clone --depth 1 https://github.com/ryanoasis/nerd-fonts
cd nerd-fonts || exit 1
./install.sh

# cursor for kde
echo "Setting up cursors for KDE"
echo "[Icon Theme]" | sudo tee /usr/share/icons/default/index.theme
echo "Inherits=Catppuccin-Frappe-Dark" | sudo tee -a /usr/share/icons/default/index.theme

# setting xdg for hyprland
XDG_MENU_PREFIX=arch- kbuildsycoca6

cd ~ || exit 1
