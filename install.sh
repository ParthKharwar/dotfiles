#!/usr/bin/env bash
# Sets up zsh + oh-my-zsh + plugins + starship + cli tools + tmux, and links configs.
# Everything installs user-local (no sudo). Safe to re-run: skips anything already installed.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN" "$HOME/.config"

# 1. oh-my-zsh
if [ ! -d "$ZSH_DIR" ]; then
  echo "Installing oh-my-zsh..."
  RUNZSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed."
fi

# 2. zsh plugins
clone() {
  local url="$1" dest="$2"
  if [ ! -d "$dest" ]; then
    echo "Cloning $(basename "$dest")..."
    git clone --depth=1 "$url" "$dest"
  else
    echo "$(basename "$dest") already installed."
  fi
}

clone https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# 3. CLI tools — user-local, no sudo
if ! command -v starship >/dev/null 2>&1; then
  echo "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir "$LOCAL_BIN" -y
else
  echo "starship already installed."
fi

if ! command -v zoxide >/dev/null 2>&1; then
  echo "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh \
    | BIN_DIR="$LOCAL_BIN" sh
else
  echo "zoxide already installed."
fi

if ! command -v direnv >/dev/null 2>&1; then
  echo "Installing direnv..."
  curl -sfL https://direnv.net/install.sh | bin_path="$LOCAL_BIN" bash
else
  echo "direnv already installed."
fi

if [ ! -d "$HOME/.atuin/bin" ]; then
  echo "Installing atuin..."
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --no-modify-path
else
  echo "atuin already installed."
fi

if ! command -v fzf >/dev/null 2>&1; then
  echo "Installing fzf..."
  clone https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --bin --no-update-rc
  cp "$HOME/.fzf/bin/fzf" "$LOCAL_BIN/fzf"
else
  echo "fzf already installed."
fi

# asset_pattern may contain the literal placeholder VER, substituted with the resolved tag.
install_github_release_bin() {
  local repo="$1" binname="$2" asset_pattern="$3"
  if command -v "$binname" >/dev/null 2>&1; then
    echo "$binname already installed."
    return
  fi
  echo "Installing $binname..."
  local tmpdir
  tmpdir="$(mktemp -d)"
  local api_resp
  api_resp="$(curl -sL "https://api.github.com/repos/$repo/releases/latest")"
  local ver
  ver="$(printf '%s\n' "$api_resp" | grep -m1 '"tag_name"' | cut -d'"' -f4)"
  if [ -z "$ver" ]; then
    echo "Could not resolve latest release for $repo" >&2
    rm -rf "$tmpdir"
    return 1
  fi
  local asset="${asset_pattern//VER/$ver}"
  local url="https://github.com/$repo/releases/download/${ver}/${asset}"
  curl -sL -o "$tmpdir/asset.tar.gz" "$url"
  tar xf "$tmpdir/asset.tar.gz" -C "$tmpdir"
  find "$tmpdir" -type f -name "$binname" -exec cp {} "$LOCAL_BIN/$binname" \;
  chmod +x "$LOCAL_BIN/$binname"
  rm -rf "$tmpdir"
}

install_github_release_bin "eza-community/eza" "eza" "eza_x86_64-unknown-linux-gnu.tar.gz"
install_github_release_bin "sharkdp/bat" "bat" "bat-VER-x86_64-unknown-linux-gnu.tar.gz"

# 4. tmux plugin manager
clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# 5. Symlink configs (back up an existing real file first)
link() {
  local src="$1" dest="$2"
  if [ -f "$dest" ] && [ ! -L "$dest" ]; then
    echo "Backing up existing $dest to $dest.backup"
    mv "$dest" "$dest.backup"
  fi
  ln -sfn "$src" "$dest"
}

link "$DOTFILES/.zshrc" "$HOME/.zshrc"
link "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
link "$DOTFILES/tmux.conf" "$HOME/.tmux.conf"

echo "Done. Start a new shell (exec zsh), then open tmux and press prefix (Ctrl-a) + I to fetch tmux plugins."
