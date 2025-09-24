# ~/.zshrc

# --- Ручная установка и загрузка Zinit ---

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Скачиваем Zinit, если его еще нет
if [ ! -d "$ZINIT_HOME" ]; then
    echo ">>> Установка Zinit..."
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
# Загружаем zinit
source "${ZINIT_HOME}/zinit.zsh"

export PATH="$HOME/tools/llvm-project/build/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/tools/llvm-project/build/lib:$LD_LIBRARY_PATH"


#Поиск и история
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups


#eza

alias ls='eza --icons --git'                   # Базовая команда: ls теперь это eza с иконками и статусом git
alias ll='eza -lh --icons --git --header'      # Длинный формат (l) с читаемым размером файлов (h) и заголовком
alias la='eza -lah --icons --git --header'     # Как 'll', но также показывает скрытые файлы (a)
alias lt='eza --tree --level=3 --icons --git'  # Отображение в виде дерева (tree) на 3 уровня вглубь
alias l.='eza -a | grep -E "^\."'              # Быстрый способ посмотреть только скрытые файлы ("dotfiles")

zstyle :compinstall filename '/home/papayka/.zshrc'
export PATH="$HOME/.tmuxifier/bin:$PATH"
eval "$(tmuxifier init -)"
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(thefuck --alias fk)"
eval "$(starship init zsh)"
autoload -Uz compinit
compinit

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit light jeffreytse/zsh-vi-mode
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab


