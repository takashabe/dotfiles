# -*- coding: utf-8 -*-

import re
from xkeysnail.transform import *

# macOS(Emacs)-like keybindings in non-Emacs applications
define_keymap(lambda wm_class: wm_class not in ("Alacritty", "Visual Studio Code"), {
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

  # Copy
  K("Super-x"): [K("C-x"), set_mark(False)],
  K("Super-c"): [K("C-c"), set_mark(False)],
  K("Super-v"): [K("C-v"), set_mark(False)],
  # Undo
  K("Super-z"): [K("C-z"), set_mark(False)],
  # Search
  K("Super-f"): K("C-f"),
  # Close
  K("Super-q"): K("M-F4"),
}, "macOS-like keys")
