#!/bin/sh

## .rc files for home directory
ln -s ~/dotfiles/.tmux.conf ~/
ln -s ~/dotfiles/.gitconfig ~/
ln -s ~/dotfiles/.gitignore ~/
ln -s ~/dotfiles/.ideavimrc ~/
ln -s ~/dotfiles/.tigrc ~/
ln -s ~/dotfiles/.agignore ~/

## ~/bin
mkdir ~/bin
cp ~/dotfiles/coloredlogcat.py ~/bin
cp ~/dotfiles/tmuxx ~/bin
cp ~/dotfiles/diff-highlight ~/bin

# ~/.config
ln -s ~/dotfiles/.config/fish/config.fish ~/.config/fish/
ln -s ~/dotfiles/.config/karabiner ~/.config/
ln -s ~/dotfiles/.config/nvim ~/.config/
ln -s ~/dotfiles/.config/tmux ~/.config/
ln -s ~/dotfiles/.config/peco ~/.config/

# vscode
ln -s ~/dotfiles/.config/code/vsicons.settings.json  ~/Library/Application\ Support/Code/User/
ln -s ~/dotfiles/.config/code/settings.json  ~/Library/Application\ Support/Code/User/
ln -s ~/dotfiles/.config/code/keybindings.json ~/Library/Application\ Support/Code/User/

# TODO homebrew, ghq関連の追加
# TODO linux/macos双方で動くようにしたい
