# general function
function reload_config
  exec fish -l
end
function edit_config
  vim ~/dotfiles/.config/fish/config.fish
end

##################################### general
set -x PATH $HOME/bin $PATH

## basic command alias
alias l 'ls -alvh'
alias ll 'ls -lvh'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias curl-android 'curl -A "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.167 Mobile Safari/537.36"'
alias curl-ios 'curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1"'

## Encoding
set -x LC_CTYPE en_US.UTF-8
set -x LC_ALL en_US.UTF-8

## Prompt
set -x PROMPT_ICON "(*'-')"
set -x PROMPT_ERROR_ICON "(*;_;)"

## vim
set -x EDITOR nvim
alias vi '/usr/local/bin/nvim'
alias vim '/usr/local/bin/nvim'

alias diff 'colordiff'

# git, github
alias gst 'git status'
alias gb 'git branch'
alias gad 'git add'
alias gc 'git commit -v'
alias h 'hub'
function gbp
  git branch -a --sort=-authordate | cut -b 3- | perl -pe 's#^remotes/origin/###' | perl -nlE 'say if !$c{$_}++' | grep -v -- "->" | peco | xargs git checkout
end

# gnu tools
set -x PATH /usr/local/opt/gnu-sed/libexec/gnubin $PATH

# for not supported 256-color
alias ssh 'env TERM=xterm ssh'

# less
set -x LESS '-R'
set -x LESSOPEN '| /usr/local/bin/src-hilite-lesspipe.sh %s'

### homebrew
set -x PATH /usr/local/bin $PATH
# openssl with homebrew
set -x PATH /usr/local/opt/openssl/bin $PATH
# ccat
alias cat 'ccat'

# nodebrew
set -x PATH $HOME/.nodebrew/current/bin $PATH

# rbenv
rbenv init - | source

# java
set -x JAVA_HOME (/usr/libexec/java_home)

# tmux
if status --is-interactive; and test -z $TMUX
  set -l wname "<°)))彡"
  if tmux has-session > /dev/null ^ /dev/null
    # attach tmux session with percol like tool
    set -l sid (tmux list-sessions | grep '' | peco | cut -d: -f1)
    command tmux attach-session -t $sid
  else
    command tmux new-session -n $wname
  end
end
alias tmw peco_select_tmux_window

# z
set -x Z_DATA $HOME/.z

function reload_tmux
  tmux source-file ~/.tmux.conf
  echo "reload tmux"
end

# gcloud
if status --is-interactive
  bass source "$HOME/bin/google-cloud-sdk/path.bash.inc"
  bass source "$HOME/bin/google-cloud-sdk/completion.bash.inc"
end

### docker, k8s
alias d 'docker'
alias k 'kubectl'
alias mk '/usr/local/bin/minikube'
alias kcp peco_select_k8s_context

# Golang
set -x GOROOT /usr/local/opt/go/libexec
set -x GOPATH $HOME/dev
set -x PATH $GOPATH/bin $GOROOT/bin $PATH
## TODO: Support recursive gocover
function gocover
  go test -coverprofile cover.out ./...; and go tool cover -html=cover.out; and rm cover.out
end
## reload gocode
function gocode_reload
  gocode close
  go get -u github.com/nsf/gocode
end

### Rust
set -x PATH $HOME/.cargo/bin $PATH

### Python
set -x PATH /usr/local/Cellar/python@2/2.7.15/bin $PATH

### Key binding
function fish_user_key_bindings
  bind \c] peco_select_ghq
  bind \cr peco_select_history
  bind \cu peco_select_z
  bind \co peco_select_file
end

# direnv
eval (direnv hook fish)

### env for application, token, secret
source $HOME/.config/fish/conf.d/env.fish
