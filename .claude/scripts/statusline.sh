#!/usr/bin/env bash

# https://code.claude.com/docs/en/statusline#full-json-schema
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // empty')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
CTX_REMAIN=$(echo "$input" | jq -r '(.context_window.remaining_percentage // 100) | ceil')
RATE_LIMIT_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty | ceil')
RATE_LIMIT_7D=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty | ceil')

parts=()
[ -n "$MODEL" ] && parts+=("${MODEL}${EFFORT:+ ($EFFORT)}")
if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  [ -n "$BRANCH" ] && parts+=("$BRANCH")
fi
usage="${CTX_REMAIN}% left"
[ -n "$RATE_LIMIT_5H" ] && usage+=" / 5h ${RATE_LIMIT_5H}%"
[ -n "$RATE_LIMIT_7D" ] && usage+=" / 7d ${RATE_LIMIT_7D}%"
parts+=("$usage")

out=""
for p in "${parts[@]}"; do
  out+="${out:+ | }$p"
done
echo "$out"
