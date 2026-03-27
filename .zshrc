# ~/.zshrc — agent-centric terminal build
# Goal: zsh/CLI drive project navigation, git change review and opening files in
# a running Neovim inside tmux. Neovim stays an editor, tmux stays the shell orchestrator.
# Base preserved: Zinit, zsh-vi-mode, zsh-syntax-highlighting,
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
# tmux-open-nvim helper script (available right after TPM plugin install)
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
alias c='clear'
alias lg='lazygit'
alias k='kubectl'
alias tf='terraform'
alias d='docker'
alias dc='docker compose'
alias j='just'
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

# Zinit annexes (current setup preserved)
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
# PLUGINS — keep existing base, add only workflow helpers
# -----------------------------------------------------------------------------
# vi mode
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

# fzf-tab — keep in the correct order
zinit ice depth=1
zinit light Aloxaf/fzf-tab

# widget wrappers / interactive helpers
zinit ice depth=1
zinit light zsh-users/zsh-autosuggestions

zinit ice depth=1
zinit light hlissner/zsh-autopair


# history search — load after syntax-highlighting
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
zstyle ':fzf-tab:*' fzf-flags --with-nth=2 --bind=tab:accept,ctrl-j:down,ctrl-k:up,alt-j:down,alt-k:up --cycle
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
if (( $+commands[ftb-tmux-popup] )); then
  zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi

# preview logic:
# - file/dir completions => tree or file preview
# - option/subcommand completions => selected completion description in preview pane
zstyle ':fzf-tab:*' fzf-preview '
  if [[ -n "$realpath" && -d "$realpath" ]]; then
    if command -v eza >/dev/null 2>&1; then
      eza --tree --level=2 --icons --color=always "$realpath" | head -200
    else
      ls -la "$realpath"
    fi
  elif [[ -n "$realpath" && -f "$realpath" ]]; then
    if command -v bat >/dev/null 2>&1; then
      bat --style=numbers --color=always --line-range :300 "$realpath"
    else
      sed -n "1,200p" "$realpath"
    fi
  else
    print -P "%F{81}${group:-completion}%f"
    [[ -n "$word" ]] && print -P "%B$word%b"
    [[ -n "$desc" ]] && print -r -- "$desc"
  fi
'
# -----------------------------------------------------------------------------
# AI terminal workflow: shell plugins + richer completion UI
# -----------------------------------------------------------------------------

# jump to git repo root
zinit ice depth=1
zinit light mollifier/cd-gitroot

# clipboard bridge
zinit ice depth=1
zinit light zpm-zsh/clipboard

# vim-style registers in shell
zinit ice depth=1
zinit light zsh-vi-more/evil-registers

# notify when long commands finish
zinit ice depth=1
zinit light MichaelAquilina/zsh-auto-notify

# faster syntax highlighting
# УБЕРИТЕ zsh-users/zsh-syntax-highlighting, если он уже подключен,
# и используйте только fast-syntax-highlighting
zinit ice depth=1
zinit light zdharma-continuum/fast-syntax-highlighting


if command -v carapace >/dev/null 2>&1; then
  source <(carapace _carapace)
fi

# -----------------------------------------------------------------------------
# Удобные алиасы под root repo
# -----------------------------------------------------------------------------

alias cdu='cd-gitroot'

# -----------------------------------------------------------------------------
# EXTERNAL TOOLS INIT (guarded)
# -----------------------------------------------------------------------------
(( $+commands[tmuxifier] )) && eval "$(tmuxifier init -)"
(( $+commands[fzf] )) && eval "$(fzf --zsh)"
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[thefuck] )) && eval "$(thefuck --alias fuck)"
(( $+commands[starship] )) && eval "$(starship init zsh)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
(( $+commands[just] )) && source <(just --completions zsh 2>/dev/null)

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
# Yazi cwd jump (kept)
function y() {
  local tmp="$(mktemp -t 'yazi-cwd.XXXXXX')" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

function _repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || print -r -- "$PWD"
}

function croot() {
  cd "$(_repo_root)" || return
}

function _preview_file_or_tree() {
  local target="$1"
  if [[ -d "$target" ]]; then
    if (( $+commands[eza] )); then
      eza --tree --level=2 --icons --color=always "$target" | head -200
    else
      ls -la "$target"
    fi
  else
    if (( $+commands[bat] )); then
      bat --style=numbers --color=always --line-range :300 "$target"
    else
      sed -n '1,200p' "$target"
    fi
  fi
}

function _open_in_editor() {
  (( $# )) || return 1

  if [[ -n "$TMUX" ]] && (( $+commands[ton] )); then
    local target
    for target in "$@"; do
      ton "$target"
    done
  else
    nvim "$@"
  fi
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

# project picker: cd in plain shell, enter/create session when outside tmux
function p() {
  local dir name
  if (( $+commands[zoxide] )); then
    dir=$(zoxide query -l | fzf --prompt='project > ' --height=60% --preview 'eza --tree --level=2 --icons --color=always {} | head -200') || return
  else
    dir=$(fd --type d --hidden --follow --exclude .git . "$HOME" 2>/dev/null | fzf --prompt='project > ' --height=60% --preview 'eza --tree --level=2 --icons --color=always {} | head -200') || return
  fi

  if [[ -n "$TMUX" ]]; then
    cd "$dir" || return
  else
    name=$(basename "$dir" | tr '.:' '__')
    tmux new-session -A -s "$name" -c "$dir"
  fi
}

# backward-compatible name
function tproj() {
  p "$@"
}

# quick edit current dir in nvim
function nv() {
  nvim "${1:-.}"
}

# fast file finder rooted in current repo if possible
function ffv() {
  local root file
  root="$(_repo_root)"
  file=$(fd --type f --hidden --follow --exclude .git . "$root" 2>/dev/null | \
    fzf --prompt='file > ' \
        --preview 'if [ -d {} ]; then eza --tree --level=2 --icons --color=always {} | head -200; elif command -v bat >/dev/null 2>&1; then bat --style=numbers --color=always --line-range :300 {}; else sed -n "1,200p" {}; fi') || return
  [[ -n "$file" ]] || return
  _open_in_editor "$file"
}

# ripgrep + fzf + open result in editor at line
function rgv() {
  local root query selected file line
  root="$(_repo_root)"
  query="$*"

  if [[ -n "$query" ]]; then
    selected=$(rg --line-number --no-heading --smart-case --hidden --glob '!.git' -- "$query" "$root" 2>/dev/null | \
      fzf --ansi --delimiter : --preview 'file=$(echo {} | cut -d: -f1); line=$(echo {} | cut -d: -f2); if command -v bat >/dev/null 2>&1; then bat --style=numbers --color=always --highlight-line "$line" --line-range "$(( line > 40 ? line - 40 : 1 )):$(( line + 80 ))" "$file"; else sed -n "1,200p" "$file"; fi') || return
  else
    selected=$(rg --line-number --no-heading --smart-case --hidden --glob '!.git' -- '.' "$root" 2>/dev/null | \
      fzf --ansi --delimiter : --disabled --query '' --prompt='rg > ' \
          --bind 'change:reload:rg --line-number --no-heading --smart-case --hidden --glob "!.git" -- {q} "'"$root"'" 2>/dev/null || true' \
          --preview 'file=$(echo {} | cut -d: -f1); line=$(echo {} | cut -d: -f2); if command -v bat >/dev/null 2>&1; then bat --style=numbers --color=always --highlight-line "$line" --line-range "$(( line > 40 ? line - 40 : 1 )):$(( line + 80 ))" "$file"; else sed -n "1,200p" "$file"; fi') || return
  fi

  file=${selected%%:*}
  line=${${selected#*:}%%:*}
  [[ -n "$file" && -n "$line" ]] || return
  _open_in_editor "$file:$line"
}

# ★ agent-diff: show ONLY what changed since last commit (what the agent did)
function adiff() {
  local root
  root=$(groot) || return 1
  if (( $+commands[delta] )); then
    git -C "$root" diff --color=always | delta --paging=always --side-by-side
  else
    git -C "$root" diff --color=always | less -R
  fi
}

# ★ agent-review: pick changed files, see side-by-side diff, open to edit
function areview() {
  local root
  root=$(groot) || return 1
  local count=$(git -C "$root" status --porcelain | wc -l | tr -d ' ')
  print -P "%F{cyan}═══ Agent Review: $count changed files ═══%f"
  git -C "$root" diff --stat --color=always
  print ""
  gchangedv
}

# ★ agent-accept: stage + commit everything (after reviewing agent's work)
function aaccept() {
  local root msg
  root=$(groot) || return 1
  msg="${*:-agent: apply changes}"
  git -C "$root" add -A
  git -C "$root" commit -m "$msg"
  print -P "%F{green}✓ Committed: $msg%f"
}

# ★ agent-reject: discard all unstaged changes
function areject() {
  local root
  root=$(groot) || return 1
  print -P "%F{red}⚠ This will discard ALL uncommitted changes.%f"
  read -q "confirm?Are you sure? (y/N) " || { print ""; return }
  print ""
  git -C "$root" checkout -- .
  git -C "$root" clean -fd
  print -P "%F{yellow}✗ Changes discarded%f"
}

function groot() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    print -u2 'not inside a git repository'
    return 1
  }
  print -r -- "$root"
}

function gcd() {
  cd "$(groot)" || return
}

function gchanged() {
  local root line path
  root=$(groot) || return 1

  git -C "$root" status --porcelain=v1 --untracked-files=all | while IFS= read -r line; do
    path=${line#?? }
    if [[ "$path" == *' -> '* ]]; then
      print -r -- "${path##* -> }"
    else
      print -r -- "$path"
    fi
  done | awk 'NF && !seen[$0]++'
}

function gchangedf() {
  local root
  root=$(groot) || return 1

  gchanged | fzf -m \
    --prompt='changed > ' \
    --preview-window=right,65%,wrap \
    --preview "root=${(q)root}; file={}; if git -C \"\$root\" diff --quiet -- \"\$file\" 2>/dev/null; then if [ -f \"\$root/\$file\" ]; then if command -v bat >/dev/null 2>&1; then bat --style=numbers --color=always --line-range :300 \"\$root/\$file\"; else sed -n '1,200p' \"\$root/\$file\"; fi; fi; else if command -v delta >/dev/null 2>&1; then git -C \"\$root\" diff --color=always -- \"\$file\" | delta --paging=never; else git -C \"\$root\" diff --color=always -- \"\$file\"; fi; fi"
}

function gchangedv() {
  local root raw
  local -a files absfiles
  root=$(groot) || return 1
  raw=$(gchangedf) || return
  files=("${(@f)raw}")
  (( ${#files[@]} )) || return

  for file in "${files[@]}"; do
    absfiles+=("$root/$file")
  done

  _open_in_editor "${absfiles[@]}"
}

function gdiffv() {
  local root file
  root=$(groot) || return 1
  file=$(gchangedf | head -n 1) || return
  [[ -n "$file" ]] || return

  if (( $+commands[delta] )); then
    git -C "$root" diff --color=always -- "$file" | delta --paging=always
  else
    git -C "$root" diff --color=always -- "$file" | less -R
  fi
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
