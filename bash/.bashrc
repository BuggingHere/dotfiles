# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export SUDO_EDITOR=nvim
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# Navigation & ls variants (short + colorful but not too noisy)
alias ls='ls --color=auto --group-directories-first'
alias l='ls -lAh --time-style=long-iso' # detailed, human-readable
alias ll='ls -l --color=auto'
alias la='ls -A'              # almost all
alias lt='ls -lh --sort=time' # sort by time

# Neovim
alias vi='nvim'
alias vim='nvim'
alias cat='bat'

# Git
alias g='git'
alias gs='git status -sb' # short status
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
alias grs='git restore --staged' # unstage

# System & monitoring
alias dfh='df -hT /home /'
alias duh='du -sh * | sort -h' # current dir usage
alias freeh='free -h'          # human-readable memory
alias reboot='systemctl reboot'
alias poweroff='systemctl poweroff'
alias suspend='systemctl suspend'

# Clipboard & text utils
alias clip='wl-copy'   # copy to clipboard
alias paste='wl-paste' # paste from clipboard
alias c='clear'

# Misc useful
alias mkdir='mkdir -pv'
alias cp='cp -v' # interactive + verbose
alias mv='mv -v'
alias rm='rm -v'
alias wget='wget -c' # continue downloads
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'

# Productivity
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias week='date +%V'               # current week number
alias path='echo -e ${PATH//:/\\n}' # print PATH nicely
alias nf='fastfetch --config neofetch'

source ~/.cache/wal/colors.sh
source /usr/share/doc/pkgfile/command-not-found.bash

complete -cf sudo

export PS1='\[\033[01;32m\]\u@\h:\[\033[01;34m\]\w\[\033[00m\]\$ '
export HISTCONTROL="erasedups:ignorespace"
shopt -s cdspell
shopt -s checkwinsize
bind '"\t": menu-complete'
bind '"\e[Z": menu-complete-backward'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'
set show-all-if-ambiguous on
