### Enable multilib
- Enable multilib in /etc/pacman.conf

### Install Chaotic AUR
- Install [Chaotic AUR](https://aur.chaotic.cx/)

### Install Paru
- Install paru
    ```bash
    sudo pacman -Sy paru
    ```
### PACKEGES TO INSTALL 
- Install all packages
    ```bash
    paru -S --needed neovim gcc npm nodejs python zsh tmux zoxide pamixer spotify steam vesktop stow ttf-fira-code ttf-fira-sans ttf-fira-mono ttf-firacode-nerd git rsync lazygit btop arm-none-eabi-gcc eza wezterm zen-browser spicetify-cli qbittorrent tidal-hifi gparted vlc
    ```
### ZSH Configuration
- Set ZSH as default shell
    ```bash
    chsh -s $(which zsh)
    ```
- Install [zplug](https://github.com/zplug/zplug)
    ```bash
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    ```

### Cursors

- Install [Catppuccin Cursors](https://github.com/catppuccin/cursors)
    ```bash
    cd ~/.gitclone
    git clone https://github.com/catppuccin/cursors.git
    cd cursors
    just build_with_hyprcursor frappe "dark"
    rsync -a ~/.gitclone/cursors/dist/catppuccin-frappe-dark-cursors ~/.icons
    ```
### Fonts

- Intall [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts)
    ```bash
    cd ~/.gitclone
    git clone --depth 1 https://github.com/ryanoasis/nerd-fonts
    cd nerd-fonts
    ./install.sh
    ```

### Icons

- Install [Papirus Folders](https://github.com/catppuccin/papirus-folders)
    ```bash
    cd ~/.gitclone
    git clone https://github.com/catppuccin/papirus-folders.git
    cd papirus-folders
    sudo cp -r src/* /usr/share/icons/Papirus
    curl -LO https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders   
    chmod +x ./papirus-folders
    ./papirus-folders -C cat-frappe-peach --theme Papirus-Dark
    ```

### XDG
- Install archlinux-xdg-menu
    ```bash
    paru -S archlinux-xdg-menu
    ```
- Run this:
    ```bash
    XDG_MENU_PREFIX=arch- kbuildsyscoca6
    ```

### Zephyr
- Install dependencies
    ```bash
    paru -Sy --needed python-setuptools python-wheel python-pyserial gperf wget curl xz ninja file cmake bison make flex gcc dtc openocd arm-none-eabi-gcc arm-none-eabi-binutils arm-none-eabi-gdb patchelf dfu-util gcovr python-pytest python-anytree python-breathe python-intelhex python-packaging python-ply python-pyaml python-pyelftools python-pykwalify python-tabulate ccache doxygen python-west
    ```
