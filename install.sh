#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
git pull

ask_on_conflict() {
  local dst="$1"
  local ts
  ts=$(date +"%Y%m%d-%H%M%S")

  echo "⚠️  $dst already exists. Choose action:"
  echo "  [s] skip"
  echo "  [r] rename to $dst.bak.$ts"
  echo "  [b] move to dotfiles/backup/"
  echo "  [o] overwrite"
  echo "  [a] abort"

  read -rp "> " choice

  case "$choice" in
    s) return 1 ;;
    r)
      mv "$dst" "$dst.bak.$ts"
      ;;
    b)
      mkdir -p "$DOTFILES/backup"
      mv "$dst" "$DOTFILES/backup/$(basename "$dst").$ts"
      ;;
    o)
      rm -rf "$dst"
      ;;
    a)
      echo "Aborted."
      exit 1
      ;;
    *)
      echo "Invalid choice."
      ask_on_conflict "$dst"
      ;;
  esac
}


link() {
  local src="$DOTFILES/$1"
  local dst="$HOME/.$2"

  [[ ! -e "$src" ]] && { echo "✗ source missing: $src"; return; }

  if [[ -e "$dst" && ! -L "$dst" ]]; then
    ask_on_conflict "$dst" || return
  fi

  ln -sf "$src" "$dst"
  echo "✓ linked $dst"

  [[ -x "$src" ]] && chmod u+x "$dst"
}

link bash/bashrc bashrc
link bash/profile bash_profile
link bash/aliases bash_aliases
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

link bash/bashrc bashrc
link bash/profile bash_profile
link bash/aliases bash_aliases
link git/gitconfig gitc

. "$HOME/.bashrc"
