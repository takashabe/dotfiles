-- ワークスペースは niri と同じく各モニタ 2 つ。どれも scrolling レイアウトを使う
-- 横モニタ (DP-2) は右方向に、縦モニタ (HDMI-A-1) は下方向にスクロールする
hl.workspace_rule({ workspace = "1", monitor = "DP-2",     default = true, layout = "scrolling" })
hl.workspace_rule({ workspace = "2", monitor = "DP-2",                     layout = "scrolling" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1", default = true, layout = "scrolling", layout_opts = { direction = "down" } })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1",                 layout = "scrolling", layout_opts = { direction = "down" } })
