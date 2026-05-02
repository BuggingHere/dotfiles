# ===========================
# Environment
# ===========================
export SUDO_EDITOR=nvim
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=foot
export BROWSER=firefox
export MANPAGER="nvim +Man!"

# ===========================
# Path
# ===========================
export PATH="$HOME/.local/bin:$PATH"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# SSH agent
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

# ===========================
# History
# ===========================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ===========================
# Completion
# ===========================
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}=A-Z'

# ===========================
# Aliases
# ===========================
alias ls="eza --icons"
alias ll="eza -l --icons --git"
alias la="eza -la --icons --git"
alias lt="eza --tree --icons"
alias cat="bat"
alias grep="rg"
alias find="fd"
alias vim="nvim"
alias vi="nvim"

# Git
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph"

# System
alias update="sudo pacman -Syu"
alias cleanup="sudo pacman -Rns $(pacman -Qdtq)"
alias mirrors="sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist"

# Dev
alias py="python"
alias venv="python -m venv .venv && source .venv/bin/activate"
alias activate="source .venv/bin/activate"

# New C project
newc() {
    mkdir -p ~/projects/c/$1
    cp ~/projects/c/template/Makefile ~/projects/c/$1/
    touch ~/projects/c/$1/main.c
    cd ~/projects/c/$1
    nvim main.c
}

# New Python project
newpy() {
    mkdir -p ~/projects/python/$1
    cd ~/projects/python/$1
    pyenv local 3.12
    python -m venv .venv
    source .venv/bin/activate
    nvim main.py
}

# ===========================
# Keybindings
# ===========================
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# ===========================
# Tools
# ===========================
eval "$(starship init zsh)"
eval "$(zoxide init zsh --cmd cd)"

source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
export FZF_DEFAULT_OPTS='--color=bg+:#221e1a,bg:#1a1612,spinner:#8abbb0,hl:#c4746e,fg:#d4c9b8,header:#6b6359,info:#d4aa6e,pointer:#8aaabb,marker:#8aac8a,fg+:#d4c9b8,prompt:#b89ab8,hl+:#c4746e'

# ===========================
# Tmux autolaunch
# ===========================
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach -t default || tmux new -s default
    exit
fi
