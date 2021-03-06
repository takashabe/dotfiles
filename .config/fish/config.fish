## fish plugin manager
# TODO

##################################### general
## basic command alias
alias make 'make --no-print-directory'
alias mv 'mv -i'
alias diff 'colordiff'
alias l 'exa -alh'
alias ll 'exa -lh'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

set -x PATH $HOME/bin $PATH
set -x PATH $HOME/.local/bin $PATH

## Encoding
set -x LANG en_US.UTF-8
set -x LC_CTYPE en_US.UTF-8

## XDG Base Directory
set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_CONFIG_HOME $HOME/.config

## Prompt
set -x PROMPT_ICON "(*'-')"
set -x PROMPT_ERROR_ICON "(*;_;)"
set -x PROMPT_ENABLE_K8S_CONTEXT 0
set -x PROMPT_ENABLE_K8S_NAMESPACE 0
set -x PROMPT_ENABLE_GCLOUD_PROJECT 1
set -x PROMPT_SHOW_ERR_STATUS 1

## vim
alias vi vim
set -x EDITOR vim

## alternative grep
alias rg "rg --hidden --glob '!.git' -i"

## fzf
set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --glob "!.git/*" -i'
set -x FZF_DEFAULT_OPTS '--height 60% --reverse --border --layout=reverse --inline-info'

## takashabe/fish-fzf
set -x FZF_CD_IGNORE_CASE '.git|vendor/|node_modules'

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
  git branch -a --sort=-authordate | cut -b 3- | perl -pe 's#^remotes/origin/###' | perl -nlE 'say if !$c{$_}++' | grep -v -- "->" | fzf | xargs git checkout
end
function gcm
  if test (count $argv) -lt 1
    echo 'require: branch name'
    return 128
  end
  git switch -c $argv[1] origin/master
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


# node
if [ -d /usr/share/nvm ] > /dev/null
  # for linux nvm
  set -x NVM_DIR $HOME/.nvm
  bass source /usr/share/nvm/nvm.sh
  bass source /usr/share/nvm/bash_completion
  bass source /usr/share/nvm/install-nvm-exec
  nvm use v12.18.0 &> /dev/null
else if [ -d (brew --prefix nvm) ]
  if status --is-interactive
    # for homebrew nvm
    # need https://github.com/jorgebucaran/nvm.fish
    set -x NVM_DIR $HOME/.nvm
    bass source (brew --prefix nvm)/nvm.sh
    bass source (brew --prefix nvm)/etc/bash_completion.d/nvm
    nvm use v12.18.0 &> /dev/null
  end
end

# rbenv
if status --is-interactive; and command -v rbenv > /dev/null
  rbenv init - | source
end

# tmux
if status --is-interactive
  if test -z $TMUX
    if tmux has-session > /dev/null ^ /dev/null
      # attach tmux session with percol like tool
      set -l sid (tmux list-sessions | grep '' | fzf | cut -d: -f1)
      command tmux -u attach-session -t $sid
    else
      command tmux -u new-session
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
set -x GOOGLE_APPLICATION_CREDENTIALS "$HOME/.config/gcloud/application_default_credentials.json"
if status --is-interactive
  if test (uname) = "Linux"
    source "/opt/google-cloud-sdk/path.fish.inc"
  else
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc"
    bass source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
  end
end

## switch gcloud project
function switch_gcloud
  fzf_gcloud_configurations
end

### docker, k8s
alias dk 'docker'
alias dkc 'docker-compose'
alias k 'kubectl'
alias kg 'kubectl get'
alias kt 'kubectl top'
alias kd 'kubectl describe'
alias kcp fzf_k8s_context
set -x PATH $HOME/bin/kubebuilder $PATH
set -x PATH $HOME/.krew/bin $PATH
set -x DOCKER_BUILDKIT 1
set -x COMPOSE_DOCKER_CLI_BUILD 1
function docker_clean
  docker stop (docker ps -a -q)
  docker rm (docker ps -a -q)
end

# Golang
set -x GOPATH $HOME/dev
set -x PATH $GOPATH/bin $GOROOT/bin $PATH
set -x GO111MODULE on
set -x GOTEST_CMD gotest
### Install golang tool binaries
function go_install_binaries
  set -l GO_BINARIES \
    'github.com/golang/mock/gomock@latest' \
    'github.com/golang/mock/mockgen@latest' \
    'golang.org/x/tools/cmd/goimports@latest' \
    'github.com/google/pprof@latest' \
    'github.com/cweill/gotests/gotests@latest' \
    'github.com/haya14busa/gtrans@latest'  \
    'github.com/rakyll/gotest@latest' \
    'github.com/fatih/gomodifytags@latest' \
    'github.com/rubenv/sql-migrate/sql-migrate@latest' \
    'github.com/swaggo/swag/cmd/swag@latest' \
    'github.com/99designs/gqlgen@latest' \
    'github.com/makiuchi-d/arelo@latest'
  pushd $HOME
  for uri in $GO_BINARIES
    echo "go install $uri ..."
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

function wrap_fzf_history
  history-merge
  fzf_history
end

function wrap_fzf_file
  fzf_file --preview "bat --style=numbers --color=always --line-range :500 {}"
end

### Key binding
function fish_user_key_bindings
  bind \c] fzf_ghq
  bind \cr wrap_fzf_history
  bind \cu fzf_z
  bind \co wrap_fzf_file
  bind \cg fzf_cd

  bind "[1;2F" kill-line
end

# direnv
direnv hook fish | source

## note
function diary_new
  set -l diary_dir $GOPATH/src/github.com/takashabe/note/diary
  set -l today (date "+%Y%m%d")

  touch $diary_dir/$today.md
  $EDITOR $diary_dir/$today.md
end

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

## osx system functions
function msleep
  osascript -e 'tell application "Finder" to sleep'
end

## Xorg
if status --is-interactive; and test (uname) = "Linux"
  xset m 1/2 4
  xset r rate 200 60
end

## Terraform
alias tf 'terraform'

## haya14busa/gtrans
# set -x GOOGLE_TRANSLATE_API_KEY "set local"
set -x GOOGLE_TRANSLATE_LANG ja
set -x GOOGLE_TRANSLATE_SECONDLANG en

## terraform
set -x TF_CLI_ARGS_plan "--parallelism=64"
set -x TF_CLI_ARGS_apply "--parallelism=64"

## Login message
# emtpy
set fish_greeting

# Load local env, functions and so on.
source $HOME/.config/fish/conf.d/local.fish

# tab completion very slow...  may be fix next-release. (3.1.3?)
# https://github.com/fish-shell/fish-shell/issues/7511
if status --is-interactive; and test (uname) = "Darwin"
  function __fish_describe_command; end
end

# mysql-client via homebrew
if status --is-interactive; and test (uname) = "Darwin"
  set -x PATH /usr/local/opt/mysql-client/bin $PATH
end

function rolling_update
  paru -Syyu --noconfirm && go_install_binaries
end
