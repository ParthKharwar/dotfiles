# dotfiles

My shell setup: zsh + oh-my-zsh, [starship](https://starship.rs) prompt, a handful of
CLI tools, and a tmux config. Everything installs user-local — no `sudo` required.

## What's in here

- **zsh**: oh-my-zsh with `zsh-autosuggestions` + `zsh-syntax-highlighting`, tuned
  history (shared, deduped, `HIST_IGNORE_SPACE` for one-off/secret commands),
  `AUTO_CD`, and cached `compinit` for fast startup.
- **starship**: replaces the old spaceship theme (config in `starship.toml`,
  same layout: time, user, dir, git, prompt char).
- **fzf**: `Ctrl-T` fuzzy file finder, `Alt-C` fuzzy cd.
- **zoxide**: `z <partial name>` jumps to a frecency-ranked directory.
- **direnv**: per-project env vars via a repo's `.envrc`.
- **atuin**: SQLite-backed shell history with fuzzy search — rebinds `Ctrl-R`.
- **eza / bat**: nicer `ls`/`cat` (aliased directly — see `.zshrc`).
- **tmux**: `Ctrl-a` prefix, vi-style pane nav/copy, mouse on, true color,
  session persistence via tmux-resurrect/continuum (config in `tmux.conf`).

## Install on a new machine

```sh
git clone https://github.com/ParthKharwar/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
exec zsh
```

The installer is idempotent — re-run it any time. It installs oh-my-zsh and its
plugins, downloads starship/zoxide/direnv/atuin/fzf/eza/bat into `~/.local/bin`
(no package manager, no sudo), clones tmux's plugin manager (TPM), and symlinks
`.zshrc`, `starship.toml`, and `tmux.conf` into place (backing up any existing
real files to `*.backup`).

**One manual step after installing:** open tmux and press `Ctrl-a` then `I` to
have TPM fetch the tmux plugins (tmux-sensible, tmux-yank, tmux-resurrect,
tmux-continuum). TPM only auto-installs plugins on that keypress, not on clone.

`tmux` itself is assumed to already be installed via your system package
manager (`apt install tmux` / `brew install tmux`) — it's not something this
installer manages, since it's a system-level dependency rather than a
user-local tool.

## Machine-specific config

Put private or per-machine settings (work env vars, secrets, extra paths) in
`~/.zshrc.local` — it's sourced automatically and never tracked here.

## Updating

Edit the files in `~/dotfiles` (symlinked into place), then commit and push.
On other machines: `git -C ~/dotfiles pull`.
