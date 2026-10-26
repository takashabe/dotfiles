#!/bin/bash

DOTFILES=$HOME/dotfiles

# ln -sf だと既存の実ファイルを黙って置き換えて手元の設定を失うため、シンボリックリンク以外は警告してスキップする
# dest が / で終わる場合はそのディレクトリ配下に src と同名で張る
link() {
  local sudo=()
  if [ "$1" = "--sudo" ]; then
    sudo=(sudo)
    shift
  fi
  local src=${1%/} dest=$2
  case $dest in
    */) dest=$dest$(basename "$src") ;;
  esac

  if [ -L "$dest" ]; then
    local current
    current=$(readlink "$dest")
    [ "${current%/}" = "$src" ] && return 0
    "${sudo[@]}" ln -sfn "$src" "$dest"
  elif [ -e "$dest" ]; then
    echo "WARN: skipped $dest (exists and is not a symlink)" >&2
  else
    local parent
    parent=$(dirname "$dest")
    [ -d "$parent" ] || "${sudo[@]}" mkdir -p "$parent"
    "${sudo[@]}" ln -s "$src" "$dest"
  fi
}

## .rc files for home directory
link "$DOTFILES/.tmux.conf" "$HOME/"
link "$DOTFILES/.gitconfig" "$HOME/"
link "$DOTFILES/.gitignore" "$HOME/"
link "$DOTFILES/.tigrc" "$HOME/"
link "$DOTFILES/.terraformrc" "$HOME/"
link "$DOTFILES/.yabairc" "$HOME/"
link "$DOTFILES/.skhdrc" "$HOME/"
link "$DOTFILES/.myclirc" "$HOME/"
link "$DOTFILES/.codex" "$HOME/"
link "$DOTFILES/.claude" "$HOME/"

## $HOME/bin
for f in "$DOTFILES"/bin/*; do
  link "$f" "$HOME/bin/"
done

# $HOME/.config
link "$DOTFILES/.config/fish/config.fish" "$HOME/.config/fish/"
link "$DOTFILES/.config/karabiner" "$HOME/.config/"
link "$DOTFILES/.config/nvim" "$HOME/.config/"
link "$DOTFILES/.config/tmux" "$HOME/.config/"
link "$DOTFILES/.config/alacritty" "$HOME/.config/"
link "$DOTFILES/.config/rofi" "$HOME/.config/"
link "$DOTFILES/.config/i3" "$HOME/.config/"
link "$DOTFILES/.config/i3blocks" "$HOME/.config/"
link "$DOTFILES/.config/Xresources.d" "$HOME/.config/"
link "$DOTFILES/.config/fontconfig" "$HOME/.config/"
link "$DOTFILES/.config/wezterm" "$HOME/.config/"
link "$DOTFILES/.config/go" "$HOME/.config/"
link "$DOTFILES/.config/lazygit" "$HOME/.config/"
link "$DOTFILES/.config/ghostty" "$HOME/.config/"
link "$DOTFILES/.config/tmuxp" "$HOME/.config/"
link "$DOTFILES/.config/bat" "$HOME/.config/"
link "$DOTFILES/.config/mcphub" "$HOME/.config/"
link "$DOTFILES/.config/gitui" "$HOME/.config/"
link "$DOTFILES/.config/zellij" "$HOME/.config/"
link "$DOTFILES/.config/hypr" "$HOME/.config/"
link "$DOTFILES/.config/niri" "$HOME/.config/"
link "$DOTFILES/.config/ironbar" "$HOME/.config/"
link "$DOTFILES/.config/noctalia" "$HOME/.config/"
link "$DOTFILES/.config/environment.d" "$HOME/.config/"
link "$DOTFILES/.config/herdr/config.toml" "$HOME/.config/herdr/"
link "$DOTFILES/.config/vivaldi-stable.conf" "$HOME/.config/"

# vscode
if [ "$(uname)" = "Linux" ]; then
  CODE_PATH=$HOME/.config/Code/User/
else
  CODE_PATH="$HOME/Library/Application Support/Code/User/"
fi
link "$DOTFILES/.config/code/vsicons.settings.json" "$CODE_PATH"
link "$DOTFILES/.config/code/settings.json" "$CODE_PATH"
link "$DOTFILES/.config/code/keybindings.json" "$CODE_PATH"

if [ "$(uname)" = "Linux" ]; then
  echo "=== Linux only ==="
  link "$DOTFILES/.config/xremap/" "$HOME/.config/"
  link "$DOTFILES/.config/systemd/user/xremap.service" "$HOME/.config/systemd/user/"
  link "$DOTFILES/.config/systemd/user/hyprland-session.target" "$HOME/.config/systemd/user/"
  ln -sfn linux "$DOTFILES/.config/ghostty/os"
  link "$DOTFILES/.gitconfig.credential.linux" "$HOME/.gitconfig.credential"
  link "$DOTFILES/.config/paru" "$HOME/.config/"
  link "$DOTFILES/.local/share/applications/screenshot.desktop" "$HOME/.local/share/applications/"
  link "$DOTFILES/.local/share/applications/tiling-restart.desktop" "$HOME/.local/share/applications/"

  # /etc
  link --sudo "$DOTFILES/etc/greetd/config.toml" /etc/greetd/config.toml
  for f in "$DOTFILES"/etc/sysctl.d/*; do
    link --sudo "$f" /etc/sysctl.d/
  done
  ## network, time
  sudo ln -sf "$DOTFILES/etc/nftables.conf" /etc/nftables.conf
  sudo systemctl enable --now nftables systemd-timesyncd
  ## 1password
  # ブラウザ検証のため root 所有である必要があり、symbolic link だと動かないためコピーする
  sudo install -D -o root -g root -m 755 "$DOTFILES/etc/1password/custom_allowed_browsers" /etc/1password/custom_allowed_browsers
  ## xremap
  sudo modprobe uinput
  sudo cp "$DOTFILES/etc/modules-load.d/uinput.conf" /etc/modules-load.d/uinput.conf
  # symbolic link だと動かないためコピーする
  sudo cp "$DOTFILES/etc/udev/rules.d/99-input.rules" /etc/udev/rules.d/
fi

if [ "$(uname)" = "Darwin" ]; then
  echo "=== macOS only ==="
  # -int 1 == 15ms
  defaults write -g InitialKeyRepeat -int 10
  defaults write -g KeyRepeat -int 1
  # settings
  link "$DOTFILES/.gitconfig.credential.darwin" "$HOME/.gitconfig.credential"
  link "$DOTFILES/.config/sketchybar/" "$HOME/.config/"
  link "$DOTFILES/.config/aerospace/" "$HOME/.config/"
  ln -sfn darwin "$DOTFILES/.config/ghostty/os"
  # enable key repeat for vscode. https://twismik0.hatenablog.com/entry/2017/08/14/115502
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
  defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false
  # disable accent character input. https://discussions.apple.com/thread/252082207?sortBy=rank
  defaults write -g ApplePressAndHoldEnabled -bool false
fi

# TODO homebrew, homebrew-cask, paru
