#!/usr/bin/env bash

# https://code.claude.com/docs/en/statusline#full-json-schema
input=$(cat)

CTX_REMAIN=$(echo "$input" | jq -r '(.context_window.remaining_percentage // 100) | ceil')
RATE_LIMIT_5H=$(echo "$input" | jq -r '(.rate_limits.five_hour.used_percentage // 100) | ceil')
RATE_LIMIT_7D=$(echo "$input" | jq -r '(.rate_limits.seven_day.used_percentage // 100) | ceil')

if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  echo -e " $BRANCH | ${CTX_REMAIN}% left / 5h ${RATE_LIMIT_5H}% / 7d ${RATE_LIMIT_7D}%"
else
  echo -e "${CTX_REMAIN}% left / 5h ${RATE_LIMIT_5H}% / 7d ${RATE_LIMIT_7D}%"
fi
