#!/usr/bin/env ruby

define :activate do |wm_class, command|
  execute("wmctrl -x -a #{wm_class.shellescape} || #{command.shellescape}")
end

window class_not: %w[slack Mozilla-Firefox google-chrome gnome-terminal-server urxvt Alacritty Focus-Proxy-Window] do
  # emacs-like bindings
  remap 'C-b', to: 'Left'
  remap 'C-f', to: 'Right'
  remap 'C-p', to: 'Up'
  remap 'C-n', to: 'Down'

  remap 'M-b', to: 'Ctrl-Left'
  remap 'M-f', to: 'Ctrl-Right'

  remap 'C-a', to: 'Alt-C-a'
  remap 'C-e', to: 'Alt-C-e'

  remap 'C-k', to: 'Alt-C-k'

  remap 'C-d', to: 'Delete'
  remap 'M-d', to: 'Ctrl-Delete'

  %w[a z x c w t l].each do |key|
    remap "Alt-#{key}", to: "C-#{key}"
  end
end

window class_only: %w[Mozilla-Firefox google-chrome slack] do
  remap 'C-b', to: 'Left'
  remap 'C-f', to: 'Right'
  remap 'C-p', to: 'Up'
  remap 'C-n', to: 'Down'

  remap 'M-b', to: 'Ctrl-Left'
  remap 'M-f', to: 'Ctrl-Right'

  remap 'C-a', to: 'Home'
  remap 'C-e', to: 'End'
  remap 'C-k', to: ['Shift-End', 'Delete']

  remap 'C-d', to: 'Delete'
  remap 'M-d', to: 'Ctrl-Delete'

  # actually these are vim insert mode bindings, but compatible with shell
  remap 'Super-w', to: 'C-w'

  %w[a z x c v w t l].each do |key|
    remap "Alt-#{key}", to: "C-#{key}"
  end
  remap 'Alt-o', to: 'Ctrl-Shift-Tab'
  remap 'Alt-p', to: 'Ctrl-Tab'
end
