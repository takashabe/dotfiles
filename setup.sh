#!/bin/sh

ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.gvimrc ~/.gvimrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf

mkdir ~/bin
cp ~/dotfiles/coloredlogcat.py ~/bin
cp ~/dotfiles/tmuxx ~/bin
cp ~/dotfiles/diff-highlight ~/bin

curl -L http://install.ohmyz.sh | sh
