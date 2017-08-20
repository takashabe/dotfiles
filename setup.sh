#!/bin/sh

ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.ideavimrc ~/.ideavimrc
ln -s ~/dotfiles/.tigrc ~/.tigrc

mkdir ~/bin
cp ~/dotfiles/coloredlogcat.py ~/bin
cp ~/dotfiles/tmuxx ~/bin
cp ~/dotfiles/diff-highlight ~/bin

# fish
ln -s ~/dotfiles/.config/fish/config.fish ~/.config/fish/config.fish

# karabiner
ln -s ~/dotfiles/.config/karabiner ~/.config/karabiner

# neovim
ln -s ~/dotfiles/.config/nvim ~/.config/nvim

# TODO homebrew, ghq関連の追加
# TODO linux/macos双方で動くようにしたい
