#!/usr/bin/env bash
#
# macOSのスペースをディスプレイの数に応じて調整する
# required: jq, yabai

set -euo pipefail

# ディスプレイの数を取得
display_count=$(yabai -m query --displays | jq 'length')

# ディスプレイが1枚の場合のスペースの目標数
target_spaces_single_display=4
# ディスプレイが2枚の場合の1ディスプレイあたりのスペースの目標数
target_spaces_per_display=2

# 目標スペース数を設定
if [ "$display_count" -eq 1 ]; then
    target_num_spaces=$target_spaces_single_display
else
    target_num_spaces=$target_spaces_per_display
fi

# ディスプレイごとにスペースを調整
for (( display_id=1; display_id<=$display_count; display_id++ ))
do
    # 現在のスペースの数を取得
    current_spaces=$(yabai -m query --displays --display $display_id | jq '.spaces | length')

    # スペースが目標数より多い場合、超過分を削除
    while [ $current_spaces -gt $target_num_spaces ]; do
        yabai -m display --focus $display_id
        yabai -m space --destroy
        let current_spaces-=1
    done

    # スペースが目標数未満の場合、不足分を追加
    while [ $current_spaces -lt $target_num_spaces ]; do
        yabai -m display --focus $display_id
        yabai -m space --create
        let current_spaces+=1
    done
done
