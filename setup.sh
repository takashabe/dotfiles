#!/bin/bash

## .rc files for home directory
ln -s $HOME/dotfiles/.tmux.conf $HOME/
ln -s $HOME/dotfiles/.gitconfig $HOME/
ln -s $HOME/dotfiles/.gitignore $HOME/
ln -s $HOME/dotfiles/.ideavimrc $HOME/
ln -s $HOME/dotfiles/.tigrc $HOME/
ln -s $HOME/dotfiles/.agignore $HOME/
ln -s $HOME/dotfiles/.Xresources $HOME/

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

# vscode
ln -s $HOME/dotfiles/.config/code/vsicons.settings.json  $HOME/Library/Application\ Support/Code/User/
ln -s $HOME/dotfiles/.config/code/settings.json  $HOME/Library/Application\ Support/Code/User/
ln -s $HOME/dotfiles/.config/code/keybindings.json $HOME/Library/Application\ Support/Code/User/

# TODO homebrew, ghq関連の追加
# TODO linux/macos双方で動くようにしたい

# Linux only
if [ uname = "Linux" ]; then
  ln -s $HOME/dotfiles/.config/xremap/  $HOME/.config/xremap/
fi
