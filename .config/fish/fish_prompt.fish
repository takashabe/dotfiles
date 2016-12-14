function _git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function _is_git_dirty
  set -l show_untracked (git config --bool bash.showUntrackedFiles)
  set untracked ''
  if [ "$theme_display_git_untracked" = 'no' -o "$show_untracked" = 'false' ]
    set untracked '--untracked-files=no'
  end
  echo (command git status -s --ignore-submodules=dirty $untracked ^/dev/null)
end

function _is_macos
  if uname -a | grep 'Darwin' > /dev/null ^ /dev/null
    return 0
  else
    return 1
  end
end

function fish_prompt
  set -l last_status $status
  # base colors: soralized (http://ethanschoonover.com/solarized)
  set -l cyan (set_color -o 2aa198)
  set -l yellow (set_color -o b58900)
  set -l red (set_color -o dc322f)
  set -l blue (set_color -o 268bd2)
  set -l green (set_color -o 2aa198)
  set -l normal (set_color normal)

  if test $last_status = 0
      set arrow "\U1F41F "
  else
      set arrow "\U1F4A3 "
  end
  # set -l cwd $cyan(basename (prompt_pwd))
  set -l cwd $cyan(prompt_pwd)

  if [ (_git_branch_name) ]
    set -l git_branch (_git_branch_name)
    set git_info "$blue$git_branch"

    if [ (_is_git_dirty) ]
      set -l dirty "$red*"
      set git_info "- $git_info$dirty"
    end
  end

  if _is_macos
    printf "$arrow $cwd $git_info $normal"
  else
    echo -n -s -e $arrow ' ' $cwd $git_info $normal ' '
  end
end
