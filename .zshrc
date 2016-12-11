# Load plugins
source ~/.zshrc.plugin

# Encoding
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# alias
alias l='ls -alv'
alias ll='ls -lv'

# for not supported 256-color
alias ssh='TERM=xterm ssh'

# general path
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export PATH=/opt/local/bin:/opt/local/sbin:~/bin:$PATH
fpath=(~/dotfiles/zsh-completions/src $fpath)

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

# rbenv
export RBENV_ROOT=/usr/local/var/rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then
  eval "$(rbenv init - zsh)";
fi

# pyenv
eval "$(pyenv virtualenv-init -)"

# google cloud sdk
export PATH=~/google-cloud-sdk/bin:$PATH

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# go
export GOROOT=/usr/local/opt/go/libexec
export GOPATH=$HOME/dev
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# peco
function peco-src () {
  local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
  if [ -n "$selected_dir" ]; then
    BUFFER="cd ${selected_dir}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src
