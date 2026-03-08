# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (Apple Silicon)
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
export MANPATH="$HOMEBREW_PREFIX/share/man:${MANPATH:-}"
export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Language
export LANG="ja_JP.UTF-8"
export LC_ALL="ja_JP.UTF-8"

# ZDOTDIR
export ZDOTDIR="$HOME/.config/zsh"

# Rust / Cargo
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# Local overrides (machine-specific, not tracked by git)
[[ -f "$HOME/.zshenv.local" ]] && . "$HOME/.zshenv.local"
