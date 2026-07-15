#!/usr/bin/env bash
# Sets up zsh + oh-my-zsh + plugins + spaceship theme, and links .zshrc.
# Safe to re-run: skips anything already installed.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

# 1. oh-my-zsh
if [ ! -d "$ZSH_DIR" ]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed."
fi

# 2. Plugins and theme
clone() {
  local url="$1" dest="$2"
  if [ ! -d "$dest" ]; then
    echo "Cloning $url..."
    git clone --depth=1 "$url" "$dest"
  else
    echo "$(basename "$dest") already installed."
  fi
}

clone https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone https://github.com/spaceship-prompt/spaceship-prompt \
  "$ZSH_CUSTOM/themes/spaceship-prompt"

ln -sfn "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" \
  "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

# 3. Link .zshrc (back up an existing real file first)
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  echo "Backing up existing ~/.zshrc to ~/.zshrc.backup"
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi
ln -sfn "$DOTFILES/.zshrc" "$HOME/.zshrc"

echo "Done. Start a new shell or run: exec zsh"
