#!/bin/sh

ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.ideavimrc ~/.ideavimrc

mkdir ~/bin
cp ~/dotfiles/coloredlogcat.py ~/bin
cp ~/dotfiles/tmuxx ~/bin
cp ~/dotfiles/diff-highlight ~/bin

# app config
# TODO: improve
cp -r ~/dotfiles/.config ~/

# fish
ln -s ~/dotfiles/.config/fish/config.fish ~/.config/fish/config.fish
ln -s ~/dotfiles/.config/fish/fish_prompt.fish ~/.config/fish/functions/fish_prompt.fish

# karabiner
ln -s ~/dotfiles/.config/karabiner/karabiner.json ~/.config/karabiner/karabiner.json

# neovim
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.config/nvim ~/.config/nvim

# TODO homebrew, ghq関連の追加
# TODO linux/macos双方で動くようにしたい
