#!/bin/bash

## .rc files for home directory
ln -s $HOME/dotfiles/.tmux.conf $HOME/
ln -s $HOME/dotfiles/.gitconfig $HOME/
ln -s $HOME/dotfiles/.gitignore $HOME/
ln -s $HOME/dotfiles/.ideavimrc $HOME/
ln -s $HOME/dotfiles/.tigrc $HOME/
ln -s $HOME/dotfiles/.agignore $HOME/
ln -s $HOME/dotfiles/.Xresources $HOME/
ln -s $HOME/dotfiles/.screenlayout $HOME/

## $HOME/bin
mkdir $HOME/bin
cp $HOME/dotfiles/coloredlogcat.py $HOME/bin
cp $HOME/dotfiles/tmuxx $HOME/bin
cp $HOME/dotfiles/diff-highlight $HOME/bin

# $HOME/.config
ln -s $HOME/dotfiles/.config/fish/config.fish $HOME/.config/fish/
ln -s $HOME/dotfiles/.config/karabiner $HOME/.config/
ln -s $HOME/dotfiles/.config/nvim $HOME/.config/
ln -s $HOME/dotfiles/.config/tmux $HOME/.config/
ln -s $HOME/dotfiles/.config/peco $HOME/.config/
ln -s $HOME/dotfiles/.config/alacritty $HOME/.config/
ln -s $HOME/dotfiles/.config/rofi $HOME/.config/
ln -s $HOME/dotfiles/.config/i3 $HOME/.config/
ln -s $HOME/dotfiles/.config/i3blocks $HOME/.config/

# vscode
if [ $(uname) = "Linux" ]; then
  echo "Yes Linux!"
  CODE_PATH=$HOME/.config/Code/User/
else
  echo "No Linux..."
  CODE_PATH=$HOME/Library/Application\ Support/Code/User/
fi
ln -s $HOME/dotfiles/.config/code/vsicons.settings.json $CODE_PATH
ln -s $HOME/dotfiles/.config/code/settings.json $CODE_PATH
ln -s $HOME/dotfiles/.config/code/keybindings.json $CODE_PATH

# keyremap for linux
if [ uname = "Linux" ]; then
  ln -s $HOME/dotfiles/.config/xremap/  $HOME/.config/xremap/
fi

# TODO homebrew, homebrew-cask, yay
