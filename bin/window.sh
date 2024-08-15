#!/usr/bin/env bash
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title window
# @raycast.mode compact
#
# Optional parameters:
# @raycast.icon 💻
#
# 指定のアプリケーションを目的のスペースに移動する

set -euo pipefail

# スペースの初期設定
"$(dirname "$0")"/space.sh

# 起動済みのアプリケーションを目的のスペースに移動する
declare -A app_to_space=(
  ["Alacritty"]=1
  ["Code"]=1
  ["Arc"]=2
  ["Obsidian"]=3
  ["Focus To-Do"]=3
  ["Todoist"]=3
  ["Slack"]=4
  ["Gather"]=4
)
for app in "${!app_to_space[@]}"; do
  target_space=${app_to_space[$app]}
  window_ids=$(yabai -m query --windows | jq -r ".[] | select(.app == \"$app\").id")
  for id in $window_ids; do
    if [ ! -z "$id" ]; then
      yabai -m window $id --space $target_space
    fi
  done
done
