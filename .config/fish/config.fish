# general function
function reload_config
  exec fish -l
end
function edit_config
  vim ~/dotfiles/.config/fish/config.fish
end

# Encoding
set -x LC_CTYPE en_US.UTF-8
set -x LC_ALL en_US.UTF-8

# vim
set -x EDITOR nvim
alias vim '/usr/local/bin/nvim'
alias oldvim '/usr/local/bin/vim'

# basic command alias
alias l 'ls -alvh'
alias ll 'ls -lvh'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

# git
alias gst 'git status'
alias gb 'git branch'
alias gad 'git add'
alias gc 'git commit -v'


# gnu tools
set -x PATH /usr/local/opt/gnu-sed/libexec/gnubin $PATH

# for not supported 256-color
alias ssh 'env TERM=xterm ssh'

# less
set -x LESS '-R'
set -x LESSOPEN '| /usr/local/bin/src-hilite-lesspipe.sh %s'

# homebrew
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

# gcloud
if status --is-interactive
  bass source '/Users/takashabe/google-cloud-sdk/path.bash.inc'
  bass source '/Users/takashabe/google-cloud-sdk/completion.bash.inc'
end

# golang
set -x GOROOT /usr/local/opt/go/libexec
set -x GOPATH $HOME/dev
set -x PATH $GOPATH/bin $GOROOT/bin $PATH
# TODO: Support recursive gocover
function gocover
  go test -coverprofile cover.out; and go tool cover -html=cover.out; and rm cover.out
end

### key binding
function fish_user_key_bindings
  bind \c] peco_select_ghq
  bind \cr peco_select_history
  bind \cj peco_select_z
  bind \cf peco_select_file
end
