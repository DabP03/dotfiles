### Install Chaotic AUR
- Install [Chaotic AUR](https://aur.chaotic.cx/)

### PACKEGES TO INSTALL 
- Install all packages
    ```bash
    sudo pacman -S --needed stow hyprland hypridle hyprlock hyprpaper hyprshot network-manager-applet waybar dart-sass neovim gcc npm nodejs python qt5ct qt6ct-kde eww zsh tmux python-pylatexenc lsd zoxide pamixer onefetch vesktop
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
