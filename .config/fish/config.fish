# Reload config
function reload_config
  exec fish -l
end

# Encoding
set -x LC_CTYPE en_US.UTF-8
set -x LC_ALL en_US.UTF-8

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

# gcloud
if status --is-interactive
  bass source '/Users/takashabe/google-cloud-sdk/path.bash.inc'
  bass source '/Users/takashabe/google-cloud-sdk/completion.bash.inc'
end

# golang
set -x GOROOT /usr/local/opt/go/libexec
set -x GOPATH $HOME/dev
set -x PATH $GOPATH/bin $GOROOT/bin $PATH

### key binding
function fish_user_key_bindings
  bind \c] peco_select_ghq
  bind \cr peco_select_history
end
