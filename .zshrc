# ~/.zshrc — professional Arch + Neovim + tmux oriented build
# Основа сохранена: Zinit, zsh-vi-mode, zsh-syntax-highlighting,
# zsh-completions, zsh-autosuggestions, Aloxaf/fzf-tab, starship, zoxide,
# fzf, tmuxifier, thefuck, yazi-function, eza aliases.

# -----------------------------------------------------------------------------
# BASE ENV
# -----------------------------------------------------------------------------
export EDITOR='nvim'
export VISUAL='nvim'
export MANPAGER='nvim +Man!'
export LESS='-R'
export PAGER='less'

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export ZDOTDIR="${ZDOTDIR:-$HOME}"

# user paths
export PATH="$HOME/tools/llvm-project/build/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/tools/llvm-project/build/lib:$LD_LIBRARY_PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.tmuxifier/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
# tmux-open-nvim helper script (становится доступен сразу после установки TPM-плагина)
export PATH="$HOME/.tmux/plugins/tmux-open-nvim/scripts:$PATH"

# keep PATH/fpath unique
typeset -U path fpath

# -----------------------------------------------------------------------------
# HISTORY
# -----------------------------------------------------------------------------
export HISTFILE="${HISTFILE:-$HOME/.histfile}"
HISTSIZE=200000
SAVEHIST=200000
HISTDUP=erase

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_FCNTL_LOCK
setopt HIST_LEX_WORDS

# -----------------------------------------------------------------------------
# SHELL BEHAVIOR
# -----------------------------------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt NO_FLOW_CONTROL

KEYTIMEOUT=1

# -----------------------------------------------------------------------------
# ALIASES
# -----------------------------------------------------------------------------
# eza
alias ls='eza --icons --git'
alias ll='eza -lh --icons --git --header'
alias la='eza -lah --icons --git --header'
alias lt='eza --tree --level=3 --icons --git'
alias l.='eza -a | grep -E "^\."'

# editors / tooling
alias svim='sudo -E nvim'
alias c='clear'
alias lg='lazygit'
alias k='kubectl'
alias tf='terraform'
alias d='docker'
alias dc='docker compose'
alias ta='tmux attach -t'
alias tls='tmux ls'
alias ts='tmux new-session -A -s'
alias vp='nmcli connection up'
alias vd='nmcli connection down'

# safer defaults
alias mkdir='mkdir -p'
alias cp='cp -i'
alias mv='mv -i'

# -----------------------------------------------------------------------------
# FZF / SEARCH / NAVIGATION
# -----------------------------------------------------------------------------
export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"
export _ZO_FZF_OPTS='--height=60% --layout=reverse --border --cycle'

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS=$'--height=60% --layout=reverse --border --cycle --preview-window=right,60%,wrap\
  --bind=ctrl-j:down,ctrl-k:up,alt-j:down,alt-k:up,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down,ctrl-f:preview-page-down,ctrl-b:preview-page-up'

# default preview strategy
if (( $+commands[bat] )); then
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :300 {}'"
else
  export FZF_CTRL_T_OPTS="--preview 'sed -n 1,200p {}'"
fi

if (( $+commands[eza] )); then
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {} | head -200'"
fi

# -----------------------------------------------------------------------------
# ZINIT
# -----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "${ZINIT_HOME:h}"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinit annexes (твои текущие сохраняются)
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# -----------------------------------------------------------------------------
# COMPLETION STYLE — configure BEFORE compinit/fzf-tab
# -----------------------------------------------------------------------------
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format '%F{yellow}-- no matches found --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' rehash true

# better completion behavior for common dev tools
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:git-switch:*' sort false
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:kubectl:*' list-grouped false

# -----------------------------------------------------------------------------
# PLUGINS — KEEP EXISTING, ONLY ADD
# fzf-tab must be loaded after compinit and before widget wrappers like autosuggestions.
# zsh-history-substring-search should be loaded after zsh-syntax-highlighting.
# -----------------------------------------------------------------------------

# vi mode (existing)
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# completions / utility plugins that enrich fpath before compinit
zinit ice depth=1
zinit light zsh-users/zsh-completions

zinit ice depth=1
zinit light wfxr/forgit

zinit ice depth=1
zinit light MichaelAquilina/zsh-you-should-use


zinit ice depth=1
zinit light chrissicool/zsh-256color

zinit ice depth=1
zinit light Tarrasch/zsh-bd

# completion engine
autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump-${ZSH_VERSION}"
zmodload zsh/complist

# fzf-tab — existing, keep it in the correct order
zinit ice depth=1
zinit light Aloxaf/fzf-tab

# widget wrappers / interactive helpers
zinit ice depth=1
zinit light zsh-users/zsh-autosuggestions

zinit ice depth=1
zinit light hlissner/zsh-autopair

# highlighting — existing
zinit ice depth=1
zinit light zsh-users/zsh-syntax-highlighting

# history search — add after syntax-highlighting
zinit ice depth=1
zinit light zsh-users/zsh-history-substring-search

# -----------------------------------------------------------------------------
# PLUGIN CONFIG
# -----------------------------------------------------------------------------
# zsh-vi-mode
ZVM_VI_EDITOR=nvim
ZVM_ESCAPE_KEYTIMEOUT=0.03
ZVM_CURSOR_STYLE_ENABLED=true

# autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=30
ZSH_AUTOSUGGEST_USE_ASYNC=true

# you-should-use
export YSU_MESSAGE_POSITION='after'
export YSU_MODE='ALL'

# forgit
export FORGIT_FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"

# fzf-tab
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept' 'ctrl-space:toggle+down'
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept,ctrl-j:down,ctrl-k:up,alt-j:down,alt-k:up --cycle
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
if (( $+commands[ftb-tmux-popup] )); then
  zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi

if (( $+commands[eza] )); then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=2 --icons --color=always $realpath | head -200'
fi
if (( $+commands[eza] && $+commands[bat] )); then
  zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -d $realpath ]] && eza --tree --level=2 --icons --color=always $realpath | head -200 || bat --style=numbers --color=always --line-range :300 $realpath'
elif (( $+commands[bat] )); then
  zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -d $realpath ]] && ls -la $realpath || bat --style=numbers --color=always --line-range :300 $realpath'
fi

# -----------------------------------------------------------------------------
# EXTERNAL TOOLS INIT (guarded)
# -----------------------------------------------------------------------------
(( $+commands[tmuxifier] )) && eval "$(tmuxifier init -)"
(( $+commands[fzf] )) && eval "$(fzf --zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[thefuck] )) && eval "$(thefuck --alias fuck)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

# history substring search
bindkey -M viins "$terminfo[kcuu1]" history-substring-search-up
bindkey -M viins "$terminfo[kcud1]" history-substring-search-down
bindkey -M vicmd "$terminfo[kcuu1]" history-substring-search-up
bindkey -M vicmd "$terminfo[kcud1]" history-substring-search-down

bindkey -M viins '^[[A' history-substring-search-up
bindkey -M viins '^[[B' history-substring-search-down
bindkey -M vicmd '^[[A' history-substring-search-up
bindkey -M vicmd '^[[B' history-substring-search-down

bindkey -M viins '^P' history-substring-search-up
bindkey -M viins '^N' history-substring-search-down

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down


# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------
# Yazi cwd jump (existing, kept)
function y() {
  local tmp="$(mktemp -t 'yazi-cwd.XXXXXX')" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# fuzzy dir sources: zoxide first, then filesystem scan
function _dev_dirs() {
  {
    (( $+commands[zoxide] )) && zoxide query -l 2>/dev/null
    fd --type d --hidden --follow --exclude .git . "${1:-.}" 2>/dev/null
  } | awk 'NF && !seen[$0]++'
}

# fuzzy cd into project or directory tree
function cdf() {
  local dir
  dir=$(_dev_dirs "${1:-.}" | fzf --prompt='cd > ' --preview 'eza --tree --level=2 --icons --color=always {} | head -200') || return
  cd "$dir" || return
}

# zoxide + fzf + eza jump
function zz() {
  local dir
  if (( ! $+commands[zoxide] )); then
    cdf "$@"
    return
  fi
  dir=$(zoxide query -l | fzf --prompt='zoxide > ' --preview 'eza --tree --level=2 --icons --color=always {} | head -200') || return
  cd "$dir" || return
}

# quick edit current dir in nvim
function nv() {
  nvim "${1:-.}"
}

# tmux project entry using zoxide/sessionx friendly directories
function tproj() {
  local dir name
  if (( $+commands[zoxide] )); then
    dir=$(zoxide query -l | fzf --prompt='project > ' --height=60% --preview 'eza --tree --level=2 --icons --color=always {} | head -200') || return
  else
    dir=$(fd --type d --hidden --follow --exclude .git . "$HOME" 2>/dev/null | fzf --prompt='project > ' --height=60% --preview 'eza --tree --level=2 --icons --color=always {} | head -200') || return
  fi
  name=$(basename "$dir" | tr '.:' '__')
  tmux new-session -A -s "$name" -c "$dir"
}

# tmux-which-key from zsh vicmd mode (leader-like <Space>)
function tmux_which_key_widget() {
  [[ -n "$TMUX" ]] || return 0
  zle -I
  tmux show-wk-menu-root >/dev/null 2>&1
  zle redisplay
}
zle -N tmux_which_key_widget

function zvm_after_lazy_keybindings() {
  zvm_define_widget tmux_which_key_widget
  zvm_bindkey vicmd ' ' tmux_which_key_widget
  zvm_bindkey vicmd '^R' fzf-history-widget
  zvm_bindkey vicmd '^T' fzf-file-widget
  zvm_bindkey vicmd '^[c' fzf-cd-widget

  zvm_bindkey viins "$terminfo[kcuu1]" history-substring-search-up
  zvm_bindkey viins "$terminfo[kcud1]" history-substring-search-down
  zvm_bindkey vicmd "$terminfo[kcuu1]" history-substring-search-up
  zvm_bindkey vicmd "$terminfo[kcud1]" history-substring-search-down
}

# -----------------------------------------------------------------------------
# LOCAL OVERRIDES
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
