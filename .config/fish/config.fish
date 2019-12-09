## fish plugin manager
# TODO

##################################### general
## basic command alias
alias rm 'rmtrash'
alias mv 'mv -i'
alias diff 'colordiff'
alias l 'ls -alvh'
alias ll 'ls -lvh'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

set -x PATH $HOME/bin $PATH
set -x PATH $HOME/.local/bin $PATH

## Encoding
set -x LANG en_US.UTF-8
set -x LC_CTYPE en_US.UTF-8

## Prompt
set -x PROMPT_ICON "(*'-')"
set -x PROMPT_ERROR_ICON "(*;_;)"
set -x PROMPT_ENABLE_K8S_CONTEXT 1
set -x PROMPT_ENABLE_K8S_NAMESPACE 1
set -x PROMPT_ENABLE_GCLOUD_PROJECT 1

## vim
alias vi vim
set -x EDITOR vim

## alternative grep
alias rg 'rg --hidden'

## fzf
set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --glob "!.git/*"'

# curl
alias curl-android 'curl -A "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.167 Mobile Safari/537.36"'
alias curl-ios 'curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1"'
function curl-xml-ios
  if test (count $argv) -lt 1
    echo 'require: url'
    return 128
  end
  curl-ios $argv[1] | xmllint --format -
end
function curl-xml-android
  if test (count $argv) -lt 1
    echo 'require: url'
    return 128
  end
  curl-android $argv[1] | xmllint --format -
end

# git, github
alias git 'hub'
alias g 'git'
alias gst 'git status'
alias gb 'git branch'
alias gc 'git commit -v'
function gbp
  git branch -a --sort=-authordate | cut -b 3- | perl -pe 's#^remotes/origin/###' | perl -nlE 'say if !$c{$_}++' | grep -v -- "->" | peco | xargs git checkout
end
function gcm
  if test (count $argv) -lt 1
    echo 'require: branch name'
    return 128
  end
  git checkout -b $argv[1] origin/master
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
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
# openssl with homebrew
set -x PATH /usr/local/opt/openssl/bin $PATH
# ccat
alias cat 'ccat'

# nodebrew
if status --is-interactive; and command -v nodebrew > /dev/null
  set -x PATH $HOME/.nodebrew/current/bin $PATH
end

# rbenv
if status --is-interactive; and command -v rbenv > /dev/null
  rbenv init - | source
end

# java
# TODO: consider java_home handling
if status --is-interactive; and command -v java > /dev/null
  set -x JAVA_HOME (/usr/libexec/java_home)
end

# tmux
if status --is-interactive
  if test -z $TMUX
    set -l wname "fish"
    if tmux has-session > /dev/null ^ /dev/null
      # attach tmux session with percol like tool
      set -l sid (tmux list-sessions | grep '' | peco | cut -d: -f1)
      command tmux -u attach-session -t $sid
    else
      command tmux -u new-session -n $wname
    end
  end
end

# z
set -x Z_DATA $HOME/.z

function reload_tmux
  tmux source-file ~/.tmux.conf
  echo "reload tmux"
end

### gcloud
## load completion
if status --is-interactive
  if test (uname) = "Linux"
    source "/opt/google-cloud-sdk/path.fish.inc"
  else
    bass source "$HOME/bin/google-cloud-sdk/path.bash.inc"
    bass source "$HOME/bin/google-cloud-sdk/completion.bash.inc"
  end
end

## switch gcloud project
function switch_gcloud
  if test (count $argv) -lt 1
    echo 'usage: switch_gcloud <private> or <work>'
    return 128
  end
  set -l env $argv[1]
  if test $env = "private"
    echo "switch to private"
    gcloud config set project (echo $GCLOUD_PRIVATE_PROJECT)
    gcloud config set account (echo $GCLOUD_PRIVATE_ACCOUNT)
  else if test "$env" = "work"
    echo "switch to work"
    gcloud config set project (echo $GCLOUD_WORK_PROJECT)
    gcloud config set account (echo $GCLOUD_WORK_ACCOUNT)
  end
end

### docker, k8s
alias dk 'docker'
alias dkc 'docker-compose'
alias k 'kubectl'
alias kg 'kubectl get'
alias kt 'kubectl top'
alias kd 'kubectl describe'
alias kcp peco_select_k8s_context
alias knp peco_select_k8s_namespace
set -x PATH $HOME/bin/kubebuilder $PATH
set -x PATH $HOME/.krew/bin $PATH
set -x DOCKER_BUILDKIT 1
function docker_clean
  docker stop (docker ps -a -q)
  docker rm (docker ps -a -q)
end

# Golang
set -x GOPATH $HOME/dev
set -x PATH $GOPATH/bin $GOROOT/bin $PATH
### Install golang tool binaries
function go_install_binaries
  set -l GO_BINARIES \
    'github.com/golang/mock/gomock' \
    'github.com/golang/mock/mockgen' \
    'golang.org/x/tools/cmd/goimports' \
    'golang.org/x/tools/cmd/gopls' \
    'github.com/google/pprof'
  pushd $HOME
  for uri in $GO_BINARIES
    echo "go get -u $uri ..."
    go get -u $uri
  end
  popd
end

### Rust
set -x PATH $HOME/.cargo/bin $PATH

### history
function history-merge --on-event fish_preexec
  history --save
  history --merge
end

function share_history_for_peco
  history-merge
  peco_select_history
end

### Key binding
function fish_user_key_bindings
  bind \c] peco_select_ghq
  bind \cr share_history_for_peco
  bind \cu peco_select_z
  bind \co peco_select_file
  bind \cg peco_select_cd
end

# direnv
direnv hook fish | source

## note
function memo_new
  set -l memo_dir $GOPATH/src/github.com/takashabe/note/memo
  set -l now (date "+%Y%m%d_%H%M%S")

  touch $memo_dir/$now.md
  $EDITOR $memo_dir/$now.md
end
function memo_clean
  set -l memo_dir $GOPATH/src/github.com/takashabe/note/memo

  find $memo_dir -type f -size 0 | xargs rm
end
function diary_new
  set -l diary_dir $GOPATH/src/github.com/takashabe/note/diary
  set -l today (date "+%Y%m%d")

  touch $diary_dir/$today.md
  $EDITOR $dirary_dir/$today.md
end

## Slack
set -x SLACK_DEVELOPER_MENU true

# Load local env, functions and so on.
source $HOME/.config/fish/conf.d/local.fish

#### general function
function reload_config
  exec fish
end
function edit_config
  $EDITOR ~/dotfiles/.config/fish/config.fish
end

function reload_network
  sudo ifconfig en0 down
  sudo ifconfig en0 up
end

## Xorg
if status --is-interactive; and test (uname) = "Linux"
  xset m 1/2 4
  xset r rate 200 60
end
