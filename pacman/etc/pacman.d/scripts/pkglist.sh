#!/usr/bin/env bash

OUTDIR="/home/buggy/dotfiles"
NATIVE="$OUTDIR/pkglist-native.txt"
AUR="$OUTDIR/pkglist-aur.txt"

mkdir -p "$OUTDIR"

# Native explicitly installed packages (not in AUR)
pacman -Qqen >"$NATIVE"

# AUR / foreign explicitly installed packages
pacman -Qqem >"$AUR"
