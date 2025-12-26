#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"

link() {
  src="$DOTFILES/$1"
  dst="$HOME/.$2"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "⚠️  $dst exists – skipping"
    return
  fi

  ln -sf "$src" "$dst"
  echo "✓ $dst"
}

link bash/bashrc bashrc
link bash/bash_profile bash_profile
link git/gitconfig gitconfig
