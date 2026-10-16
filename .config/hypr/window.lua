-- アプリごとに開くワークスペースを固定する
local function open_on(workspace, class)
  hl.window_rule({ match = { class = class }, workspace = workspace .. " silent" })
end

-- 1: terminal
open_on(1, "^(Alacritty|Ghostty|com\\.mitchellh\\.ghostty)$")
-- 2: browsing
open_on(2, "^(firefox|Firefox|zen|Zen|Zen-beta|Brave-browser|Google-chrome|Chromium|vivaldi-stable|Vivaldi)$")
-- 3: notes / productivity
open_on(3, "^(obsidian)$")
-- 4: communication
open_on(4, "^(Slack|discord|Discord|gather|gather.town|LINE)$")
-- 5: IDE
open_on(5, "^(Code|code-oss|Code - OSS|VSCodium|Zed|zed|cursor|Cursor|kiro)$")
-- 6: development tools
open_on(6, "^(TablePlus|tableplus|Postman)$")
-- 7: development tools #2
open_on(7, "^(DevToys|devtoys)$")
-- 9: background
open_on(9, "^(Spotify)$")

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
