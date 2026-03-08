# ============================================================
# Options
# ============================================================
setopt AUTO_CD              # cd without cd command
setopt AUTO_PUSHD           # push directory to stack on cd
setopt PUSHD_IGNORE_DUPS    # don't push duplicates
setopt CORRECT              # command correction
setopt HIST_IGNORE_DUPS     # ignore duplicate history
setopt HIST_IGNORE_ALL_DUPS # remove older duplicate entries
setopt HIST_REDUCE_BLANKS   # trim blanks in history
setopt HIST_VERIFY          # expand history before executing
setopt SHARE_HISTORY        # share history across sessions
setopt INC_APPEND_HISTORY   # append to history incrementally
setopt EXTENDED_HISTORY     # save timestamps in history
setopt NO_BEEP              # disable beep

HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# ============================================================
# Completion
# ============================================================
autoload -Uz compinit
if [[ -n "$ZDOTDIR/.zcompdump"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion::complete:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"
zstyle ':completion::complete:*' use-cache on

# ============================================================
# Prompt (Starship)
# ============================================================
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# ============================================================
# Key bindings
# ============================================================
bindkey -e  # emacs keybindings
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left
bindkey '^[[3~' delete-char      # Delete key

# ============================================================
# Aliases
# ============================================================

# ls -> eza
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first --git'
  alias lt='eza --tree --icons --group-directories-first'
else
  alias ls='ls -G'
  alias ll='ls -lh'
  alias la='ls -lah'
fi

# cat -> bat
if command -v bat &>/dev/null; then
  alias cat='bat --style=plain'
fi

# cd -> zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi

# grep -> ripgrep
if command -v rg &>/dev/null; then
  alias grep='rg'
fi

# General
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias q='exit'
alias reload='exec zsh'
alias path='echo $PATH | tr ":" "\n"'

# Editor
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gl='git lg'
alias gco='git checkout'
alias gbr='git branch'
alias gdf='git diff'

# Homebrew
alias brew-update='brew update && brew upgrade && brew cleanup'
alias brew-dump='brew bundle dump --force --file="$DOTFILES_DIR/macos/homebrew/Brewfile"'

# macOS specific
alias rmds='find . -name ".DS_Store" -delete'
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias ip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ports='lsof -nP -iTCP -sTCP:LISTEN'

# ============================================================
# Functions
# ============================================================

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1"   ;;
      *.tar.gz)  tar xzf "$1"   ;;
      *.tar.xz)  tar xJf "$1"   ;;
      *.tar.zst) tar --zstd -xf "$1" ;;
      *.bz2)     bunzip2 "$1"   ;;
      *.gz)      gunzip "$1"    ;;
      *.zip)     unzip "$1"     ;;
      *.7z)      7z x "$1"      ;;
      *.rar)     unrar x "$1"   ;;
      *)         echo "Unknown archive: $1" ;;
    esac
  else
    echo "'$1' is not a file"
  fi
}

# Show PATH entries one per line
showpath() {
  echo "$PATH" | tr ':' '\n' | nl
}

# fzf-powered directory jump
if command -v fzf &>/dev/null; then
  fzf-cd() {
    local dir
    dir=$(find "${1:-.}" -type d 2>/dev/null | fzf +m) && cd "$dir"
  }
  bindkey -s '^F' 'fzf-cd\n'
fi

# ============================================================
# Plugin Manager (sheldon)
# ============================================================
if command -v sheldon &>/dev/null; then
  eval "$(sheldon source)"
fi

# ============================================================
# Tool integrations
# ============================================================

# mise (runtime version manager)
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# fzf
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

# ============================================================
# Local overrides
# ============================================================
[[ -f "$ZDOTDIR/.zshrc.local" ]] && source "$ZDOTDIR/.zshrc.local"
