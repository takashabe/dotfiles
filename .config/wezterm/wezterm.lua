local wezterm = require 'wezterm';

return {
  default_prog = { '/opt/homebrew/bin/fish', '-l' },
  font = wezterm.font("SF Mono Square"),
  use_ime = true,
  font_size = 20.0,
  color_scheme = "OneHalfDark",
  hide_tab_bar_if_only_one_tab = true,
  adjust_window_size_when_changing_font_size = false,

  disable_default_key_bindings = true,

  window_padding = {
    left = 3,
    right = 3,
    top = 3,
    bottom = 3,
  },
}
