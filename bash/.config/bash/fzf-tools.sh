#!/usr/bin/env bash
# ============================================================
#  FZF TOOLS
#  Collection of fzf-powered shell utilities
#  Source this in .bashrc:
#    source ~/.config/bash/fzf-tools.sh
# ============================================================

# ── SHARED HELPERS ──────────────────────────────────────────

_fzf_base() {
  fzf \
    --layout=reverse \
    --border=rounded \
    --prompt="${1:-❯ } " \
    --pointer="→" \
    --marker="✓" \
    --height=70% \
    --preview-window=right:40%:wrap \
    "${@:2}"
}

_fzf_confirm() {
  echo -e "\n$1"
  read -r -p "Proceed? [y/N] " ans
  [[ "${ans,,}" == "y" ]]
}

# ============================================================
#  FZF-KILL
#  Fuzzy search running processes and kill them
#  Usage: fzf-kill [signal]
# ============================================================

fzf-kill() {
  local signal="${1:-SIGTERM}"

  # Validate signal
  if ! kill -l "$signal" &>/dev/null; then
    echo "Invalid signal: $signal"
    echo "Common signals: SIGTERM SIGKILL SIGHUP SIGINT"
    return 1
  fi

  local procs
  procs=$(ps aux --no-headers |
    awk '{printf "%-10s %-8s %-5s %-5s %s\n", $1, $2, $3, $4, substr($0, index($0,$11))}' |
    _fzf_base "Kill ($signal) ❯" \
      -m \
      --header "USER       PID      CPU  MEM  COMMAND" \
      --preview "ps -p {2} -o pid,ppid,user,stat,start,time,command --no-headers 2>/dev/null")

  [[ -z "$procs" ]] && echo "No process selected." && return

  local pids
  pids=$(echo "$procs" | awk '{print $2}')

  echo "Processes to kill with $signal:"
  echo "$procs" | awk '{print "  -", $2, $5}' | head -20

  _fzf_confirm "" || return

  echo "$pids" | xargs kill -s "$signal" 2>/dev/null
  echo "Done."
}

# ============================================================
#  FZF-SSH
#  Fuzzy search ~/.ssh/config hosts and connect
#  Usage: fzf-ssh
# ============================================================

fzf-ssh() {
  local ssh_config="$HOME/.ssh/config"

  if [[ ! -f "$ssh_config" ]]; then
    echo "No SSH config found at $ssh_config"
    return 1
  fi

  local host
  host=$(grep -E "^Host " "$ssh_config" |
    grep -v '\*' |
    awk '{print $2}' |
    _fzf_base "SSH ❯" \
      --no-multi \
      --preview "grep -A8 \"^Host {}\$ \" $ssh_config | bat --color=always --language=sshconfig --style=plain")

  [[ -z "$host" ]] && echo "No host selected." && return

  echo "Connecting to $host..."
  ssh "$host"
}

# ============================================================
#  FZF-DOTFILES
#  Fuzzy search dotfiles and open in nvim
#  Usage: fzf-dotfiles [dotfiles_dir]
# ============================================================

fzf-dotfiles() {
  local dotdir="${1:-$HOME/dotfiles}"

  if [[ ! -d "$dotdir" ]]; then
    echo "Dotfiles directory not found: $dotdir"
    return 1
  fi

  local file
  file=$(find "$dotdir" -type f \
    ! -path "*/.git/*" \
    ! -path "*/node_modules/*" |
    sed "s|$dotdir/||" |
    _fzf_base "Dotfiles ❯" \
      --no-multi \
      --preview "bat --color=always --style=numbers '$dotdir/{}' 2>/dev/null || cat '$dotdir/{}'")

  [[ -z "$file" ]] && echo "No file selected." && return

  nvim "$dotdir/$file"
}

# ============================================================
#  FZF-MAN
#  Fuzzy search man pages and open selected
#  Usage: fzf-man
# ============================================================

fzf-man() {
  local page
  page=$(man -k . 2>/dev/null |
    awk '{print $1, $2}' |
    sort -u |
    _fzf_base "Man ❯" \
      --no-multi \
      --preview "man {1} 2>/dev/null | bat --color=always --language=man --style=plain | head -80")

  [[ -z "$page" ]] && echo "No page selected." && return

  man "$(echo "$page" | awk '{print $1}')"
}

# ============================================================
#  FZF-HISTORY
#  Enhanced history search (supplements CTRL+R)
#  Usage: fzf-history
# ============================================================

fzf-history() {
  local cmd
  cmd=$(history |
    awk '{$1=""; print substr($0,2)}' |
    sort -u |
    tac |
    _fzf_base "History ❯" \
      --no-multi \
      --preview "echo {}" \
      --preview-window=down:3:wrap)

  [[ -z "$cmd" ]] && return

  # Put the command in the readline buffer instead of running it
  READLINE_LINE="$cmd"
  READLINE_POINT=${#cmd}
}

# Bind fzf-history to CTRL+H
bind -x '"\C-h": fzf-history'

# ============================================================
#  FZF-CD
#  Fuzzy search recent zoxide dirs and cd into one
#  Usage: fzf-cd
# ============================================================

fzf-cd() {
  local dir
  dir=$(zoxide query -l 2>/dev/null |
    _fzf_base "Jump ❯" \
      --no-multi \
      --preview "eza --icons --tree --color=always --level=2 {} 2>/dev/null | head -40")

  [[ -z "$dir" ]] && echo "No directory selected." && return

  cd "$dir" || return
  echo "  $dir"
}

# Bind fzf-cd to CTRL+J
bind -x '"\C-j": fzf-cd'

# ============================================================
#  FZF-EDIT
#  Fuzzy search files in current dir (recursive) and open in nvim
#  Usage: fzf-edit
# ============================================================

fzf-edit() {
  local file
  file=$(find . -type f \
    ! -path "*/.git/*" \
    ! -path "*/node_modules/*" |
    _fzf_base "Edit ❯" \
      --no-multi \
      --preview "bat --color=always --style=numbers {} 2>/dev/null | head -100")

  [[ -z "$file" ]] && echo "No file selected." && return

  nvim "$file"
}

# Bind fzf-edit to CTRL+E
bind -x '"\C-e": fzf-edit'

# ============================================================
#  HELP
# ============================================================

fzf-help() {
  cat <<HELP
fzf tools — available commands

  fzf-kill   [signal]    fuzzy kill processes (default: SIGTERM)
  fzf-ssh                fuzzy connect to SSH hosts from ~/.ssh/config
  fzf-dotfiles [dir]     fuzzy open dotfiles in nvim (default: ~/dotfiles)
  fzf-man                fuzzy search and open man pages
  fzf-history            fuzzy search command history → puts cmd in buffer
  fzf-cd                 fuzzy jump to zoxide directory
  fzf-edit               fuzzy open file in current dir tree in nvim

Keybinds (active in bash):
  CTRL+H    fzf-history
  CTRL+J    fzf-cd
  CTRL+E    fzf-edit
  CTRL+R    fzf history search (built-in)
  CTRL+T    fzf file search    (built-in)
  ALT+C     fzf cd             (built-in)
HELP
}
