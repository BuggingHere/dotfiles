# ============================================================
#  ZSHRC
# ============================================================

# ── ENVIRONMENT ─────────────────────────────────────────────
export SUDO_EDITOR=nvim
export EDITOR=nvim
export VISUAL=nvim

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=20000

export STARSHIP_CONFIG="$HOME/.cache/wal/starship.toml"


# ── SHELL OPTIONS ────────────────────────────────────────────
setopt AUTO_CD           # type dir name to cd into it
setopt CORRECT           # autocorrect commands
setopt HIST_IGNORE_DUPS  # no duplicate history entries
setopt HIST_IGNORE_SPACE # ignore commands starting with space
setopt SHARE_HISTORY     # share history across sessions
setopt APPEND_HISTORY    # append instead of overwrite
setopt AUTO_PUSHD        # push dirs to stack on cd
setopt PUSHD_IGNORE_DUPS # no duplicate dirs in stack
setopt EXTENDED_GLOB     # extended globbing

fpath=(~/.zsh/completions $fpath)

# ── COMPLETION ───────────────────────────────────────────────
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion::complete:*' gain-privileges 1           # sudo completion


# ── PYWAL ────────────────────────────────────────────────────
source ~/.cache/wal/colors.sh


# ── EZA (ls replacement) ─────────────────────────────────────
alias ls='eza --icons --group-directories-first --color=always'
alias l='eza --icons --group-directories-first --color=always -lah --time-style=long-iso'
alias ll='eza --icons --group-directories-first --color=always -l'
alias la='eza --icons --group-directories-first --color=always -a'
alias lt='eza --icons --group-directories-first --color=always -l --sort=modified'
alias tree='eza --icons --tree --color=always'


# ── BAT (cat replacement) ────────────────────────────────────
export BAT_THEME="base16"
alias cat='bat --paging=never'
alias catp='bat'


# ── NAVIGATION ───────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'


# ── FILE OPERATIONS ──────────────────────────────────────────
alias cp='cp -v'
alias mv='mv -v'
alias rm='trash-put'
alias rmf='rm -v'
alias trl='trash-list'
alias trr='trash-restore'
alias tre='trash-empty'


# ── GIT ──────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull --rebase'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gco='git checkout'
alias grs='git restore --staged'


# ── SYSTEM ───────────────────────────────────────────────────
alias dfh='df -hT /home /'
alias duh='du -sh * | sort -h'
alias freeh='free -h'
alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'
alias suspend='systemctl suspend'


# ── CLIPBOARD ────────────────────────────────────────────────
alias clip='wl-copy'
alias paste='wl-paste'


# ── UTILS ────────────────────────────────────────────────────
alias c='clear'
alias wget='wget -c'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias vi='nvim'
alias vim='nvim'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias path='echo -e ${PATH//:/\\n}'
alias ff='fastfetch --config examples/13.jsonc'
alias lg="lazygit"

# ── FZF ──────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border=rounded
  --prompt='❯ '
  --pointer='→'
  --marker='✓'
  --color=bg+:${color0},bg:${color0},spinner:${color1},hl:${color1}
  --color=fg:${color7},header:${color1},info:${color3},pointer:${color1}
  --color=marker:${color2},fg+:${color7},prompt:${color4},hl+:${color1}
"
export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_OPTS="--preview 'eza --icons --tree --color=always {} | head -100'"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range=:50 {}'"

source <(fzf --zsh)

# ── SOURCE ───────────────────────────────────────────────────
source ~/.config/zsh/fzf-pacman.zsh
source ~/.config/zsh/fzf-tools.zsh


# ── PLUGINS ──────────────────────────────────────────────────
# Install with: sudo pacman -S zsh-autosuggestions zsh-syntax-highlighting
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── ZOXIDE ──────────────────────────────────────────────────
# Initialise zoxide and replace cd entirely
eval "$(zoxide init zsh --cmd cd)"
# Now `cd` uses zoxide — learns your dirs automatically
# Use `cd -` to go back, `cdi` for interactive fzf picker

# ── YAZI ────────────────────────────────────────────────────
# Shell wrapper — lets yazi change your working directory on quit
# Press q in yazi and your terminal cd's to where you left off
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# ── TMUX ────────────────────────────────────────────────────
# Auto-attach or create a default session when opening a terminal
# Only runs if not already inside tmux
if [ -z "$TMUX" ]; then
    tmux attach -t main 2>/dev/null || tmux new -s main
    kill -HUP $PPID
fi

# ── STARSHIP ─────────────────────────────────────────────────
eval "$(starship init zsh)"
