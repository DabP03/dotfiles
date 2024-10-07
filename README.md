### Install Chaotic AUR
- Install [Chaotic AUR](https://aur.chaotic.cx/)

### PACKEGES TO INSTALL 
- Install all packages
    ```bash
    sudo pacman -S --needed hyprland hypridle hyprlock hyprshot network-manager-applet waybar dart-sass neovim gcc npm nodejs python qt5ct qt6ct-kde eww zsh tmux python-pylatexenc lsd zoxide pamixer onefetch vesktop swww kitty stow ttf-fira-code ttf-fira-sans ttf-fira-mono ttf-firacode-nerd git xdg-desktop-portal-hyprland xdg-desktop-portal-wlr lightly-qt lightly-qt6 papirus-icon-theme mako xorg-xcursorgen inkscape just xcur2png rsync lazygit btop
    ```
### ZSH Configuration

- Install [Oh My ZSH](https://ohmyz.sh/)
    ```bash
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```
- Install [ZSH Autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
    ```bash
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    ```
- Install [ZSH Syntax Highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
    ```bash
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    ```
- Install [ZSH Cattpuccin Theme](https://github.com/catppuccin/zsh-syntax-highlighting)
    ```bash
    cd ~/.gitclone
    git clone https://github.com/catppuccin/zsh-syntax-highlighting.git
    cd zsh-syntax-highlighting/themes/
    rsync -a catppuccin_frappe-zsh-syntax-highlighting.zsh ~/.zsh/
    ```
- Install [ZSH Autopair](https://github.com/hlissner/zsh-autopair)
    ```bash
    git clone https://github.com/hlissner/zsh-autopair ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autopair
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
