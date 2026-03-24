# ============================================================
#  BASHRC
# ============================================================

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ── ENVIRONMENT ─────────────────────────────────────────────
export SUDO_EDITOR=nvim
export EDITOR=nvim
export VISUAL=nvim

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

export HISTCONTROL="erasedups:ignorespace"
export HISTSIZE=10000
export HISTFILESIZE=20000

export STARSHIP_CONFIG="$HOME/.cache/wal/starship.toml"

# ── SHELL OPTIONS ────────────────────────────────────────────
shopt -s cdspell      # autocorrect cd typos
shopt -s checkwinsize # update LINES/COLUMNS after each command
shopt -s globstar     # enable ** glob patterns
shopt -s histappend   # append to history instead of overwriting
shopt -s autocd       # type a dir name to cd into it

# ── PYWAL ────────────────────────────────────────────────────
source ~/.cache/wal/colors.sh

# ── COMPLETIONS ──────────────────────────────────────────────
source /usr/share/doc/pkgfile/command-not-found.bash
complete -cf sudo

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
alias catp='bat' # bat with paging

# ── NAVIGATION ───────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'

# ── FILE OPERATIONS ──────────────────────────────────────────
alias cp='cp -v'          # interactive + verbose
alias mv='mv -v'          # interactive + verbose
alias rm='trash-put'      # send to trash instead of permanent delete
alias rmf='rm -v'         # real rm for when you actually mean it
alias trl='trash-list'    # list trashed files
alias trr='trash-restore' # restore a trashed file
alias tre='trash-empty'   # empty the trash

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

eval "$(fzf --bash)"

# ── ZOXIDE ───────────────────────────────────────────────────
eval "$(zoxide init bash --cmd cd)"

# ── STARSHIP ─────────────────────────────────────────────────
eval "$(starship init bash)"
