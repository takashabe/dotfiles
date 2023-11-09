#!/usr/bin/env bash
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title yabai_window_desktop
# @raycast.mode compact
#
# Optional parameters:
# @raycast.icon 🖥
#
# laptop単体で使う場合のwindow設定

set -euo pipefail

yabai -m rule --add label=alacritty app="Alacritty" space=1
yabai -m rule --add label=vscode app="Code" space=1

yabai -m rule --add label=arc app="Arc" space=2

yabai -m rule --add label=obsidian app="Obsidian" space=3

yabai -m rule --add label=slack app="Slack" space=4
yabai -m rule --add label=gather app="Gather" space=4
