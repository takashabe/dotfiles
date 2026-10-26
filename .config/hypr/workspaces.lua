-- ワークスペースは niri と同じく各モニタ 2 つ。どれも scrolling レイアウトを使う
-- 横モニタ (DP-2) は右方向に、縦モニタ (HDMI-A-1) は下方向にスクロールする
hl.workspace_rule({ workspace = "1", monitor = "DP-2",     default = true, layout = "scrolling" })
hl.workspace_rule({ workspace = "2", monitor = "DP-2",                     layout = "scrolling" })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1", default = true, layout = "scrolling", layout_opts = { direction = "down" } })
hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1",                 layout = "scrolling", layout_opts = { direction = "down" } })

-- 縦モニタでは新しい行を高さ半分で開き、上下に 2 つ並べる
local PORTRAIT_ROW_HEIGHT = 0.5
for _, ws in ipairs({ 3, 4 }) do
  hl.window_rule({ match = { workspace = ws }, scrolling_width = PORTRAIT_ROW_HEIGHT })
end

local function is_portrait(mon)
  return mon.transform % 2 == 1
end

-- focus_fit_method はモニタ単位で指定できないため、フォーカスのあるモニタに合わせて切り替える。
-- 縦モニタで center にすると、高さ半分の行が中央に来て上下の行が半端に切れる。fit なら 2 行がちょうど収まる
local function apply_focus_fit(mon)
  if not mon then return end
  hl.config({ scrolling = { focus_fit_method = is_portrait(mon) and 1 or 0 } })
end
hl.on("monitor.focused", apply_focus_fit)
hl.on("config.reloaded", function() apply_focus_fit(hl.get_active_monitor()) end)

-- 縦モニタでは 1 行 1 窓に戻す。列の構成は Lua から読めないので、各窓で expel を窓の数だけ試す。
-- expel は列末尾の窓を現在の列の直後へ出すため、元の並び順は保たれる
local function split_rows(ws)
  local tiled = {}
  for _, w in ipairs(hl.get_workspace_windows(ws)) do
    if not w.floating then table.insert(tiled, w) end
  end
  for _, w in ipairs(tiled) do
    hl.dispatch(hl.dsp.focus({ window = w }))
    for _ = 2, #tiled do
      hl.dispatch(hl.dsp.layout("expel"))
    end
  end
end

-- reload では既存の列幅が戻らないため、表示中のワークスペースの列幅を既定値に揃え直す。
-- colresize all はフォーカス中のワークスペースにしか効かないので、モニタを順にフォーカスして回る
function tiling_restart()
  local active_mon = hl.get_active_monitor()
  local active_win = hl.get_active_window()
  for _, mon in ipairs(hl.get_monitors()) do
    local width = is_portrait(mon) and PORTRAIT_ROW_HEIGHT or hl.get_config("scrolling.column_width")
    hl.dispatch(hl.dsp.focus({ monitor = mon.name }))
    if is_portrait(mon) and mon.active_workspace then
      split_rows(mon.active_workspace)
    end
    hl.dispatch(hl.dsp.layout("colresize all " .. width))
  end
  if active_win then
    hl.dispatch(hl.dsp.focus({ window = active_win }))
  elseif active_mon then
    hl.dispatch(hl.dsp.focus({ monitor = active_mon.name }))
  end
end

return { is_portrait = is_portrait }
