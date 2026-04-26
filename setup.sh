#!/usr/bin/env bash

# setup chaotic aur
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

printf "[chaotic-aur]\n Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

# install paru
sudo pacman -Syu paru

# install packages
paru -S --needed --noconfirm neovim gcc npm nodejs python zsh tmux zoxide pamixer spotify steam vesktop stow git rsync lazygit btop arm-none-eabi-gcc eza wezterm-nightly-bin zen-browser spicetify-cli qbittorrent tidal-hifi gparted vlc starship inter-font kdeconnect fastfetch fzf unzip firewalld sshfs darkly gamescope yazi fd jq 7zip power-profiles-daemon arm-none-linux-gnueabihf-toolchain-bin awww hyprland hypridle hyprcursor hyprlock hyprshot dunst archlinux-xdg-menu qt6ct-kde qt5ct-kde xdg-desktop-portal-gtk xdg-desktop-portal-hyprland caligula quickshell gnome-keyring libsecret catimg luarocks waypaper vicinae nerd-fonts yolk-bin catppuccin-cursors-frappe awww-git zathura zathura-pdf-mupdf darkly-qt6-git zplug papirus-icon-theme

# setup yolk
cd ~/.config/yolk/ || exit 1
yolk git sync

# install zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# make gitclone directory
mkdir -p ~/.gitclone
cd ~/.gitclone || exit 1

# download zsh-syntax-highlighting theme
git clone --depth 1 https://github.com/catppuccin/zsh-syntax-highlighting.git
mkdir -p ~/.zsh
cp ~/.gitclone/zsh-syntax-highlighting/themes/catppuccin_frappe-zsh-syntax-highlighting.zsh ~/.zsh/

# download qt theme
git clone --depth 1 https://github.com/catppuccin/kde.git
~/.gitclone/kde/install.sh 3 7 2 y

hyprctl reload
exit 0
