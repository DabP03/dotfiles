source ~/.zplug/init.zsh

zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/github",   from:oh-my-zsh
zplug "plugins/fzf",   from:oh-my-zsh
zplug "plugins/dirhistory",   from:oh-my-zsh
zplug "plugins/fancy-ctrl-z",   from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-autosuggestions", defer:2
zplug "hlissner/zsh-autopair", defer:2
zplug "softmoth/zsh-vim-mode"

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

# zsh vim mode
# ZVM_CURSOR_STYLE_ENABLED=false
# ZVM_KEYTIMEOUT=0.01
# ZVM_ESCAPE_KEYTIMEOUT=0.01

ZSH_AUTOSUGGEST_STRATEGY=(completion)

source ~/.zsh/catppuccin_frappe-zsh-syntax-highlighting.zsh

alias v="nvim"
alias sv="sudo nvim"
alias ls="eza --color=always --icons=always"
alias pf="fzf --border=none --preview 'bat -n --color=always {}' --bind shift-up:preview-page-up,shift-down:preview-page-down"
alias vv="dev-tmux"
alias gitui="gitui -t frappe.ron"
# alias ssh='env TERM=xterm-256color ssh' # allows kitty to work with ssh
alias fman="compgen -c | fzf | xargs man"
alias ftldr="compgen -c | fzf | xargs tldr"
alias get_idf='. $HOME/esp/esp-idf/export.sh'
alias anifetch='python ~/.config/anifetch/anifetch.py -f "$HOME/Videos/Touhou-BadApple.mp4" -s "$HOME/Videos/Touhou-BadApple.mp4" -r 10 -W 80 -H 40 -c "--symbols block+border+space-wide-inverted" -ff'


export FZF_DEFAULT_OPTS=" \
--color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
--color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
--color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"

export BAT_THEME="Catppuccin Frappe"

eval "$(starship init zsh)"

# export PATH=$PATH:~/.cargo/bin/
path+=("/home/piotr/.bin")
path+=("$HOME/.cargo/bin:$PATH")
path+=("/usr/include/SDL2")
path+=("/home/piotr/.config/emacs/bin")
export PATH

#lua
# export LUA_PATH="$HOME/.luarocks/share/lua/5.4/?.lua;$HOME/.luarocks/share/lua/5.4/?/init.lua;$LUA_PATH"
# export LUA_CPATH="$HOME/.luarocks/lib/lua/5.4/?.so;$LUA_CPATH"

export EDITOR=nvim
export VISUAL=nvim

#xdg-mime default nvim.desktop text/plain
eval "$(zoxide init zsh --cmd cd)"

# yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# git funcs
function git_all() {
    if [[ $# -ne 1 ]]
    then
        echo "Usage git_all <commit msg>"
        return
    fi
    git add .
    git commit -m "$1"
    git push
}

# zsh vim stuff

function change-hack() {
  read -k 1 option

  if [[ $option == 's' ]]; then
    zle -U Tcs
  elif [[ $option == 'c' ]]; then
    zle vi-change-whole-line
  else
    zle -U ${NUMERIC}Tvc$option
  fi
}

function delete-hack() {
  read -k 1 option

  if [[ $option == 's' ]]; then
    zle -U Tds
  elif [[ $option == 'd' ]]; then
    zle kill-whole-line
  else
    zle -U ${NUMERIC}Tvd$option
  fi
}

function yank-hack() {
  read -k 1 option

  if [[ $option == 's' ]]; then
    zle -U Tys
  elif [[ $option == 'y' ]]; then
    zle vi-yank-whole-line
  else
    zle -U ${NUMERIC}Tvy$option
  fi
}

zle -N change-hack
zle -N delete-hack
zle -N yank-hack
autoload -Uz surround
zle -N delete-surround surround
zle -N change-surround surround
zle -N add-surround surround
bindkey -M vicmd 'Tcs' change-surround
bindkey -M vicmd 'Tds' delete-surround
bindkey -M vicmd 'Tys' add-surround
bindkey -M vicmd 'Tvd' vi-delete
bindkey -M vicmd 'Tvc' vi-change
bindkey -M vicmd 'Tvy' vi-yank
bindkey -M vicmd 'c' change-hack
bindkey -M vicmd 'd' delete-hack
bindkey -M vicmd 'y' yank-hack
bindkey -M visual S add-surround
KEYTIMEOUT=1
MODE_INDICATOR=""

zplug load
