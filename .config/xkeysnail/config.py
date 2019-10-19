# -*- coding: utf-8 -*-

import re
from xkeysnail.transform import *

# Keybindings for Firefox/Chrome
define_keymap(lambda wm_class: wm_class in ("firefox", "google-chrome"), {
  K("Super-w"): K("C-w"),
  K("Super-l"): K("C-l"),
}, "Firefox and Chrome")

# macOS(Emacs)-like keybindings in non-Emacs applications
define_keymap(lambda wm_class: wm_class not in ("Emacs", "URxvt", "Alacritty"), {
  # Cursor
  K("C-b"): with_mark(K("left")),
  K("C-f"): with_mark(K("right")),
  K("C-p"): with_mark(K("up")),
  K("C-n"): with_mark(K("down")),
  K("C-h"): with_mark(K("backspace")),
  # Beginning/End of line
  K("C-a"): with_mark(K("home")),
  K("C-e"): with_mark(K("end")),
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
