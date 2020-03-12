#!/bin/bash

options=(
  -modi            "combi,system:rofi_system_menu.sh,calc:qalc,run,ssh"
  -combi-modi      "window,drun"
  -show            "combi"
  -font            "Ubuntu 28"
  -width           "100"
  -padding         "80"
  -lines           "8"
  -opacity         "80"
  -fixed-num-lines
  -hide-scrollbar
  -sidebar-mode

  ##  key bindings  ##
  -kb-cancel        "Escape,Control+g,Control+bracketleft,Control+c"
  -kb-mode-next     "Shift+Right,Control+i,Control+Tab"
  -kb-mode-previous "Shift+Left,Control+Shift+i"

  #### color scheme
  -color-enabled   "true"
  ## window         bg      border
  -color-window    "#282828, #282828"
  ## text & cursor  bg       fg       altbg    hlbg     hlfg
  -color-normal    "#282828, #ebdbb2, #282828, #ebdbb2, #282828"
  -color-active    "#282828, #ebdbb2, #282828, #ebdbb2, #282828"
  -color-urgent    "#282828, #ebdbb2, #282828, #ebdbb2, #282828"
)

rofi "$@" "${options[@]}"
