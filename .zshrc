# Encoding
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# oh-my-zsh
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="gentoo"
plugins=(git github tmux debian)
source $ZSH/oh-my-zsh.sh

# general path
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export PATH=/opt/local/bin:/opt/local/sbin:~/bin:$PATH
fpath=(~/dotfiles/zsh-completions/src $fpath)

# alias
alias l='ls -alv'

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
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
