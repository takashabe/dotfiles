# Encoding
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# oh-my-zsh
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="gentoo"
plugins=(knife_ssh knife bundler git github history brew scala sbt ruby rails vagrant)
source $ZSH/oh-my-zsh.sh

# general path
export PATH=/usr/local/bin:/usr/local/sbin:$PATH
export PATH=/opt/local/bin:/opt/local/sbin:~/bin:$PATH

# alias
alias l='ls -alv'
alias git='/usr/local/bin/git'

# tmux
alias tmux='tmuxx'
alias tm='tmuxx'

# tmux
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
export PATH="/Users/takashabe/.rbenv/shims:${PATH}"
source "/usr/local/Cellar/rbenv/0.4.0/libexec/../completions/rbenv.zsh"
rbenv rehash 2>/dev/null
rbenv() {
  typeset command
  command="$1"
  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$command" in
  rehash|shell)
    eval `rbenv "sh-$command" "$@"`;;
  *)
    command rbenv "$command" "$@";;
  esac
}
