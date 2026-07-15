# dotfiles

My zsh + oh-my-zsh setup: [spaceship prompt](https://github.com/spaceship-prompt/spaceship-prompt),
autosuggestions, syntax highlighting, and startup-speed tweaks.

## Install on a new machine

```sh
git clone https://github.com/pkharwar/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
exec zsh
```

The installer is idempotent — re-run it any time. It installs oh-my-zsh if
missing, clones the plugins/theme, and symlinks `~/.zshrc` to this repo
(backing up any existing file to `~/.zshrc.backup`).

## Machine-specific config

Put private or per-machine settings (work env vars, secrets, extra paths) in
`~/.zshrc.local` — it's sourced automatically and never tracked here.

## Updating

Edit `~/dotfiles/.zshrc` (which is what `~/.zshrc` points to), then commit and
push. On other machines: `git -C ~/dotfiles pull`.
