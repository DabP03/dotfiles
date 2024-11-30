source ~/.zplug/init.zsh

zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/github",   from:oh-my-zsh
zplug "plugins/fzf",   from:oh-my-zsh
zplug "plugins/dirhistory",   from:oh-my-zsh
zplug "plugins/fancy-ctrl-z",   from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "hlissner/zsh-autopair", defer:2


zstyle ':completion:*' menu select

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# History settings
HISTFILE=~/.zsh_history          # Location of the history file
HISTSIZE=10000                   # Number of entries kept in memory
SAVEHIST=10000                   # Number of entries saved to file
setopt appendhistory             # Append to the history file, don't overwrite it
setopt incappendhistory          # Add commands to history file immediately
setopt sharehistory              # Share history between sessions
setopt histignoredups            # Don't record duplicate entries
setopt histignorespace           # Ignore commands that start with a space


ZSH_AUTOSUGGEST_STRATEGY=(completion)

source ~/.zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh

alias v="nvim"
alias nv="neovide"
alias sv="sudo nvim"
alias ls="lsd"
alias pf="fzf --border=none --preview 'bat -n --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
alias vv="dev-tmux"
alias gitui="gitui -t frappe.ron"
alias ssh='env TERM=xterm-256color ssh' # allows kitty to work with ssh
alias fman="compgen -c | fzf | xargs man"
alias ftldr="compgen -c | fzf | xargs tldr"
alias get_idf='. $HOME/esp/esp-idf/export.sh'

export FZF_DEFAULT_OPTS=" \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

export BAT_THEME="Catppuccin-frappe"

eval "$(starship init zsh)"

# export PATH=$PATH:~/.cargo/bin/
export PATH="$HOME/.cargo/bin:$PATH"
export PATH=$PATH=:/usr/include/SDL2
export PATH=$PATH=:/home/piotr/.config/emacs/bin
export PATH=$PATH=:/home/piotr/.bin

export EDITOR=nvim
export VISUAL=nvim

#xdg-mime default nvim.desktop text/plain
eval "$(zoxide init zsh --cmd cd)"

# bun completions
[ -s "/home/piotr/.bun/_bun" ] && source "/home/piotr/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

zplug load
