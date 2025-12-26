#!/usr/bin/env bash
set -euo pipefail

# git clone https://github.com/totallycrazy/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./install.sh


DOTFILES="$HOME/dotfiles"

cd "$DOTFILES"
git pull

# ------------------------------------------------------------
# PATH bootstrap
# ------------------------------------------------------------

if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

# ------------------------------------------------------------
# sudo detection
# ------------------------------------------------------------

HAS_SUDO=false
if command -v sudo >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null; then
    HAS_SUDO=true
  else
    echo "⚠️  sudo installed but not usable without password"
  fi
else
  echo "⚠️  sudo not available"
fi

# ------------------------------------------------------------
# conflict handling
# ------------------------------------------------------------

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
    r) mv "$dst" "$dst.bak.$ts" ;;
    b)
      mkdir -p "$DOTFILES/backup"
      mv "$dst" "$DOTFILES/backup/$(basename "$dst").$ts"
      ;;
    o) rm -rf "$dst" ;;
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

# ------------------------------------------------------------
# package installation (idempotent)
# ------------------------------------------------------------

PACKAGES=(
  curl wget git magic-wormhole fd-find sd nnn micro broot
  lazygit trippy xh yq duf gdu du-dust lnav procs gping
  fzf zoxide ripgrep bat lsd eza dtrx translate-shell
  most npm
)

missing_packages=()

for pkg in "${PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" >/dev/null 2>&1; then
    missing_packages+=("$pkg")
  fi
done

if [[ ${#missing_packages[@]} -gt 0 ]]; then
  if [[ "$HAS_SUDO" == true ]]; then
    echo "Installing missing packages:"
    printf '  - %s\n' "${missing_packages[@]}"
    sudo apt update
    sudo apt install -y "${missing_packages[@]}"
  else
    echo "⚠️  Missing packages, but no sudo access:"
    printf '  - %s\n' "${missing_packages[@]}"
    echo "Skipping package installation."
  fi
else
  echo "✓ All packages already installed"
fi

# ------------------------------------------------------------
# npm globals (non-fatal)
# ------------------------------------------------------------

if command -v npm >/dev/null 2>&1; then
  npm list -g @microsoft/inshellisense >/dev/null 2>&1 || \
    npm install -g @microsoft/inshellisense
fi

# ------------------------------------------------------------
# Debian naming sanity fixes
# ------------------------------------------------------------

mkdir -p "$HOME/.local/bin"

command -v fdfind >/dev/null && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
command -v batcat >/dev/null && ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"

# ------------------------------------------------------------
# dotfiles
# ------------------------------------------------------------

link bash/bashrc bashrc
link bash/profile bash_profile
link bash/aliases bash_aliases
# link git/gitconfig git

# ------------------------------------------------------------
# reload shell config
# ------------------------------------------------------------

. "$HOME/.bashrc"
