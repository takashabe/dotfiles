#!/bin/sh

ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.gvimrc ~/.gvimrc
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/.gitconfig ~/.gitconfig

ln -s ~/dotfiles/.vim ~/.vim
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh

mkdir ~/bin
cp ~/dotfiles/coloredlogcat.py ~/bin
cp ~/dotfiles/tmuxx ~/bin
cp ~/dotfiles/diff-highlight ~/bin

curl -L http://install.ohmyz.sh | sh

# TODO homebrew, peco/ghq関連の追加
# TODO linux/macos双方で動くようにしたい
