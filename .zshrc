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

# vim
export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
alias vi='env LANG=en-US.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env LANG=en_US.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'

# tmux
alias tmux='tmuxx'
alias tm='tmuxx'

# android
export PATH=/Applications/android-sdk/tools:/Applications/android-sdk/platform-tools:$PATH
export ANDROID_HOME=/Applications/android-sdk/

# tmux自動起動
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
