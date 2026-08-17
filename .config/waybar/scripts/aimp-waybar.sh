#!/usr/bin/env bash

set -Eeuo pipefail

CONFIG_FILE="${AIMP_WAYBAR_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/waybar/scripts/aimp-control.conf}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/aimp-waybar"
CURRENT_PLAYLIST_FILE="$STATE_DIR/current-playlist"

[[ -r "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

: "${BACKEND:=auto}"
: "${AIMP_PLAYER_MATCH:=aimp}"
: "${PLAYLIST_DIR:=$HOME/Music/Playlists}"
: "${PLAYLIST_MAP:=${XDG_CONFIG_HOME:-$HOME/.config}/waybar/scripts/aimp-playlists.conf}"
: "${PLAYLIST_OPEN_MODE:=argument}"
: "${PLAYLIST_AUTOPLAY:=0}"
: "${STARTUP_DELAY:=1.0}"
: "${WAYBAR_SIGNAL:=9}"
: "${MAX_TEXT_LENGTH:=45}"
: "${SHOW_TRACK:=1}"
: "${NOTIFY_REPLACE_ID:=91192}"
: "${HOTKEY_TOGGLE:=Ctrl+Alt+Space}"
: "${HOTKEY_PREVIOUS:=Ctrl+Alt+Left}"
: "${HOTKEY_NEXT:=Ctrl+Alt+Right}"
: "${ICON_PLAYING:=󰎆}"
: "${ICON_PAUSED:=󰏤}"
: "${ICON_RUNNING:=󰐊}"
: "${ICON_STOPPED:=󰝛}"

if ! declare -p AIMP_CMD >/dev/null 2>&1; then
  AIMP_CMD=(aimp)
fi
if ! declare -p AIMP_PROCESS_NAMES >/dev/null 2>&1; then
  AIMP_PROCESS_NAMES=(aimp AIMP.exe)
fi
if ! declare -p ROFI_CMD >/dev/null 2>&1; then
  ROFI_CMD=(rofi -dmenu -i -p "AIMP playlist")
fi
if ! declare -p CUSTOM_TOGGLE >/dev/null 2>&1; then
  CUSTOM_TOGGLE=()
fi
if ! declare -p CUSTOM_PREVIOUS >/dev/null 2>&1; then
  CUSTOM_PREVIOUS=()
fi
if ! declare -p CUSTOM_NEXT >/dev/null 2>&1; then
  CUSTOM_NEXT=()
fi
if ! declare -p PLAYLIST_OPEN_CMD >/dev/null 2>&1; then
  PLAYLIST_OPEN_CMD=()
fi

mkdir -p "$STATE_DIR"

print_help() {
  local exit_code="${1:-0}"
  cat <<'USAGE'
Usage: aimp-waybar.sh <action>

Actions:
  status       Print one JSON line for Waybar
  toggle       Launch AIMP or toggle play/pause
  previous     Play the previous track
  next         Play the next track
  playlist     Select a playlist through Rofi
  launch       Launch AIMP
  help         Show this help
USAGE
  exit "$exit_code"
}

die() {
  printf 'aimp-waybar: %s\n' "$*" >&2
  exit 1
}

notify() {
  command -v notify-send >/dev/null 2>&1 || return 0
  notify-send \
    -a "AIMP" \
    -r "$NOTIFY_REPLACE_ID" \
    -u low \
    "$1" "${2:-}"
}

run_detached() {
  if command -v setsid >/dev/null 2>&1; then
    setsid -f "$@" >/dev/null 2>&1
  else
    nohup "$@" >/dev/null 2>&1 &
  fi
}

is_running() {
  local process_name
  for process_name in "${AIMP_PROCESS_NAMES[@]}"; do
    pgrep -x -- "$process_name" >/dev/null 2>&1 && return 0
  done
  return 1
}

launch_aimp() {
  if is_running; then
    return 0
  fi
  run_detached "${AIMP_CMD[@]}"
  notify "AIMP" "Player started"
}

get_mpris_player() {
  command -v playerctl >/dev/null 2>&1 || return 1

  local player needle
  needle="${AIMP_PLAYER_MATCH,,}"
  while IFS= read -r player; do
    [[ "${player,,}" == *"$needle"* ]] || continue
    printf '%s\n' "$player"
    return 0
  done < <(playerctl --list-all 2>/dev/null || true)

  return 1
}

resolve_backend() {
  case "$BACKEND" in
    auto)
      if get_mpris_player >/dev/null; then
        printf '%s\n' mpris
      else
        printf '%s\n' hotkey
      fi
      ;;
    mpris|hotkey|custom)
      printf '%s\n' "$BACKEND"
      ;;
    *)
      die "unknown backend: $BACKEND"
      ;;
  esac
}

run_named_command() {
  local array_name="$1"
  local -n command_ref="$array_name"
  ((${#command_ref[@]} > 0)) || die "$array_name is empty in $CONFIG_FILE"
  "${command_ref[@]}"
}

send_hotkey() {
  local combination="$1"
  "${AIMP_CMD[@]}" -hotkey "$combination" >/dev/null 2>&1
}

control_mpris() {
  local action="$1" player playerctl_action

  if ! player="$(get_mpris_player)"; then
    launch_aimp
    [[ "$action" == toggle ]] && return 0
    sleep "$STARTUP_DELAY"
    player="$(get_mpris_player)" || die "AIMP did not expose an MPRIS player"
  fi

  case "$action" in
    toggle) playerctl_action=play-pause ;;
    previous) playerctl_action=previous ;;
    next) playerctl_action=next ;;
    *) die "unsupported MPRIS action: $action" ;;
  esac

  playerctl --player="$player" "$playerctl_action"
}

control_hotkey() {
  local action="$1" combination

  if ! is_running; then
    launch_aimp
    [[ "$action" == toggle ]] && return 0
    sleep "$STARTUP_DELAY"
  fi

  case "$action" in
    toggle) combination="$HOTKEY_TOGGLE" ;;
    previous) combination="$HOTKEY_PREVIOUS" ;;
    next) combination="$HOTKEY_NEXT" ;;
    *) die "unsupported hotkey action: $action" ;;
  esac

  send_hotkey "$combination" || die "AIMP rejected hotkey: $combination"
}

control_custom() {
  case "$1" in
    toggle) run_named_command CUSTOM_TOGGLE ;;
    previous) run_named_command CUSTOM_PREVIOUS ;;
    next) run_named_command CUSTOM_NEXT ;;
    *) die "unsupported custom action: $1" ;;
  esac
}

refresh_waybar() {
  pkill "-RTMIN+${WAYBAR_SIGNAL}" waybar >/dev/null 2>&1 || true
}

control_action() {
  local action="$1" backend
  backend="$(resolve_backend)"

  case "$backend" in
    mpris) control_mpris "$action" ;;
    hotkey) control_hotkey "$action" ;;
    custom) control_custom "$action" ;;
  esac

  refresh_waybar
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

playlist_label() {
  local filename
  filename="$(basename -- "$1")"
  filename="${filename%.aimppl4}"
  filename="${filename%.aimppl}"
  filename="${filename%.m3u8}"
  filename="${filename%.m3u}"
  filename="${filename%.pls}"
  printf '%s\n' "$filename"
}

load_playlists() {
  PLAYLIST_LABELS=()
  PLAYLIST_PATHS=()

  local label path line
  if [[ -r "$PLAYLIST_MAP" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
      [[ "$line" =~ ^[[:space:]]*(#|$) ]] && continue
      [[ "$line" == *'|'* ]] || continue

      label="$(trim "${line%%|*}")"
      path="$(trim "${line#*|}")"
      path="${path/#\~/$HOME}"
      [[ -n "$label" && -f "$path" ]] || continue

      PLAYLIST_LABELS+=("$label")
      PLAYLIST_PATHS+=("$path")
    done < "$PLAYLIST_MAP"
  fi

  if ((${#PLAYLIST_PATHS[@]} == 0)) && [[ -d "$PLAYLIST_DIR" ]]; then
    while IFS= read -r -d '' path; do
      PLAYLIST_LABELS+=("$(playlist_label "$path")")
      PLAYLIST_PATHS+=("$path")
    done < <(
      find "$PLAYLIST_DIR" -maxdepth 4 -type f \
        \( -iname '*.aimppl4' -o -iname '*.aimppl' -o -iname '*.m3u' -o -iname '*.m3u8' -o -iname '*.pls' \) \
        -print0 | sort -z
    )
  fi
}

path_to_file_uri() {
  local absolute_path="$1"
  command -v python3 >/dev/null 2>&1 || return 1
  python3 - "$absolute_path" <<'PY'
import pathlib
import sys
print(pathlib.Path(sys.argv[1]).resolve().as_uri())
PY
}

open_playlist_custom() {
  local playlist_path="$1" token found_placeholder=0
  local -a command=()

  ((${#PLAYLIST_OPEN_CMD[@]} > 0)) || die "PLAYLIST_OPEN_CMD is empty"

  for token in "${PLAYLIST_OPEN_CMD[@]}"; do
    if [[ "$token" == *'{playlist}'* ]]; then
      token="${token//\{playlist\}/$playlist_path}"
      found_placeholder=1
    fi
    command+=("$token")
  done

  ((found_placeholder == 1)) || command+=("$playlist_path")
  run_detached "${command[@]}"
}

open_playlist() {
  local playlist_path="$1" player uri

  case "$PLAYLIST_OPEN_MODE" in
    argument)
      run_detached "${AIMP_CMD[@]}" "$playlist_path"
      ;;
    mpris)
      player="$(get_mpris_player)" || die "AIMP MPRIS player not found"
      uri="$(path_to_file_uri "$playlist_path")" || die "python3 is required for MPRIS playlist URIs"
      playerctl --player="$player" open "$uri"
      ;;
    custom)
      open_playlist_custom "$playlist_path"
      ;;
    *)
      die "unknown PLAYLIST_OPEN_MODE: $PLAYLIST_OPEN_MODE"
      ;;
  esac

  printf '%s\n' "$playlist_path" > "$CURRENT_PLAYLIST_FILE"

  if [[ "$PLAYLIST_AUTOPLAY" == 1 ]]; then
    sleep 0.25
    control_action toggle
  else
    refresh_waybar
  fi
}

select_playlist() {
  command -v "${ROFI_CMD[0]}" >/dev/null 2>&1 || die "${ROFI_CMD[0]} is not installed"
  load_playlists
  ((${#PLAYLIST_PATHS[@]} > 0)) || die "no playlists found in $PLAYLIST_DIR or $PLAYLIST_MAP"

  local selection index
  selection="$({
    for index in "${!PLAYLIST_LABELS[@]}"; do
      printf '%04d  %s\n' "$index" "${PLAYLIST_LABELS[$index]}"
    done
  } | "${ROFI_CMD[@]}")" || return 0

  [[ "$selection" =~ ^([0-9]{4})[[:space:]] ]] || return 0
  index=$((10#${BASH_REMATCH[1]}))
  [[ -n "${PLAYLIST_PATHS[$index]:-}" ]] || return 0

  open_playlist "${PLAYLIST_PATHS[$index]}"
  notify "AIMP playlist" "${PLAYLIST_LABELS[$index]}"
}

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

truncate_text() {
  local value="$1" limit="$2"
  if ((${#value} <= limit)); then
    printf '%s' "$value"
  elif ((limit > 1)); then
    printf '%s…' "${value:0:limit-1}"
  else
    printf '…'
  fi
}

current_playlist_name() {
  [[ -r "$CURRENT_PLAYLIST_FILE" ]] || return 1
  local path
  IFS= read -r path < "$CURRENT_PLAYLIST_FILE"
  [[ -n "$path" ]] || return 1
  playlist_label "$path"
}

mpris_artist() {
  local player="$1"
  { playerctl --player="$player" metadata xesam:artist 2>/dev/null || true; } |
    awk 'BEGIN { first=1 } { if (!first) printf ", "; printf "%s", $0; first=0 } END { print "" }'
}

status_json() {
  local player status class icon artist title text tooltip playlist
  playlist="$(current_playlist_name 2>/dev/null || true)"

  if player="$(get_mpris_player)"; then
    status="$(playerctl --player="$player" status 2>/dev/null || printf 'Stopped')"
    artist="$(mpris_artist "$player")"
    title="$(playerctl --player="$player" metadata xesam:title 2>/dev/null || true)"

    case "${status,,}" in
      playing) class=playing; icon="$ICON_PLAYING" ;;
      paused) class=paused; icon="$ICON_PAUSED" ;;
      *) class=running; icon="$ICON_RUNNING" ;;
    esac

    if [[ "$SHOW_TRACK" == 1 && -n "$title" ]]; then
      if [[ -n "$artist" ]]; then
        text="$icon $artist — $title"
      else
        text="$icon $title"
      fi
    else
      text="$icon AIMP"
    fi

    tooltip="Status: $status"
    [[ -n "$artist$title" ]] && tooltip+=$'\n'"Track: ${artist:+$artist — }$title"
  elif is_running; then
    class=running
    text="$ICON_RUNNING AIMP"
    tooltip="AIMP is running"
    tooltip+=$'\n'"Track metadata requires MPRIS/playerctl"
  else
    class=stopped
    text="$ICON_STOPPED AIMP"
    tooltip="AIMP is stopped"
  fi

  [[ -n "$playlist" ]] && tooltip+=$'\n'"Playlist: $playlist"
  tooltip+=$'\n\n'"Left click: play/pause"
  tooltip+=$'\n'"Middle click: choose playlist"
  tooltip+=$'\n'"Right click: next track"
  tooltip+=$'\n'"Wheel up/down: previous/next track"

  text="$(truncate_text "$text" "$MAX_TEXT_LENGTH")"

  printf '{"text":"%s","tooltip":"%s","class":["%s","aimp"]}\n' \
    "$(json_escape "$text")" \
    "$(json_escape "$tooltip")" \
    "$(json_escape "$class")"
}

main() {
  case "${1:-status}" in
    status) status_json ;;
    toggle) control_action toggle ;;
    previous) control_action previous ;;
    next) control_action next ;;
    playlist) select_playlist ;;
    launch) launch_aimp; refresh_waybar ;;
    help|-h|--help) print_help 0 ;;
    *) print_help 2 ;;
  esac
}

main "$@"
