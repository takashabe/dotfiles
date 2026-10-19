-- niri と同じく、コミュニケーション系と Obsidian は縦モニタの 3 番で開く
-- 別ワークスペースへ送るウィンドウには workspaces.lua の行高さルールが効かないため、ここでも高さ半分を指定する
local function open_on(workspace, class)
  hl.window_rule({ match = { class = class }, workspace = workspace .. " silent", scrolling_width = 0.5 })
end

open_on(3, "^Slack$")
open_on(3, "^obsidian$")
open_on(3, "^todoist$")
open_on(3, "^chrome-odhdeommofkpfnffhlpjhbeiedldfelj-Default$") -- Gather (Chrome PWA)

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
