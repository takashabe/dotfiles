#!/bin/bash
# niri-action.sh - rofiからniriのアクションを実行するランチャー
# Usage: niri-action.sh
#   rofi経由: Super+Dなどでrofiを開いた後にこのスクリプトを呼ぶか、
#   直接: niri keybindに `spawn "niri-action.sh"` を追加

declare -A actions

# --- アプリ起動 ---
actions["  Terminal (Ghostty)"]="spawn ghostty"
actions["  Browser (Vivaldi)"]="spawn vivaldi"
actions["  File Manager (Nautilus)"]="spawn nautilus"

# --- ウィンドウ操作 ---
actions["  Close Window"]="close-window"
actions["  Fullscreen"]="fullscreen-window"
actions["  Toggle Floating"]="toggle-window-floating"
actions["  Center Column"]="center-column"
actions["  Maximize Column"]="maximize-column"
actions["  Switch Preset Width"]="switch-preset-column-width"

# --- レイアウト ---
actions["  Toggle Tabbed Display"]="toggle-column-tabbed-display"
actions["  Consume Window Left"]="consume-or-expel-window-left"
actions["  Expel Window Right"]="consume-or-expel-window-right"
actions["  Expand to Available Width"]="expand-column-to-available-width"

# --- ワークスペース移動 ---
actions["  Go to WS1 (DP-1)"]="focus-workspace ws1"
actions["  Go to WS2 (DP-1)"]="focus-workspace ws2"
actions["  Go to WS3 (HDMI)"]="focus-workspace ws3"
actions["  Go to WS4 (HDMI)"]="focus-workspace ws4"

# --- ウィンドウをワークスペースに送る ---
actions["  Send to WS1"]="move-window-to-workspace ws1"
actions["  Send to WS2"]="move-window-to-workspace ws2"
actions["  Send to WS3"]="move-window-to-workspace ws3"
actions["  Send to WS4"]="move-window-to-workspace ws4"

# --- モニタ操作 ---
actions["  Focus Monitor Left"]="focus-monitor-left"
actions["  Focus Monitor Right"]="focus-monitor-right"
actions["  Move Window to Monitor Left"]="move-window-to-monitor-left"
actions["  Move Window to Monitor Right"]="move-window-to-monitor-right"

# --- スクリーンショット ---
actions["  Screenshot (Interactive)"]="screenshot"
actions["  Screenshot Screen"]="screenshot-screen"
actions["  Screenshot Window"]="screenshot-window"

# --- システム ---
actions["  Reload Config"]="load-config-file"
actions["  Power Off Monitors"]="power-off-monitors"
actions["  Show Hotkey Overlay"]="show-hotkey-overlay"
actions["  Toggle Overview"]="toggle-overview"
actions["  Quit niri"]="quit"

# rofiで選択
selected=$(printf '%s\n' "${!actions[@]}" | sort | rofi -dmenu -i -p "niri" -theme-str 'window {width: 40%;}')

[ -z "$selected" ] && exit 0

action="${actions[$selected]}"

# spawnは特殊処理（引数をniri msg actionに渡す）
if [[ "$action" == spawn\ * ]]; then
  app="${action#spawn }"
  niri msg action spawn "$app"
else
  niri msg action $action
fi
