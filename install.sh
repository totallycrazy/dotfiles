#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"

link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/.$2"

  # Ziel existiert und ist KEIN Symlink → nicht anfassen
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    echo "⚠️  $dst exists – skipping"
    return
  fi

  # Quelle existiert?
  if [[ ! -e "$src" ]]; then
    echo "✗ source missing: $src"
    return
  fi

  ln -sf "$src" "$dst"
  echo "✓ linked $dst"

  # optional: executable bit setzen, wenn Quelle executable ist
  if [[ -x "$src" ]]; then
    chmod u+x "$dst"
  fi
}

link bash/aliases bash_aliases
link bash/bashrc bashrc
link bash/profile bash_profile
link git/gitconfig gitconfig

echo "Installing packages…"

sudo apt update
sudo apt install -y \
  curl wget git magic-wormhole fd-find sd nnn micro broot \
  lazygit trippy xh yq duf gdu du-dust lnav procs gping \
  fzf zoxide ripgrep bat lsd eza dtrx

# fd-find / bat Debian-Namenschaos fixen
command -v fdfind >/dev/null && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
command -v batcat >/dev/null && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"

# sicherstellen, dass ~/.local/bin im PATH ist
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

source "$HOME/.bashrc"
