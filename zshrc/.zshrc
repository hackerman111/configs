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
# -----------------------------------------------------------------------------
# ARGC COMPLETIONS
# -----------------------------------------------------------------------------
export ARGC_COMPLETIONS_ROOT="$XDG_DATA_HOME/argc-completions"

if [[ -d "$ARGC_COMPLETIONS_ROOT" ]]; then
  export ARGC_COMPLETIONS_PATH="$ARGC_COMPLETIONS_ROOT/completions/linux:$ARGC_COMPLETIONS_ROOT/completions"
  export PATH="$ARGC_COMPLETIONS_ROOT/bin:$PATH"
fi

# user paths
export PATH="$HOME/tools/llvm-project/build/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/tools/llvm-project/build/lib:$LD_LIBRARY_PATH"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
# tmux-open-nvim helper script (available right after TPM plugin install)
export PATH="$HOME/.tmux/plugins/tmux-open-nvim/scripts:$PATH"

# keep PATH/fpath unique
typeset -U path fpath

# -----------------------------------------------------------------------------
# HISTORY
# -----------------------------------------------------------------------------
export HISTFILE="${HISTFILE:-$HOME/.histfile}"
HISTSIZE=9000000
SAVEHIST=9000000
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

#ffmpeg
alias mp4tomp3='for f in *.mp4; do ffmpeg -i "$f" -q:a 0 -map a "${f%.mp4}.mp3"; done'

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
alias q= 'exit'

# safer defaults
alias mkdir='mkdir -p'
alias cp='cp -i'
alias mv='mv -i'

unalias bookokrat 2>/dev/null

_bookokrat_cleanup() {
    if [[ -n "$TMUX" ]]; then
        printf '\ePtmux;\e\e_Ga=d,d=Z,z=-1,q=2\e\e\\\e\\'
    else
        printf '\e_Ga=d,d=Z,z=-1,q=2\e\\'
    fi
}

_bookokrat() {
    command bookokrat "$@"
    local rc=$?

    _bookokrat_cleanup

    return $rc
}

alias bookokrat='_bookokrat'

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

# -----------------------------------------------------------------------------
# fzf-tab
# -----------------------------------------------------------------------------
zstyle ':fzf-tab:*' fzf-command fzf

# Не наследовать общий FZF_DEFAULT_OPTS:
# общий preview-window/bind часто ломает completion-контексты fzf-tab.
zstyle ':fzf-tab:*' use-fzf-default-opts no

zstyle ':fzf-tab:*' fzf-flags \
  --height=60% \
  --layout=reverse \
  --border=rounded \
  --cycle \
  --ansi \
  --info=inline \
  --preview-window=right,55%,wrap \
  --bind=ctrl-j:down \
  --bind=ctrl-k:up \
  --bind=alt-j:down \
  --bind=alt-k:up \
  --bind=ctrl-u:preview-half-page-up \
  --bind=ctrl-d:preview-half-page-down \
  --bind=ctrl-f:preview-page-down \
  --bind=ctrl-b:preview-page-up \
  --bind=ctrl-space:toggle \
  --bind=tab:accept

zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' continuous-trigger '/'
zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*' fzf-min-height 15

# Директории: компактное дерево.
zstyle ':fzf-tab:complete:cd:*' fzf-preview '
  if (( $+commands[eza] )); then
    eza --tree --level=2 --icons --git --color=always "$realpath" 2>/dev/null | head -200
  else
    ls -la --color=always "$realpath" 2>/dev/null
  fi
'

zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview '
  if (( $+commands[eza] )); then
    eza --tree --level=2 --icons --git --color=always "$realpath" 2>/dev/null | head -200
  else
    ls -la --color=always "$realpath" 2>/dev/null
  fi
'

# Общий preview для файлов.
zstyle ':fzf-tab:complete:*:*' fzf-preview '
  if [[ -d "$realpath" ]]; then
  if (( $+commands[eza] )); then
    eza --tree --level=2 --icons --git --color=always "$realpath" 2>/dev/null | head -200
  else
    ls -la --color=always "$realpath" 2>/dev/null
  fi
  elif [[ -f "$realpath" ]]; then
    mime=$(file --mime-type -b "$realpath" 2>/dev/null)
    case "$mime" in
      text/*|application/json|application/xml|application/yaml|application/x-sh|application/x-shellscript)
        if (( $+commands[bat] )); then
          bat --style=numbers --color=always --line-range=:250 "$realpath" 2>/dev/null
        else
          sed -n "1,250p" "$realpath" 2>/dev/null
        fi
        ;;
      image/*)
        if (( $+commands[chafa] )); then
          chafa "$realpath" 2>/dev/null
        else
          file "$realpath" 2>/dev/null
        fi
        ;;
      *)
        file "$realpath" 2>/dev/null
        ;;
    esac
  else
    print -r -- "$desc"
  fi
'

# pacman / yay: показ информации о пакете в fzf-preview
zstyle ':fzf-tab:complete:(pacman|yay):*' fzf-preview '
  # Если это не флаг (не начинается с дефиса), пытаемся показать инфо о пакете
  if [[ ! "$word" =~ ^- ]]; then
    # Пробуем получить инфо из репозиториев (Si), если нет - из установленных (Qi)
    { pacman -Si "$word" 2>/dev/null || pacman -Qi "$word" 2>/dev/null; } |
      if (( $+commands[bat] )); then
        bat --style=plain --color=always --line-range :150
      else
        sed -n "1,150p"
      fi
  else
    # Если это флаг, показываем help
    "$words[1]" --help 2>/dev/null | sed -n "1,150p"
  fi
'

# Git.
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview '
  git diff --color=always -- "$word" 2>/dev/null |
    { (( $+commands[delta] )) && delta || cat; }
'

zstyle ':fzf-tab:complete:git-(checkout|switch):*' fzf-preview '
  case "$group" in
    *modified*|*file*)
      git diff --color=always -- "$word" 2>/dev/null |
        { (( $+commands[delta] )) && delta || cat; }
      ;;
    *commit*)
      git show --color=always --stat --patch "$word" 2>/dev/null |
        { (( $+commands[delta] )) && delta || cat; }
      ;;
    *branch*|*tag*)
      git log --color=always --oneline --graph --decorate -30 "$word" 2>/dev/null
      ;;
    *)
      git log --color=always --oneline --graph --decorate --all -30 2>/dev/null
      ;;
  esac
'

# Процессы.
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '
  [[ "$group" == *process* || "$group" == *PID* ]] &&
    ps --pid="$word" -o pid,ppid,user,%cpu,%mem,etime,stat,args -w -w 2>/dev/null
'

zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags \
  --height=50% \
  --layout=reverse \
  --border=rounded \
  --ansi \
  --preview-window=down:5:wrap

# systemctl.
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview '
  SYSTEMD_COLORS=1 systemctl status "$word" --no-pager --full 2>/dev/null
'

# ssh/scp/sftp.
zstyle ':fzf-tab:complete:(ssh|scp|sftp|sshfs|mosh):*' fzf-preview '
  ssh -G "${word##*@}" 2>/dev/null | sed -n "1,120p"
'

# npm/pnpm.
zstyle ':fzf-tab:complete:(npm|pnpm|yarn):*' fzf-preview '
  if [[ -f package.json ]]; then
    if (( $+commands[jq] )); then
      jq -r ".scripts // {} | to_entries[] | \"\(.key)\t\(.value)\"" package.json 2>/dev/null
    else
      sed -n "1,160p" package.json 2>/dev/null
    fi
  fi
'

# cargo/rustup/uv/just/docker/kubectl.
zstyle ':fzf-tab:complete:(cargo|rustup|uv|just):*' fzf-preview '
  case "$group" in
    *command*|*commands*)
      "$words[1]" "$word" --help 2>/dev/null | sed -n "1,160p"
      ;;
    *)
      print -r -- "$group: $word"
      ;;
  esac
'

zstyle ':fzf-tab:complete:docker:*' fzf-preview '
  docker inspect "$word" 2>/dev/null | sed -n "1,180p" ||
  docker ps -a --filter "name=$word" --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null
'

zstyle ':fzf-tab:complete:kubectl:*' fzf-preview '
  kubectl describe "$word" 2>/dev/null | sed -n "1,180p" ||
  kubectl get "$word" -o yaml 2>/dev/null | sed -n "1,180p"
'

# Переменные окружения.
zstyle ':fzf-tab:complete:(-parameter-|export|unset|expand):*' fzf-preview '
  print -r -- ${(P)word}
'

# Команды.
# Порядок:
# 1. argc-completions spec: флаги, опции, аргументы, подкоманды
# 2. tldr
# 3. man
# 4. which

# Команды: argc-completions -> tldr -> man -> which.
zstyle ':fzf-tab:complete:-command-:*' fzf-preview '
  _argc_file=""

  for _candidate in \
    "$ARGC_COMPLETIONS_ROOT/completions/$word.sh" \
    "$ARGC_COMPLETIONS_ROOT/completions/linux/$word.sh"
  do
    [[ -r "$_candidate" ]] && {
      _argc_file="$_candidate"
      break
    }
  done

  if [[ -n "$_argc_file" ]]; then
    {
      print -r -- "argc-completions: $word"
      print -r -- "source: $_argc_file"
      print -r -- ""

      awk "
        /^# @cmd/ {
          sub(/^# @cmd[ \t]*/, \"cmd     \")
          print
        }
        /^# @flag/ {
          sub(/^# @flag[ \t]*/, \"flag    \")
          print
        }
        /^# @option/ {
          sub(/^# @option[ \t]*/, \"option  \")
          print
        }
        /^# @arg/ {
          sub(/^# @arg[ \t]*/, \"arg     \")
          print
        }
      " "$_argc_file" | sed -n "1,220p"
    }
  else
    (tldr --color always "$word" 2>/dev/null) ||
    (MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word" 2>/dev/null | bat -plman --color=always 2>/dev/null) ||
    (which "$word" 2>/dev/null)
  fi
'

# Команды.
zstyle ':fzf-tab:complete:-command-:*' fzf-preview '
  (tldr --color always "$word" 2>/dev/null) ||
  (MANWIDTH=$FZF_PREVIEW_COLUMNS man "$word" 2>/dev/null | bat -plman --color=always 2>/dev/null) ||
  (which "$word" 2>/dev/null)
'



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
zinit light zpm-zsh/ssh

if (( $+commands[npm] )); then
  zinit ice depth=1
  zinit light lukechilds/zsh-better-npm-completion

  zinit ice depth=1
  zinit light akoenig/npm-run.plugin.zsh
fi

if (( $+commands[rustup] )); then
  zinit ice depth=1
  zinit light pkulev/zsh-rustup-completion
fi

zinit ice depth=1
zinit light wfxr/forgit

zinit ice depth=1
zinit light MichaelAquilina/zsh-you-should-use

zinit ice depth=1
zinit light chrissicool/zsh-256color

zinit ice depth=1
zinit light Tarrasch/zsh-bd



# -----------------------------------------------------------------------------
# COMPLETION ENGINE
# -----------------------------------------------------------------------------

fpath=(
  /usr/share/zsh/site-functions
  /usr/share/zsh/functions/Completion/Unix
  $fpath
)

typeset -U fpath

autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh"

_zcompdump="$XDG_CACHE_HOME/zsh/.zcompdump-${ZSH_VERSION}"

if [[ -s "$_zcompdump" ]]; then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
fi

unset _zcompdump

# Явно привязать native completions
(( $+functions[_pacman] )) && compdef _pacman pacman
(( $+functions[_yay] )) && compdef _yay yay

# -----------------------------------------------------------------------------
# ARGC COMPLETIONS CACHE
# -----------------------------------------------------------------------------
_argc_zsh_cache="$XDG_CACHE_HOME/zsh/argc-completions.zsh"

_argc_generate_cache() {
  [[ -d "$ARGC_COMPLETIONS_ROOT/completions" ]] || return 1
  (( $+commands[argc] )) || return 1

  mkdir -p "$XDG_CACHE_HOME/zsh"

  find "$ARGC_COMPLETIONS_ROOT/completions" \
    -type f \
    -name '*.sh' \
    -printf '%P\n' 2>/dev/null |
    sed 's/\.sh$//' |
    sort -u |
    xargs argc --argc-completions zsh >| "$_argc_zsh_cache"
}

if [[ -d "$ARGC_COMPLETIONS_ROOT" ]] && (( $+commands[argc] )); then
  [[ -s "$_argc_zsh_cache" ]] || _argc_generate_cache
  [[ -s "$_argc_zsh_cache" ]] && source "$_argc_zsh_cache"
fi

unset -f _argc_generate_cache
unset _argc_zsh_cache

# fzf-tab — keep in the correct order
zinit ice depth=1
zinit light Aloxaf/fzf-tab

# widget wrappers / interactive helpers
zinit ice depth=1
zinit light zsh-users/zsh-autosuggestions

zinit ice depth=1
zinit light hlissner/zsh-autopair


# -----------------------------------------------------------------------------
# PLUGIN CONFIG
# -----------------------------------------------------------------------------
# zsh-vi-mode
ZVM_VI_EDITOR=nvim
ZVM_ESCAPE_KEYTIMEOUT=0.03
ZVM_CURSOR_STYLE_ENABLED=true

# autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_COMPLETION_IGNORE='(git log *|git diff *|git show *|rg *|fd *|find *)'

# you-should-use
export YSU_MESSAGE_POSITION='after'
export YSU_MODE='ALL'

# auto-notify
export AUTO_NOTIFY_THRESHOLD=20
export AUTO_NOTIFY_EXPIRE_TIME=8000
export AUTO_NOTIFY_ENABLE_SSH=0
export AUTO_NOTIFY_CANCEL_ON_SIGINT=1

# forgit
export FORGIT_FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS"

# =============================================================================
# zsh-vi-mode hook — перепривязываем Tab ПОСЛЕ того как ZVM перезапишет биндинги
# =============================================================================
function zvm_after_init() {
  bindkey '^I' fzf-tab-complete
  (( $+commands[fzf] )) && {
    bindkey '^T' fzf-file-widget
    bindkey '^R' fzf-history-widget
    bindkey '^[c' fzf-cd-widget
  }
  bindkey -M viins "$terminfo[kcuu1]" history-substring-search-up
  bindkey -M viins "$terminfo[kcud1]" history-substring-search-down
  bindkey -M viins '^[[A' history-substring-search-up
  bindkey -M viins '^[[B' history-substring-search-down
  bindkey -M viins '^P' history-substring-search-up
  bindkey -M viins '^N' history-substring-search-down
}

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


# faster syntax highlighting
# УБЕРИТЕ zsh-users/zsh-syntax-highlighting, если он уже подключен,
# и используйте только fast-syntax-highlighting
zinit ice depth=1
zinit light zdharma-continuum/fast-syntax-highlighting

# history search — load after syntax-highlighting
zinit ice depth=1
zinit light zsh-users/zsh-history-substring-search



# -----------------------------------------------------------------------------
# Удобные алиасы под root repo
# -----------------------------------------------------------------------------

alias cdu='cd-gitroot'

# -----------------------------------------------------------------------------
# EXTERNAL TOOLS INIT (guarded)
# -----------------------------------------------------------------------------
(( $+commands[tmuxifier] )) && eval "$(tmuxifier init -)"
# fzf's generated zsh init can try to restore the read-only `zle` option.
(( $+commands[fzf] )) && eval "$(fzf --zsh)" 2>/dev/null
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[thefuck] )) && eval "$(thefuck --alias fuck)"
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# Prefer focused native/plugin completions where they beat the generic carapace fallback.
(( $+functions[_zbnc_zsh_better_npm_completion] )) && compdef _zbnc_zsh_better_npm_completion npm
(( $+functions[_zbnc_zsh_better_npm_completion_npx] )) && compdef _zbnc_zsh_better_npm_completion_npx npx
autoload -Uz _git _ssh 2>/dev/null
compdef _git git 2>/dev/null
compdef _ssh ssh scp sftp sshfs mosh 2>/dev/null

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
function argc-refresh() {
  local cache_file="$XDG_CACHE_HOME/zsh/argc-completions.zsh"

  if [[ ! -d "$ARGC_COMPLETIONS_ROOT" ]]; then
    print -P "%F{red}argc-completions: directory not found: $ARGC_COMPLETIONS_ROOT%f"
    return 1
  fi

  if [[ -d "$ARGC_COMPLETIONS_ROOT/.git" ]]; then
    git -C "$ARGC_COMPLETIONS_ROOT" pull --ff-only
  fi

  "$ARGC_COMPLETIONS_ROOT/scripts/download-tools.sh"

  mkdir -p "$XDG_CACHE_HOME/zsh"

  find "$ARGC_COMPLETIONS_ROOT/completions" \
    -type f \
    -name '*.sh' \
    -printf '%P\n' 2>/dev/null |
    sed 's/\.sh$//' |
    sort -u |
    xargs argc --argc-completions zsh >| "$cache_file"

  rm -f "$XDG_CACHE_HOME/zsh/.zcompdump-"*

  print -P "%F{green}argc-completions cache rebuilt.%f Run: exec zsh"
}
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

# ─────────────────────────────────────────────────────────────────────────────
# ff — recent files fuzzy picker  (аналог zz, но для файлов)
#
# Три источника в порядке приоритета (дедуплицируются):
#   1. git-изменённые файлы текущего репо (самые свежие для агента)
#   2. fd --changed-within 7d  (файлы, изменённые за последние 7 дней)
#   3. fallback: fd --type f в текущем репо/директории
#
# Использование:
#   ff           — интерактивный fzf-пикер, открывает в nvim / ton (если tmux)
#   ff <query>   — предзаполнить строку поиска
#
# Флаги:
#   --days N     — глубина поиска fd (по умолчанию 7)
#   --root DIR   — корень поиска (по умолчанию: git root или $PWD)
#   --print      — только вывести пути, не открывать редактор
#
# Зависимости: fd, fzf, bat (опционально), eza (опционально)
#              nvim + ton (tmux-open-nvim) — как у тебя в конфиге
# ─────────────────────────────────────────────────────────────────────────────

function ff() {
  # ── parse args ────────────────────────────────────────────────────────────
  local -i days=7
  local root query print_only=0
  local -a leftover

  while (( $# )); do
    case "$1" in
      --days)   days="${2:?'--days requires a value'}"; shift 2 ;;
      --root)   root="${2:?'--root requires a value'}"; shift 2 ;;
      --print)  print_only=1; shift ;;
      --)       shift; leftover+=("$@"); break ;;
      -*)       print -u2 "ff: unknown flag $1"; return 1 ;;
      *)        leftover+=("$1"); shift ;;
    esac
  done

  query="${leftover[*]}"
  [[ -z "$root" ]] && root="$(_repo_root)"   # fallback: git root or PWD

  # ── build candidate list ──────────────────────────────────────────────────
  # Source 1: git-changed files (absolute paths) — most relevant for AI agent
  local -a git_files=()
  if git -C "$root" rev-parse --is-inside-work-tree &>/dev/null; then
    while IFS= read -r rel; do
      [[ -f "$root/$rel" ]] && git_files+=("$root/$rel")
    done < <(
      git -C "$root" status --porcelain=v1 --untracked-files=all 2>/dev/null \
        | while IFS= read -r line; do
            local p="${line#?? }"
            [[ "$p" == *' -> '* ]] && p="${p##* -> }"
            print -r -- "$p"
          done
    )
  fi

  # Source 2: recently modified files via fd
  local -a fd_files=()
  if (( $+commands[fd] )); then
    while IFS= read -r f; do
      fd_files+=("$f")
    done < <(
      fd --type f --hidden --follow \
         --exclude .git --exclude node_modules --exclude __pycache__ \
         --exclude '.DS_Store' \
         --changed-within "${days}d" \
         --absolute-path \
         . "$root" 2>/dev/null \
        | sort -t/ -k1,1  # fd doesn't guarantee mtime order; we sort after
    )
  fi

  # Source 3: fallback — any file in the repo/dir (when sources 1+2 are empty)
  local -a fallback_files=()
  if (( ${#git_files[@]} + ${#fd_files[@]} == 0 )); then
    while IFS= read -r f; do
      fallback_files+=("$f")
    done < <(
      fd --type f --hidden --follow \
         --exclude .git --exclude node_modules \
         --absolute-path \
         . "$root" 2>/dev/null | head -500
    )
  fi

  # Merge & deduplicate, preserving priority order (git > fd > fallback)
  local -a candidates=()
  local -A seen=()
  for f in "${git_files[@]}" "${fd_files[@]}" "${fallback_files[@]}"; do
    [[ -z "${seen[$f]}" ]] || continue
    seen[$f]=1
    candidates+=("$f")
  done

  if (( ${#candidates[@]} == 0 )); then
    print -P "%F{yellow}ff: no files found in $root%f"
    return 1
  fi

  # ── fzf preview command (bat with fallback) ───────────────────────────────
  local preview_cmd
  if (( $+commands[bat] )); then
    preview_cmd='bat --style=numbers --color=always --line-range :300 {}'
  else
    preview_cmd='sed -n "1,200p" {}'
  fi

  # ── label for git-changed files (shown as relative paths in fzf) ─────────
  # We display relative paths for readability, but remember absolutes for open.
  # Build a display→absolute map via NUL-separated pairs fed to fzf --read0.

  # Simpler approach: display relative-to-root, pass absolute via fzf transform
  local -a display=()
  for f in "${candidates[@]}"; do
    # strip root prefix for display; keep absolute for opening
    display+=("${f#$root/}")
  done

  # ── run fzf ──────────────────────────────────────────────────────────────
  local raw
  raw=$(
    printf '%s\n' "${display[@]}" | fzf \
      --multi \
      --prompt='recent > ' \
      --query="$query" \
      --preview="$preview_cmd" \
      --preview-window='right,65%,wrap' \
      --bind='ctrl-j:down,ctrl-k:up,alt-j:down,alt-k:up' \
      --bind='ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down' \
      --bind='ctrl-f:preview-page-down,ctrl-b:preview-page-up' \
      --cycle \
      --header="$(printf '%d files | root: %s | last %dd' ${#candidates[@]} "${root/#$HOME/~}" $days)"
  ) || return

  # ── resolve selected display lines back to absolute paths ─────────────────
  local -a selected=()
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    local abs="$root/$rel"
    # handle files that were already absolute (from outside root)
    [[ -f "$abs" ]] && selected+=("$abs") || selected+=("$rel")
  done <<< "$raw"

  (( ${#selected[@]} )) || return

  # ── output ────────────────────────────────────────────────────────────────
  if (( print_only )); then
    printf '%s\n' "${selected[@]}"
    return
  fi

  _open_in_editor "${selected[@]}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Suggested additions to your .zshrc:
#
#   # open recent files (mirrors 'zz' for directories)
#   # ff            — picks from git-changed + fd-recent files
#   # ff some text  — pre-fills fzf query
#   # ff --days 14  — widen time window
#   # ff --print    — print paths (useful for pipes / agent scripts)
#
# The function uses _repo_root and _open_in_editor already defined in your
# config, so just append this block after those definitions.
# ─────────────────────────────────────────────────────────────────────────────

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

# Автозапуск tmux
if [[ -z "$TMUX" ]] && [[ $- == *i* ]]; then
    exec tmux new-session 
fi
# -----------------------------------------------------------------------------
# LOCAL OVERRIDES
# -----------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
path=("$HOME/go/bin" "$HOME/.local/bin" $path)
[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
