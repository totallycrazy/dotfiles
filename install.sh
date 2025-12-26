#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"

link() {
  src="$DOTFILES/$1"
  dst="$HOME/.$2"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "⚠️  $dst exists – skipping, but setting execution rights..."
    if [ -e "$dst" ] ; then
      chmod u+x "$dst"
    fi
    return
  fi

  ln -sf "$src" "$dst"
  echo "✓ $dst"
  if [ -e "$dst" ] ; then
    chmod u+x "$dst"
  fi
}

link bash/bashrc bashrc
link bash/profile bash_profile
link git/gitconfig gitconfig

sudo apt install -y curl wget git magic-wormhole fd-find sd nnn micro broot lazygit trippy xh yq duf gdu du-dust lnav procs gping fzf zoxide ripgrep bat lsd eza dtrx

cd ~ 
source .bashrc
