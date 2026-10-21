#!/usr/bin/env bash
set -euo pipefail

dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"

# slurp を Esc で取り消すと非 0 で終わるので、撮影せずに抜ける
geometry=$(slurp -d) || exit 0

# ppm は無圧縮で PNG エンコードを挟まない分、Satty が早く開く
grim -g "$geometry" -t ppm - | satty --filename - \
  --output-filename "$dir/%Y-%m-%d %H-%M-%S.png" \
  --copy-command wl-copy \
  --actions-on-enter save-to-clipboard,exit
