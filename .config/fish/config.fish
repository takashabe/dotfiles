# Reload config
function reload_config
  exec fish -l
end

# Encoding
set -x LC_CTYPE ja_JP.UTF-8
set -x LC_ALL ja_JP.UTF-8

# alias
alias l 'ls -alv'
alias ll 'ls -lv'
alias gst 'git status'
alias gc 'git commit -v'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

# for not supported 256-color
alias ssh 'TERM=xterm ssh'

# general path
set -x PATH /usr/local/bin /usr/local/sbin $PATH

# tmux
if status --is-interactive; and test -z $TMUX
  set -l wname "shell"
  if tmux has-session > /dev/null ^ /dev/null
    # attach tmux session with percol like tool
    set -l sid (tmux list-sessions | grep '' | peco | cut -d: -f1)
    command tmux attach-session -t $sid
  else
    command tmux new-session -n $wname
  end
end

function reload_tmux
  tmux source-file ~/.tmux.conf
  echo "reload tmux"
end

# rbenv
# TODO

# pyenv
status --is-interactive; and source (pyenv init -|psub)

# nodebrew
# TODO

# golang
set -x GOROOT /usr/local/opt/go/libexec
set -x GOPATH $HOME/dev
set -x PATH $GOPATH/bin $GOROOT/bin $PATH

# peco
function peco_select_ghq
  set -l query (commandline)

  if test -n $query
    set peco_flags --query "$query"
  end

  ghq list -p | peco $peco_flags | read line

  if [ $line ]
    cd $line
    commandline -f repaint
  end
end

function peco_select_history
  set -l query (commandline)

  if test -n $query
    set peco_flags --query "$query"
  end

  history | peco $peco_flags | read line

  if [ $line ]
    commandline $line
  else
    commandline ''
  end
end

### key binding
function fish_user_key_bindings
  bind \c] peco_select_ghq
  bind \cr peco_select_history
end
