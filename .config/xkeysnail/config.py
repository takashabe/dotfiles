# -*- coding: utf-8 -*-

import re
from xkeysnail.transform import *

# macOS(Emacs)-like keybindings in non-Emacs applications
define_keymap(lambda wm_class: wm_class not in ("Alacritty", "Code"), {
  # Cursor
  K("C-b"): K("left"),
  K("C-f"): K("right"),
  K("C-p"): K("up"),
  K("C-n"): K("down"),
  K("C-h"): K("backspace"),
  # Beginning/End of line
  K("C-a"): K("home"),
  K("C-e"): K("end"),
  # Kill line
  K("C-k"): [K("Shift-end"), K("C-x"), set_mark(False)],

  K("Super-x"): [K("C-x"), set_mark(False)],
  K("Super-c"): [K("C-c"), set_mark(False)],
  K("Super-v"): [K("C-v"), set_mark(False)],
  K("Super-z"): [K("C-z"), set_mark(False)],
  K("Super-f"): K("C-f"),
  K("Super-t"): K("C-t"),
  K("Super-r"): K("C-r"),
  K("Super-w"): K("C-w"),
}, "macOS-like keys")

# ESC + IME off for vim
define_keymap(lambda wm_class: wm_class in ("Alacritty", "Code"), {
  # MUHENKAN=HANJA
  K("ESC"): [K("ESC"), K("HANJA"), set_mark(False)],
}, "vim")
