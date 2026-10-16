-- niri と同じく、コミュニケーション系と Obsidian は縦モニタの 3 番で開く
local function open_on(workspace, class)
  hl.window_rule({ match = { class = class }, workspace = workspace .. " silent" })
end

open_on(3, "^Slack$")
open_on(3, "^vivaldi-lpiiknacbombkbjcmblabngmfnbahijj-Default$")
open_on(3, "^obsidian$")

-- ファイルマネージャと表計算はフローティングで開く
hl.window_rule({ match = { class = "^(org.gnome.Nautilus|dolphin|thunar)$" }, float = true })
hl.window_rule({ match = { class = "^(libreoffice-calc|soffice\\.bin)$" },     float = true })

-- アプリからの最大化要求を無視する
hl.window_rule({
  name  = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- XWayland のドラッグ中に出る空ウィンドウにフォーカスを渡さない
hl.window_rule({
  name  = "fix-xwayland-drags",
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  no_focus = true,
})
