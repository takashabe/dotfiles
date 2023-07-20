#!/bin/bash
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title yabai stsart
# @raycast.mode compact
#
# Optional parameters:
# @raycast.icon 🤖

cnt=$(ps aux | grep -v grep | grep /opt/homebrew/bin/yabai | wc -l)

if [ $cnt -gt 0 ]; then
  yabai --restart-service
else
  yabai --start-service
fi

skhd --restart-service
