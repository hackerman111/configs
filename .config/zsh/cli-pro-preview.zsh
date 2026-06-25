# ~/.config/zsh/cli-pro-preview.zsh
# =============================================================================
# Preview-функции для fzf-tab zstyle и хелп-виджетов (K, ,h, ,H, Alt+H)
#
# ПУБЛИЧНЫЙ API (используется в .zshrc):
#   _cli_pro_preview_help  CMD [SUBCMD...]   → inline help в less/ZLE
#   _cli_pro_preview_command CMD             → full doc page (tldr/man)
#   cli-pro-preview SUBCMD [ARGS...]         → dispatcher для fzf-tab zstyle
#
# ЦЕПОЧКА ПРИОРИТЕТОВ
#   command: argc-completions → tldr → man → --help
#   flag:    grep флага из --help команды
#   generic: file-type preview (JSON/YAML/TOML/MD/code) → command help
#   help:    subcommand-aware --help
# =============================================================================

# =============================================================================
# _cli_pro_preview_help CMD [SUBCMD...]
# Inline help для хелп-виджетов и функции chelp.
# Учитывает субкоманды (git commit, docker build, cargo add, ...).
# =============================================================================

function _cli_pro_preview_help() {
  emulate -L zsh
  local cmd="${1:-}"; shift
  [[ -z "$cmd" ]] && return 1

  case "$cmd" in
    git)
      [[ $# -gt 0 ]] && git "$1" --help 2>&1 | head -200 || git --help 2>&1 | head -200
      ;;
    docker)
      [[ $# -gt 0 ]] && docker "$@" --help 2>&1 | head -200 || docker --help 2>&1 | head -200
      ;;
    kubectl)
      [[ $# -gt 0 ]] && kubectl "$@" --help 2>&1 | head -200 || kubectl --help 2>&1 | head -200
      ;;
    cargo)
      [[ $# -gt 0 ]] && cargo "$@" --help 2>&1 | head -200 || cargo --help 2>&1 | head -200
      ;;
    ip)
      # ip использует help как subcommand, не --help
      [[ $# -gt 0 ]] && ip "$@" help 2>&1 | head -200 || ip help 2>&1 | head -200
      ;;
    sudo|doas)
      man "$cmd" 2>/dev/null | head -200 || "$cmd" --help 2>&1 | head -200
      ;;
    openssl)
      [[ $# -gt 0 ]] && openssl "$1" --help 2>&1 | head -200 || openssl help 2>&1 | head -200
      ;;
    *)
      # Сначала пробуем с субкомандой, потом без
      if [[ $# -gt 0 ]]; then
        "$cmd" "$@" --help 2>&1 | head -200 ||
        "$cmd" --help 2>&1 | head -200
      else
        "$cmd" --help 2>&1 | head -200
      fi
      ;;
  esac
}

# =============================================================================
# _cli_pro_preview_command CMD
# Полная страница документации для cpage и виджета ,H.
# Приоритет: tldr (примеры) → man (полнота) → --help (fallback)
# =============================================================================

function _cli_pro_preview_command() {
  emulate -L zsh
  local cmd="${1:-}"
  [[ -z "$cmd" ]] && return 1

  # argc-completions: структурированный help (самый точный)
  if (( $+commands[argc] )) &&
     [[ -f "${ARGC_COMPLETIONS_ROOT}/completions/${cmd}.sh" ]]; then
    "$cmd" --help 2>&1 | head -200
    return
  fi

  # tldr: краткие читаемые примеры
  if (( $+commands[tldr] )); then
    tldr --color "$cmd" 2>/dev/null && return
  fi

  # man: полная документация
  man "$cmd" 2>/dev/null | head -300 && return

  # Fallback
  "$cmd" --help 2>&1 | head -200
}

# =============================================================================
# _cli_pro_preview_file PATH
# Smart file preview по расширению.
# JSON → jq  |  YAML/TOML/MD → bat  |  директория → eza
# =============================================================================

function _cli_pro_preview_file() {
  emulate -L zsh
  local target="${1:-}"
  [[ -z "$target" ]] && return

  # Директория
  if [[ -d "$target" ]]; then
    if (( $+commands[eza] )); then
      eza --tree --level=2 --icons --git --color=always "$target" 2>/dev/null | head -200
    else
      ls -la --color=always "$target" 2>/dev/null
    fi
    return
  fi

  # По расширению (lowercase)
  local ext="${target:e:l}"

  case "$ext" in
    json)
      if (( $+commands[jq] )); then
        jq --color-output . "$target" 2>/dev/null | head -200 ||
          bat --language=json --style=numbers --color=always "$target" 2>/dev/null | head -200
      else
        bat --language=json --style=numbers --color=always "$target" 2>/dev/null | head -200
      fi
      ;;
    yaml|yml)
      bat --language=yaml --style=numbers --color=always "$target" 2>/dev/null | head -200 ||
        cat "$target" | head -200
      ;;
    toml)
      bat --language=toml --style=numbers --color=always "$target" 2>/dev/null | head -200 ||
        cat "$target" | head -200
      ;;
    md|markdown)
      if (( $+commands[glow] )); then
        glow -s dark "$target" 2>/dev/null | head -200
      else
        bat --language=markdown --style=numbers --color=always "$target" 2>/dev/null | head -200
      fi
      ;;
    env|envrc)
      bat --language=bash --style=numbers --color=always "$target" 2>/dev/null | head -200 ||
        cat "$target" | head -200
      ;;
    pdf)
      (( $+commands[pdftotext] )) &&
        pdftotext "$target" - 2>/dev/null | head -200 ||
        print "PDF: $target"
      ;;
    rs|py|lua|js|ts|jsx|tsx|go|c|cpp|h|sh|zsh|bash|nix|hs|ml|ex|exs|rb|java|kt)
      bat --style=numbers --color=always "$target" 2>/dev/null | head -300
      ;;
    *)
      if (( $+commands[bat] )); then
        bat --style=numbers --color=always --line-range :300 "$target" 2>/dev/null ||
          sed -n '1,200p' "$target" 2>/dev/null
      else
        # Проверяем, что это текстовый файл
        if file "$target" 2>/dev/null | grep -qiE 'text|script|source'; then
          sed -n '1,200p' "$target" 2>/dev/null
        else
          print "Binary: $target ($(file -b "$target" 2>/dev/null))"
        fi
      fi
      ;;
  esac
}

# =============================================================================
# cli-pro-preview SUBCMD [ARGS...]
# Диспетчер для fzf-tab zstyle-preview.
# Subcmds: command | flag | generic | help
# =============================================================================

function cli-pro-preview() {
  emulate -L zsh
  local sub="${1:-}"; shift

  case "$sub" in

    # ── command ────────────────────────────────────────────────────────────────
    # Вызывается при Tab на имя команды: показывает документацию.
    command)
      local word="${1:-}"
      [[ -z "$word" ]] && return 0

      # argc-completions: точное структурированное описание
      if (( $+commands[argc] )) &&
         [[ -f "${ARGC_COMPLETIONS_ROOT}/completions/${word}.sh" ]]; then
        "$word" --help 2>&1 | head -160
        return
      fi

      # tldr: краткие примеры (идеально для первого знакомства)
      if (( $+commands[tldr] )); then
        tldr --color "$word" 2>/dev/null && return
      fi

      # man page
      man "$word" 2>/dev/null | head -160 && return

      # last resort
      (( $+commands["$word"] )) && "$word" --help 2>&1 | head -160 || true
      ;;

    # ── flag ───────────────────────────────────────────────────────────────────
    # Вызывается при Tab на --flag или -f: вытаскивает описание флага из --help.
    flag)
      local cmd="${1:-}" flag="${2:-}"
      [[ -z "$cmd" || -z "$flag" ]] && return 0

      local help_text
      help_text=$("$cmd" --help 2>&1)

      # Экранируем метасимволы для grep
      local esc_flag="${flag//[.+*?^$\{\}()|[\]\\]/\\&}"

      # Ищем строку флага + 3 строки контекста
      local matched
      matched=$(print -r -- "$help_text" |
        grep -E "(^|[[:space:]])${esc_flag}([[:space:],=]|$)" -A 3 | head -15)

      if [[ -n "$matched" ]]; then
        print -r -- "$matched"
      else
        # Флаг не найден — показываем первые 40 строк --help
        print -r -- "$help_text" | head -40
      fi
      ;;

    # ── generic ────────────────────────────────────────────────────────────────
    # Универсальный fallback: file-preview если есть путь, иначе command-help.
    generic)
      local realpath="${1:-}" word="${2:-}" group="${3:-}" desc="${4:-}"

      if [[ -n "$realpath" && -e "$realpath" ]]; then
        _cli_pro_preview_file "$realpath"
      elif [[ -n "$word" ]] && (( $+commands["$word"] )); then
        cli-pro-preview command "$word"
      else
        [[ -n "$group" ]] && print "group: $group"
        [[ -n "$desc"  ]] && print "desc:  $desc"
        [[ -n "$word"  ]] && print "word:  $word"
      fi
      ;;

    # ── help ───────────────────────────────────────────────────────────────────
    # Для zstyle ':fzf-tab:complete:*:options' и option-*
    help)
      _cli_pro_preview_help "$@"
      ;;

    *)
      return 1
      ;;
  esac
}
