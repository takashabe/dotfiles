#!/usr/bin/env bash
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title yabai_window_laptop
# @raycast.mode compact
#
# Optional parameters:
# @raycast.icon 💻
#
# デスクトップとして使う場合のwindow設定

set -euo pipefail

# アプリケーションごとのスペース初期設定
## display 1
yabai -m rule --add label=alacritty app="Alacritty" display=1 space=1
yabai -m rule --add label=vscode app="Code" display=1 space=1
yabai -m rule --add label=arc app="Arc" display=1 space=2
## display 2
yabai -m rule --add label=obsidian app="Obsidian" display=2 space=3
yabai -m rule --add label=notion app="Notion" display=2 space=3
yabai -m rule --add label=slack app="Slack" display=2 space=4
yabai -m rule --add label=gather app="Gather" display=2 space=4


# 起動済みのアプリケーションを目的のスペースに移動する
declare -A app_to_space=(
    ["Alacritty"]=1
    ["Code"]=1
    ["Arc"]=2
    ["Obsidian"]=3
    ["Notion"]=3
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
