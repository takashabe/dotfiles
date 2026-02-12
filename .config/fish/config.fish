## fish plugin manager
# TODO

##################################### general
## basic command alias
alias make 'make --no-print-directory'
alias mv 'mv -i'
alias l 'eza -alh'
alias ll 'eza -lh'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias lg 'lazygit'
alias ld 'lazydocker'

if status --is-interactive; and test (uname) = "Linux"
  alias pbcopy 'wl-copy'
  alias pbpaste 'wl-paste'
end

set -x PATH $HOME/bin $PATH
set -x PATH $HOME/.local/bin $PATH
if status --is-interactive; and test (uname) = "Darwin"
  # gnu coreutils
  alias sed 'gsed'
  set -x PATH /opt/homebrew/bin $PATH
end

## Encoding
set -x LANG en_US.UTF-8
set -x LC_CTYPE en_US.UTF-8

## XDG Base Directory
set -x XDG_DATA_HOME $HOME/.local/share
set -x XDG_CACHE_HOME $HOME/.cache
set -x XDG_CONFIG_HOME $HOME/.config

## Prompt
set -x PROMPT_ICON "🐟"
set -x PROMPT_ERROR_ICON "🍣"
set -x PROMPT_ENABLE_K8S_CONTEXT 1
set -x PROMPT_ENABLE_K8S_NAMESPACE 0
set -x PROMPT_ENABLE_GCLOUD_PROJECT 1
set -x PROMPT_SHOW_ERR_STATUS 1
set -x GIT_WORKTREE_PREFIX ".git/.wkit-worktrees/"

## claude-code
set -x PATH $HOME/.claude/local $PATH

## vim
alias vi nvim
alias vim nvim
set -x EDITOR nvim

## alternative grep
alias rg "rg --hidden --glob '!.git/*' --glob '!node_modules/*' --glob '!vendor/*' -i"

## fzf
set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --glob "!.git/*" -i'
# tmuxを使うバージョン
set -x FZF_DEFAULT_OPTS '--height 80% --tmux --reverse --border --layout=reverse --inline-info'
# tmuxを使わないバージョン(ghosttyネイティブにした)
# set -x FZF_DEFAULT_OPTS '--height 80% --reverse --border --layout=reverse --inline-info'

## takashabe/fish-fzf
set -x FZF_CD_IGNORE_CASE '.git|vendor/|node_modules'
set -x FZF_CD_MAX_DEPTH 5

# postgres
set -x PATH /opt/homebrew/opt/libpq/bin $PATH

# git, github
# alias git 'hub'
alias g 'git'
alias gst 'git status'
alias gb 'git branch'
alias gc 'git commit -v'
alias gpush 'git push origin HEAD'

function gpull
  git pull origin (git branch --show-current)
end

# ルート/ワークツリー双方で、リモート削除済みかつマージ済みのブランチ/ワークツリーを掃除する
function gfetchprune
  set -l dry_run 0
  for arg in $argv
    switch $arg
      case --dry-run -n
        set dry_run 1
      case '*'
        echo "Usage: gfetchprune [--dry-run|-n]"
        return 1
    end
  end

  set -l repo_root (git rev-parse --show-toplevel 2>/dev/null)
  or begin
    echo "not a git repository"
    return 1
  end

  git fetch origin --prune
  # PROTECT_BRANCHES defined in local.fish
  set -l protect_re $PROTECT_BRANCHES

  set -l default_branch (git symbolic-ref --quiet --short refs/remotes/origin/HEAD | string replace 'origin/' '')
  if test -z "$default_branch"
    if git show-ref --verify --quiet refs/heads/main
      set default_branch main
    else if git show-ref --verify --quiet refs/heads/master
      set default_branch master
    end
  end

  if test -z "$default_branch"
    echo "default branch not found (origin/HEAD, main, master)"
    return 1
  end

  set -l merge_target "refs/remotes/origin/$default_branch"
  if not git show-ref --verify --quiet $merge_target
    set merge_target "refs/heads/$default_branch"
  end

  if not git show-ref --verify --quiet $merge_target
    echo "merge target not found: $merge_target"
    return 1
  end

  set -l current_wt (git rev-parse --show-toplevel)
  set -l worktree_entries
  set -l wt_path ""
  set -l wt_branch ""
  for line in (git worktree list --porcelain)
    if string match -q 'worktree *' -- $line
      if test -n "$wt_path"
        set -a worktree_entries "$wt_path\t$wt_branch"
      end
      set wt_path (string replace 'worktree ' '' -- $line)
      set wt_branch ""
    else if string match -q 'branch refs/heads/*' -- $line
      set wt_branch (string replace 'branch refs/heads/' '' -- $line)
    else if string match -q 'branch (null)' -- $line
      set wt_branch ""
    end
  end
  if test -n "$wt_path"
    set -a worktree_entries "$wt_path\t$wt_branch"
  end

  set -l targets_branches
  set -l targets_worktrees

  for entry in $worktree_entries
    set -l parts (string split -m1 "\t" -- $entry)
    set -l path $parts[1]
    set -l branch $parts[2]

    if test -z "$branch"
      continue
    end
    if test "$path" = "$current_wt"
      continue
    end
    if test "$branch" = "$default_branch"
      continue
    end
    string match -qr "^($protect_re)\$" -- $branch; and continue

    set -l upstream (git for-each-ref --format='%(upstream:short)' refs/heads/$branch)
    if test -z "$upstream"
      continue
    end

    set -l track (git for-each-ref --format='%(upstream:trackshort)' refs/heads/$branch)
    string match -q '*gone*' -- $track; or continue

    git merge-base --is-ancestor $branch $merge_target; or continue

    set -a targets_worktrees $path
    set -a targets_branches $branch
  end

  # worktree未使用のブランチも削除対象にする
  for entry in (git for-each-ref --format='%(refname:short)' refs/heads)
    set -l branch $entry
    if test "$branch" = "$default_branch"
      continue
    end
    string match -qr "^($protect_re)\$" -- $branch; and continue

    # worktree使用中は除外
    for wt_entry in $worktree_entries
      set -l wt_parts (string split -m1 "\t" -- $wt_entry)
      if test "$branch" = "$wt_parts[2]"
        set branch ""
        break
      end
    end
    if test -z "$branch"
      continue
    end

    set -l upstream (git for-each-ref --format='%(upstream:short)' refs/heads/$branch)
    if test -z "$upstream"
      continue
    end
    set -l track (git for-each-ref --format='%(upstream:trackshort)' refs/heads/$branch)
    string match -q '*gone*' -- $track; or continue
    git merge-base --is-ancestor $branch $merge_target; or continue

    set -a targets_branches $branch
  end

  if test (count $targets_worktrees) -eq 0; and test (count $targets_branches) -eq 0
    echo "already updated"
    return
  end

  for path in $targets_worktrees
    if test $dry_run -eq 1
      echo "[dry-run] git worktree remove -f -- $path"
    else
      git worktree remove -f -- $path
    end
  end

  for branch in $targets_branches
    if test $dry_run -eq 1
      echo "[dry-run] git branch -d -- $branch"
    else
      git branch -d -- $branch
    end
  end
end

# ブランチ一覧をfzfで選択してチェックアウトする
function gbp
  git branch -a --sort=-authordate | cut -b 3- | perl -pe 's#^remotes/origin/###' | perl -nlE 'say if !$c{$_}++' | grep -v -- "->" | fzf | xargs git checkout
end

# GitHubのPRからブランチをfzfで選択してチェックアウトする
function ghp
  fzf_gh_pr_checkout
end

# git worktree listをfzfで選択してcdする
function gwl
  fzf_git_wt
end

# git worktreeとブランチを同時に作成する
function gwa
  if test (count $argv) -eq 0
    echo "Usage: gwa <branch-name>"
    return 1
  end

  wkit add $argv[1]
  cd (command wkit switch $argv[1])
  commandline -f repaint
end

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
if status --is-interactive; and command -v nodebrew > /dev/null
  set -x PATH $HOME/.nodebrew/current/bin $PATH
end
if status --is-interactive; and command -v volta > /dev/null
  set -x VOLTA_HOME $HOME/.volta
  set -x PATH $VOLTA_HOME/bin $PATH
end

set -x NUXT_TELEMETRY_DISABLED 1

# java
set -x PATH /opt/homebrew/opt/openjdk/bin $PATH

# rbenv
if status --is-interactive; and command -v rbenv > /dev/null
  rbenv init - | source
end

# z
set -x Z_DATA $HOME/.z

function reload_tmux
  tmux source-file ~/.tmux.conf
  echo "reload tmux"
end

# aquaproj/aqua
# https://github.com/aquaproj/aqua
set -x AQUA_GLOBAL_CONFIG "$XDG_CONFIG_HOME/aqua/aqua.yaml"
set -x PATH "$XDG_DATA_HOME/aquaproj-aqua/bin" $PATH

# bat (https://github.com/sharkdp/bat)
set -x BAT_THEME "TwoDark"

### gcloud
set -x GOOGLE_APPLICATION_CREDENTIALS "$HOME/.config/gcloud/application_default_credentials.json"
if status --is-interactive
  if test (uname) = "Linux"
    source "/opt/google-cloud-cli/path.fish.inc"
  else
    source "$(brew --prefix)/share/google-cloud-sdk/path.fish.inc"
  end
end

## switch gcloud project
function switch_gcloud
  fzf_gcloud_configurations
end

### docker, k8s
# alias docker 'nerdctl'
alias dk 'docker'
alias dkc 'docker compose'
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
function docker_restart
  docker stop (docker ps -a -q)
  docker rm (docker ps -a -q)
  docker compose up -d
end

# Go
set -x GOPATH $HOME/dev
set -x PATH $GOPATH/bin $GOROOT/bin $PATH
set -x GO111MODULE on
set -x GOTEST_CMD gotest
# set -x GOROOT $GOPATH/src/go.googlesource.com/go
### Install golang tool binaries
function go_install_binaries
  set -l GO_BINARIES \
    'go.uber.org/mock/mockgen@latest' \
    'golang.org/x/tools/cmd/goimports@latest' \
    'mvdan.cc/gofumpt@latest' \
    'golang.org/x/tools/gopls@latest' \
    'github.com/google/pprof@latest' \
    'github.com/cweill/gotests/gotests@latest' \
    'github.com/haya14busa/gtrans@latest'  \
    'github.com/rakyll/gotest@latest' \
    'github.com/fatih/gomodifytags@latest' \
    'github.com/rubenv/sql-migrate/sql-migrate@latest' \
    'github.com/swaggo/swag/cmd/swag@master' \
    'github.com/skanehira/swagger-preview/cmd/spr@latest' \
    'github.com/golangci/golangci-lint/cmd/golangci-lint@latest' \
    'github.com/nametake/golangci-lint-langserver@latest' \
    'github.com/josharian/impl@latest' \
    'github.com/air-verse/air@latest' \
    'google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest' \
    'google.golang.org/protobuf/cmd/protoc-gen-go@latest' \
    'github.com/GoogleCloudPlatform/protoc-gen-bq-schema@latest' \
    'github.com/pwaller/goimports-update-ignore@latest' \
    'github.com/onsi/ginkgo/v2/ginkgo@latest' \
    'github.com/kisielk/godepgraph@latest' \
    'mvdan.cc/gofumpt@latest' \
    'github.com/d-kuro/gwq/cmd/gwq@latest'
  pushd $HOME
  for uri in $GO_BINARIES
    echo "go install $uri ..."
    go install $uri
  end
  popd
end

# Rust
set -x PATH $HOME/.cargo/bin $PATH
if status --is-interactive; and test -r "$HOME/.cargo/env.fish"
  source "$HOME/.cargo/env.fish"
end

# Python
set -x CLOUDSDK_PYTHON_SITEPACKAGES 1

### fish history
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
  bind \ck kill-line
end

# direnv
direnv hook fish | source

#### general function
function reload_config
  source $HOME/.config/fish/config.fish
end
function edit_config
  $EDITOR ~/dotfiles/.config/fish/config.fish
end

function reload_network
  sudo ifconfig en0 down
  sudo ifconfig en0 up
end

function randomize_mac_address
  # for macos
  sudo spoof-mac randomize en0
end

function reload_keyboard
  systemctl --user restart xkeysnail
  systemctl --user restart imwheel
end

function get_global_ip
  curl -s https://httpbin.org/ip
end

## osx system functions
function msleep
  osascript -e 'tell application "Finder" to sleep'
end

function rolling_update
  paru -Syyu --noconfirm && go_install_binaries
end

## Terraform
alias tf 'terraform'

## haya14busa/gtrans
# set -x GOOGLE_TRANSLATE_API_KEY "set local"
set -x GOOGLE_TRANSLATE_LANG ja
set -x GOOGLE_TRANSLATE_SECONDLANG en

## terraform
set -x TF_CLI_ARGS_plan "--parallelism=254"
set -x TF_CLI_ARGS_apply "--parallelism=254"

## Login message
# emtpy
set fish_greeting

# Load local env, functions and so on.
if status --is-interactive; and test -r $HOME/.config/fish/conf.d/local.fish
  source $HOME/.config/fish/conf.d/local.fish
end

# tab completion very slow...  may be fix next-release. (3.1.3?)
# https://github.com/fish-shell/fish-shell/issues/7511
if status --is-interactive; and test (uname) = "Darwin"
  function __fish_describe_command; end
end

# mysql-client via homebrew
if status --is-interactive; and test (uname) = "Darwin"
  fish_add_path /opt/homebrew/opt/mysql-client@5.7/bin
  eval $(/opt/homebrew/bin/brew shellenv)
end

# コマンド実行時間が一定時間を超えていればnotificationを表示
function __postexec_notify_on_long_running_commands --on-event fish_postexec
  # インタラクティブなコマンドは通知しない
  set --function interactive_commands vi vim nvim man less zed pgcli psql tig lg lazygit ld lazydocker
  set --function command (string split ' ' $argv[1])
  if contains $command $interactive_commands
    return
  end

  # 通知するコマンドの実行時間が閾値を超えた場合に通知を行う (milliseconds)
  set -l threshold_duration 10000
  set -l display_cmd_length 20
  if test $CMD_DURATION -gt $threshold_duration
    # 実行コマンドの先頭30文字を通知する
    set -l full_command (string join ' ' $argv)
    set -l display_command (string sub -s 1 -l $display_cmd_length $full_command)
    if test (string length $full_command) -gt $display_cmd_length
      set display_command (string join '' $display_command '...')
    end
    set -l duration_in_seconds (math "floor($CMD_DURATION / 1000)")
    set -l notification_message "'$display_command' finished. took $duration_in_seconds s"
    osascript -e "display notification \"$notification_message\" with title \"Command Notification\""
  end
end

if test -r ~/.safe-chain/scripts/init-fish.fish; and command -v safe-chain > /dev/null
  source ~/.safe-chain/scripts/init-fish.fish # Safe-chain Fish initialization script
end

if status --is-interactive; and command -v starship > /dev/null
  starship init fish | source
end

if status --is-interactive; and command -q git; and git wt -h &>/dev/null
  git wt --init fish | source
end
