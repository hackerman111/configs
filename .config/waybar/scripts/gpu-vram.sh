#!/usr/bin/env bash

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

query_gpu() {
  nvidia-smi \
    --query-gpu=name,memory.used,memory.total \
    --format=csv,noheader,nounits 2>/dev/null | head -n 1
}

query="$(query_gpu)"

if [[ -z "$query" ]]; then
  echo '{"text":"󰾲 --%","tooltip":"GPU VRAM metrics unavailable"}'
  exit 0
fi

IFS=',' read -r raw_name raw_used raw_total <<<"$query"

name="$(trim "$raw_name")"
used="$(trim "$raw_used")"
total="$(trim "$raw_total")"

if [[ "$used" =~ ^[0-9]+(\.[0-9]+)?$ && "$total" =~ ^[0-9]+(\.[0-9]+)?$ && "$total" != "0" ]]; then
  usage_pct="$(awk -v used="$used" -v total="$total" 'BEGIN { printf "%.0f", (used / total) * 100 }')"
  used_gib="$(awk -v value="$used" 'BEGIN { printf "%.1f", value / 1024 }')"
  total_gib="$(awk -v value="$total" 'BEGIN { printf "%.1f", value / 1024 }')"
else
  usage_pct="--"
  used_gib="--"
  total_gib="--"
fi

class=""
if [[ "$usage_pct" =~ ^[0-9]+$ ]]; then
  if (( usage_pct >= 90 )); then
    class="critical"
  elif (( usage_pct >= 75 )); then
    class="warning"
  fi
fi

tooltip="GPU: ${name}\nVRAM: ${used_gib}/${total_gib} GiB (${usage_pct}%)"

if [[ -n "$class" ]]; then
  printf '{"text":"󰾲 %s%%","tooltip":"%s","class":"%s"}\n' "$usage_pct" "$tooltip" "$class"
else
  printf '{"text":"󰾲 %s%%","tooltip":"%s"}\n' "$usage_pct" "$tooltip"
fi
