# antigen.zsh
source ~/.zshrc.antigen

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
