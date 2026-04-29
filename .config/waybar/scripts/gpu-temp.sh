#!/usr/bin/env bash

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

query_gpu() {
  nvidia-smi \
    --query-gpu=name,temperature.gpu,memory.used,memory.total \
    --format=csv,noheader,nounits 2>/dev/null | head -n 1
}

query="$(query_gpu)"

if [[ -z "$query" ]]; then
  echo '{"text":"󱔱 --°C","tooltip":"GPU metrics unavailable"}'
  exit 0
fi

IFS=',' read -r raw_name raw_temp raw_used raw_total <<<"$query"

name="$(trim "$raw_name")"
temp="$(trim "$raw_temp")"
used="$(trim "$raw_used")"
total="$(trim "$raw_total")"

class=""
icon="󱃃"

if [[ "$temp" =~ ^[0-9]+$ ]]; then
  if (( temp >= 80 )); then
    icon="󰸁"
    class="critical"
  elif (( temp >= 70 )); then
    icon="󱃂"
    class="warning"
  elif (( temp >= 60 )); then
    icon="󰔏"
  fi
else
  temp="--"
  icon="󱔱"
fi

used_gib="$(awk -v value="$used" 'BEGIN { if (value ~ /^[0-9]+(\.[0-9]+)?$/) printf "%.1f", value / 1024; else print "--" }')"
total_gib="$(awk -v value="$total" 'BEGIN { if (value ~ /^[0-9]+(\.[0-9]+)?$/) printf "%.1f", value / 1024; else print "--" }')"

tooltip="GPU: ${name}\nTemperature: ${temp}°C\nVRAM: ${used_gib}/${total_gib} GiB"

if [[ -n "$class" ]]; then
  printf '{"text":"%s %s°C","tooltip":"%s","class":"%s"}\n' "$icon" "$temp" "$tooltip" "$class"
else
  printf '{"text":"%s %s°C","tooltip":"%s"}\n' "$icon" "$temp" "$tooltip"
fi
