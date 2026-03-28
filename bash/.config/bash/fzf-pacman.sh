#!/usr/bin/env bash
# ============================================================
#  FZF-PACMAN
#  Interactive package manager using fzf
#  Usage: fzf-pacman [remove|install|orphans|aur|info|log]
# ============================================================

fzf-pacman() {
  # ── HELPERS ─────────────────────────────────────────────

  _has() { command -v "$1" &>/dev/null; }

  _fzf_base() {
    fzf -m \
      --layout=reverse \
      --border=rounded \
      --prompt="${1:-❯ } " \
      --pointer="→" \
      --marker="✓" \
      --height=70% \
      --preview-window=right:40%:wrap \
      "${@:2}"
  }

  _confirm() {
    echo -e "\n$1"
    read -r -p "Proceed? [y/N] " ans
    [[ "${ans,,}" == "y" ]]
  }

  _no_selection() { echo "No packages selected. Aborting."; }

  # ── MODES ───────────────────────────────────────────────

  _remove() {
    local pkgs
    pkgs=$(pacman -Qq | _fzf_base "Remove ❯" --preview "pacman -Qi {1}")
    [[ -z "$pkgs" ]] && _no_selection && return

    echo "Packages to remove:"
    echo "$pkgs" | sed 's/^/  - /'
    _confirm "" || return

    sudo pacman -Rns --noconfirm $(echo "$pkgs")
  }

  _install() {
    local pkgs
    pkgs=$(pacman -Slq | _fzf_base "Install ❯" --preview "pacman -Si {1}")
    [[ -z "$pkgs" ]] && _no_selection && return

    echo "Packages to install:"
    echo "$pkgs" | sed 's/^/  - /'
    _confirm "" || return

    sudo pacman -S --noconfirm --needed $(echo "$pkgs")
  }

  _orphans() {
    local orphans
    orphans=$(pacman -Qdtq 2>/dev/null)

    if [[ -z "$orphans" ]]; then
      echo "No orphaned packages found."
      return
    fi

    local pkgs
    pkgs=$(echo "$orphans" | _fzf_base "Orphans ❯" --preview "pacman -Qi {1}")
    [[ -z "$pkgs" ]] && _no_selection && return

    echo "Orphans to remove:"
    echo "$pkgs" | sed 's/^/  - /'
    _confirm "" || return

    sudo pacman -Rns --noconfirm $(echo "$pkgs")
  }

  _aur() {
    if ! _has yay && ! _has paru; then
      echo "No AUR helper found. Install yay or paru first."
      return 1
    fi

    local helper
    _has yay && helper="yay" || helper="paru"

    local mode="${1:-install}"

    case "$mode" in
    install)
      local pkgs
      echo "Fetching AUR package list..."
      pkgs=$($helper -Slq --aur 2>/dev/null | _fzf_base "AUR Install ❯" --preview "$helper -Si {1}")
      [[ -z "$pkgs" ]] && _no_selection && return

      echo "AUR packages to install:"
      echo "$pkgs" | sed 's/^/  - /'
      _confirm "" || return

      $helper -S --aur --noconfirm $(echo "$pkgs")
      ;;
    remove)
      local installed_aur
      installed_aur=$(pacman -Qqm 2>/dev/null)

      if [[ -z "$installed_aur" ]]; then
        echo "No AUR packages installed."
        return
      fi

      local pkgs
      pkgs=$(echo "$installed_aur" | _fzf_base "AUR Remove ❯" --preview "$helper -Qi {1}")
      [[ -z "$pkgs" ]] && _no_selection && return

      echo "AUR packages to remove:"
      echo "$pkgs" | sed 's/^/  - /'
      _confirm "" || return

      yay -Rns --noconfirm $(echo "$pkgs")
      ;;
    *)
      echo "Usage: fzf-pacman aur [install|remove]"
      ;;
    esac
  }

  _info() {
    local pkg
    pkg=$(pacman -Qq | _fzf_base "Info ❯" \
      --preview "pacman -Qi {1}" \
      --bind "ctrl-f:preview(pacman -Ql {1})" \
      --bind "ctrl-d:preview(pacman -Qi {1})" \
      --header "CTRL+D: details  CTRL+F: files")
    [[ -z "$pkg" ]] && _no_selection && return
    pacman -Qi "$pkg"
  }

  _log() {
    grep -i "installed\|removed\|upgraded" /var/log/pacman.log |
      tac |
      _fzf_base "Log ❯" \
        --no-multi \
        --preview "echo {}" \
        --preview-window=down:3:wrap
  }

  _update() {
    echo "Checking for updates..."
    local updates
    updates=$(checkupdates 2>/dev/null)

    if [[ -z "$updates" ]]; then
      echo "System is up to date."
      return
    fi

    local pkgs
    pkgs=$(echo "$updates" | awk '{print $1}' |
      _fzf_base "Update ❯" \
        --bind "ctrl-a:select-all" \
        --preview "pacman -Si {1}" \
        --header "$(echo "$updates" | wc -l) updates available")
    [[ -z "$pkgs" ]] && _no_selection && return

    echo "Packages to update:"
    echo "$pkgs" | sed 's/^/  - /'
    _confirm "" || return

    yay -Syu --noconfirm $(echo "$pkgs")
  }

  # ── HELP ────────────────────────────────────────────────

  _usage() {
    cat <<EOF
fzf-pacman — interactive package manager

Usage:
  fzf-pacman <command> [subcommand]

Commands:
  install       fuzzy search and install from repos
  remove        fuzzy search and remove installed packages
  orphans       find and remove orphaned packages
  aur install   fuzzy search and install from AUR
  aur remove    fuzzy search and remove AUR packages
  info          browse package info (CTRL+D: details, CTRL+F: files)
  log           browse pacman transaction log
  update        select packages to update from available updates

Keys (inside fzf):
  TAB           select/deselect a package
  Enter         confirm selection
  Esc           cancel
EOF
  }

  # ── DISPATCH ────────────────────────────────────────────

  case "${1:-}" in
  install) _install ;;
  remove) _remove ;;
  orphans) _orphans ;;
  aur) _aur "${2:-install}" ;;
  info) _info ;;
  log) _log ;;
  update) _update ;;
  help | --help | -h) _usage ;;
  *)
    echo "Unknown command: ${1:-}"
    echo ""
    _usage
    return 1
    ;;
  esac
}
