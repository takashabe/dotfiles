# Encoding
set -x LC_CTYPE ja_JP.UTF-8
set -x LC_ALL ja_JP.UTF-8

# alias
alias l 'ls -alv'
alias ll 'ls -lv'
alias gst 'git status'
alias gc 'git commit -v'

# for not supported 256-color
alias ssh 'TERM=xterm ssh'

# general path
set -x PATH /usr/local/bin /usr/local/sbin $PATH

# tmux auto load
if status --is-interactive; and test -z $TMUX
  set -l wname "🐟"
  if tmux has-session > /dev/null ^ /dev/null
    # attach tmux session with percol like tool
    set -l sid (tmux list-sessions | grep '' | peco | cut -d: -f1)
    command tmux attach-session -t $sid -n $wname
  else
    command tmux new-session -n $wname
  end
end

# rbenv
# TODO

# pyenv
# TODO

# nodebrew
# TODO

# golang
set -x GOROOT /usr/local/opt/go/libexec
set -x GOPATH $HOME/dev
set -x PATH $GOPATH/bin $GOROOT/bin $PATH
