#!/usr/bin/env bash

# https://code.claude.com/docs/en/statusline#full-json-schema
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
REMAIN=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100')

if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  echo -e " $BRANCH | ${MODEL} (${REMAIN}% context left)"
else
  echo -e "${MODEL} (${REMAIN}% context left)"
fi
