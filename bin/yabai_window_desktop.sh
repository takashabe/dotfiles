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

## display 1
yabai -m rule --add label=alacritty app="Alacritty" display=1 space=1
yabai -m rule --add label=vscode app="Code" display=1 space=1

yabai -m rule --add label=edge app="Microsoft Edge" display=1 space=2

## display 2
yabai -m rule --add label=obsidian app="Obsidian" display=2 space=3
yabai -m rule --add label=notion app="Notion" display=2 space=3
yabai -m rule --add label=slack app="Slack" display=2 space=4
yabai -m rule --add label=gather app="Gather" display=2 space=4
