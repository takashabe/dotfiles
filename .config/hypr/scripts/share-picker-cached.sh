#!/usr/bin/env bash
# xdg-desktop-portal-hyprland の custom_picker_binary として使う、キャッシュ付きピッカーラッパー。
#
# Chromium 系ブラウザは 1 回の画面共有でポータルの ScreenCast セッションを 2 つ作る
# (プレビュー用と本番用)。両者で restore token を共有しないため実ピッカーが 2 回出る。
# このラッパーは直近 TTL 秒 (5 秒) 以内の 2 回目以降の呼び出しに 1 回目の選択をそのまま返し、
# 1 回の共有でピッカーを 1 度だけ表示させる。
#
# 注意: TTL 秒以内に別の共有を始めると前回の選択が使い回される。別の画面/ウィンドウに
# 変えたいときは TTL 秒待つか、ブラウザの共有ダイアログの「再選択」を使う。

set -u

REAL_PICKER=/usr/bin/hyprland-share-picker
TTL=5

runtime="${XDG_RUNTIME_DIR:-/tmp}"
cache="$runtime/xdph-share-picker.cache"
lock="$runtime/xdph-share-picker.lock"

# 同時呼び出しを直列化する。1 回目がピッカーを出している間、2 回目はここで待ち、
# 解放後に新しいキャッシュを読む
exec 9>"$lock"
flock 9

now=$(date +%s)
if [ -s "$cache" ]; then
  mtime=$(stat -c %Y "$cache" 2>/dev/null || echo 0)
  if [ $((now - mtime)) -le "$TTL" ]; then
    cat "$cache"
    exit 0
  fi
fi

# 実ピッカーを対話表示する。XDPH_WINDOW_SHARING_LIST などの環境変数は xdph が
# セットしたものがそのまま継承される
out=$("$REAL_PICKER" "$@")
rc=$?

if [ "$rc" -eq 0 ] && [ -n "$out" ]; then
  printf '%s\n' "$out" | tee "$cache"
else
  # キャンセルや失敗はキャッシュせず、そのまま返す
  rm -f "$cache"
  [ -n "$out" ] && printf '%s\n' "$out"
  exit "$rc"
fi
