#!/bin/bash

## .rc files for home directory
ln -s $HOME/dotfiles/.vimrc $HOME/
ln -s $HOME/dotfiles/.tmux.conf $HOME/
ln -s $HOME/dotfiles/.gitconfig $HOME/
ln -s $HOME/dotfiles/.gitignore $HOME/
ln -s $HOME/dotfiles/.tigrc $HOME/
ln -s $HOME/dotfiles/.Xresources $HOME/
ln -s $HOME/dotfiles/.screenlayout $HOME/
ln -s $HOME/dotfiles/.terraformrc $HOME/
ln -s $HOME/dotfiles/.yabairc $HOME/
ln -s $HOME/dotfiles/.skhdrc $HOME/
ln -s $HOME/dotfiles/.myclirc $HOME/
ln -s $HOME/dotfiles/.imwheelrc $HOME/
ln -s $HOME/dotfiles/.xprofile $HOME/

## $HOME/bin
mkdir $HOME/bin
cp $HOME/dotfiles/diff-highlight $HOME/bin

# $HOME/.config
ln -s $HOME/dotfiles/.config/fish/config.fish $HOME/.config/fish/
ln -s $HOME/dotfiles/.config/karabiner $HOME/.config/
ln -s $HOME/dotfiles/.config/nvim $HOME/.config/
ln -s $HOME/dotfiles/.config/tmux $HOME/.config/
ln -s $HOME/dotfiles/.config/alacritty $HOME/.config/
ln -s $HOME/dotfiles/.config/rofi $HOME/.config/
ln -s $HOME/dotfiles/.config/i3 $HOME/.config/
ln -s $HOME/dotfiles/.config/i3blocks $HOME/.config/
ln -s $HOME/dotfiles/.config/Xresources.d $HOME/.config/
ln -s $HOME/dotfiles/.config/vim $HOME/.config/
ln -s $HOME/dotfiles/.config/fontconfig $HOME/.config/

# vscode
if [ $(uname) = "Linux" ]; then
  CODE_PATH=$HOME/.config/Code/User/
else
  CODE_PATH=$HOME/Library/Application\ Support/Code/User/
fi
ln -s $HOME/dotfiles/.config/code/vsicons.settings.json $CODE_PATH
ln -s $HOME/dotfiles/.config/code/settings.json $CODE_PATH
ln -s $HOME/dotfiles/.config/code/keybindings.json $CODE_PATH

if [ $(uname) = "Linux" ]; then
  echo "=== Linux only ==="
  ln -s $HOME/dotfiles/.config/xremap/  $HOME/.config/xremap/
  ln -s $HOME/dotfiles/.config/xkeysnail/  $HOME/.config/xkeysnail/
  ln -s $HOME/dotfiles/.config/systemd/user/xkeysnail.service $HOME/.config/systemd/user/
  ln -s $HOME/dotfiles/.config/systemd/user/imwheel.service $HOME/.config/systemd/user/
  ln -s $HOME/dotfiles/.gitconfig.credential.linux $HOME/.gitconfig.credential
fi

if [ $(uname) = "Darwin" ]; then
  # -int 1 == 15ms
  defaults write -g InitialKeyRepeat -int 10
  defaults write -g KeyRepeat -int 1
  # settings
  ln -s $HOME/dotfiles/.gitconfig.credential.darwin $HOME/.gitconfig.credential
fi

# TODO homebrew, homebrew-cask, yay
