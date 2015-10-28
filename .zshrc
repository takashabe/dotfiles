# Encoding
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

### 通常コマンドのalias
alias l='ls -alv'
# 古い環境などxterm-256colorやscreen-256colorを認識しない環境用
alias ssh='TERM=xterm ssh'

# oh-my-zsh
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(brew git github tmux debian python pyenv macports redis nodebew npm node go)
source $ZSH/oh-my-zsh.sh

# general path
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export PATH=/opt/local/bin:/opt/local/sbin:~/bin:$PATH
fpath=(~/dotfiles/zsh-completions/src $fpath)

# vim
case "$(uname)" in
  Darwin) # OSがMacならば
    if [[ -d /Applications/MacVim.app ]]; then # MacVimが存在するならば
      alias vim=/Applications/MacVim.app/Contents/MacOS/Vim
      alias vi=vim
    fi
    ;;

  *) ;; # OSがMac以外ならば何もしない
esac

# tmux auto load
if [ -z "$TMUX" -a -z "$STY" ]; then
  if type tmuxx >/dev/null 2>&1; then
    tmuxx
  elif type tmux >/dev/null 2>&1; then
    if tmux has-session && tmux list-sessions | /usr/bin/grep -qE '.*]$'; then
      tmux attach && echo "tmux attached session "
    else
      tmux new-session && echo "tmux created new session"
    fi
  fi
fi

# 履歴をウィンドウ間で共有しない
unsetopt share_history

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# pyenv
eval "$(pyenv virtualenv-init -)"

# google cloud sdk
export PATH=~/google-cloud-sdk/bin:$PATH

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# go
export GOROOT=/usr/local/opt/go/libexec
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
