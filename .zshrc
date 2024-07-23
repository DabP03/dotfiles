export ZSH="$HOME/.oh-my-zsh"

#ZSH_THEME="robbyrussell"

plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
    copyfile
    copypath
    github
    fzf
    dirhistory
    sudo
    web-search
    fancy-ctrl-z
)


source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_STRATEGY=(completion)

source ~/.zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh

#pfetch
# PF_INFO="ascii title os uptime pkgs" PF_SEP="" PF_COL1=4 PF_COL2=9 PF_COL3=1 PF_ALIGN="" PF_ASCII="Catppuccin" pfetch

# alias pfetch='PF_INFO="ascii title os uptime pkgs" PF_SEP="" PF_COL1=4 PF_COL2=9 PF_COL3=1 PF_ALIGN="" PF_ASCII="Catppuccin" pfetch'
# alias zshconfig="nvim ~/.zshrc"
# alias ohmyzsh="nvim ~/.oh-my-zsh"
alias v="nvim"
alias nv="neovide"
alias sv="sudo nvim"
alias ls="lsd"
alias pf="fzf --border=none --preview 'bat -n --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
alias vv="dev-tmux"
alias gitui="gitui -t frappe.ron"
alias cd="z"

#alias compileAndRun="compileAndRun"
alias removeUnused="sudo pacman -Rsn $(pacman -Qqdt)"

alias fman="compgen -c | fzf | xargs man"
alias ftldr="compgen -c | fzf | xargs tldr"

eval $(thefuck --alias)

export FZF_DEFAULT_OPTS=" \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

export BAT_THEME="Catppuccin-frappe"

eval "$(starship init zsh)"

# export PATH=$PATH:~/.cargo/bin/
path+=('/home/piotr/.bin')
path+=('/home/piotr/.cargo/bin')
path+=('/usr/include/SDL2')
path+=('/home/piotr/.config/emacs/bin')
export PATH

export EDITOR=nvim
export VISUAL=nvim

source ~/.zsh-autopair/autopair.zsh
autopair-init

#xdg-mime default nvim.desktop text/plain
eval "$(zoxide init zsh)"
