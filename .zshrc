# Performance optimizations
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

# Cache completions aggressively: only rebuild the dump if it's >24h old.
# (Portable across Linux/macOS — the old `stat -f` check was BSD-only.)
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY       # save timestamps
setopt SHARE_HISTORY          # share across concurrent sessions
setopt HIST_IGNORE_DUPS       # skip immediate repeated commands
setopt HIST_IGNORE_ALL_DUPS   # remove older dupes when a new one is added
setopt HIST_IGNORE_SPACE       # leading space = don't record (secrets, one-offs)
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # expand history refs into the buffer before running

# Nav / correction
setopt AUTO_CD                # `foo` == `cd foo` for directories
setopt CORRECT                # suggest fixes for command typos

# Path update to include local packages
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end

# Theme is handled by starship (see below) instead of an oh-my-zsh theme.
ZSH_THEME=""

zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 30

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Aliases
alias zshconfig="nano ~/.zshrc"
alias ohmyzsh="nano ~/.oh-my-zsh"

# eza / bat
alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons'
alias la='eza -la --group-directories-first --icons'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'

# Autosuggest settings
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#663399,standout"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Custom function: add-commit-push
acp() {
  git add -A && \
  git commit -m "$1" && \
  git push origin HEAD
}

# fzf: Ctrl-T (find files), Alt-C (cd into dir). Ctrl-R is rebound by atuin below.
[[ -f ~/.fzf/shell/completion.zsh ]] && source ~/.fzf/shell/completion.zsh
[[ -f ~/.fzf/shell/key-bindings.zsh ]] && source ~/.fzf/shell/key-bindings.zsh

# zoxide: `z <partial name>` jumps to a frecency-ranked directory match
eval "$(zoxide init zsh)"

# direnv: per-project env vars via .envrc
eval "$(direnv hook zsh)"

# atuin: SQLite-backed shell history with fuzzy search (rebinds Ctrl-R)
[[ -f "$HOME/.atuin/bin/env" ]] && . "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# starship prompt (config: ~/.config/starship.toml, symlinked from this repo)
eval "$(starship init zsh)"

# Machine-specific config (work env vars, secrets, one-off paths).
# Keep anything private here — this file is NOT tracked in the dotfiles repo.
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
