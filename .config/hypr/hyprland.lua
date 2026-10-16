-- Hyprland 設定 (Lua)。0.55 以降 hyprlang (.conf) は非推奨
-- https://wiki.hypr.land/Configuring/Start/

require("monitors")
require("workspaces")
require("window")
require("shell")

local terminal    = "ghostty"
local fileManager = "nautilus"

-- 自動起動。デスクトップシェルの起動は shell.lua 側で行う
-- 0.56 の Hyprland は graphical-session.target を起動しないため、niri.service と同じように
-- hyprland-session.target 経由で起動し、xremap など WantedBy=graphical-session.target のユニットを動かす
-- https://wiki.hypr.land/Useful-Utilities/Systemd-start/#hyprland-sessiontarget
hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user start hyprland-session.target")
  hl.exec_cmd("systemctl --user start pipewire pipewire-pulse wireplumber")
  hl.exec_cmd("fcitx5 -d --replace")
  hl.exec_cmd("1password --silent")
end)

hl.on("hyprland.shutdown", function()
  os.execute("systemctl --user stop graphical-session.target")
end)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- 見た目 https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  general = {
    gaps_in     = 5,
    gaps_out    = 20,
    border_size = 2,
    col = {
      active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = false,
    allow_tearing    = false,
    layout           = "scrolling",
  },

  -- niri 風のスクロールレイアウト https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
  -- 列幅プリセットは niri の preset-column-widths に合わせる
  scrolling = {
    column_width             = 0.98, -- niri の default-column-width と同じ。新しい列はほぼ全幅で開き、既存の列は横へ押し出される
    explicit_column_widths   = "0.3, 0.5, 0.98, 1.0",
    fullscreen_on_one_column = true,
  },

  decoration = {
    rounding         = 10,
    rounding_power   = 2,
    active_opacity   = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled      = true,
      range        = 4,
      render_power = 3,
      color        = 0xee1a1a1a,
    },
    blur = {
      enabled  = true,
      size     = 3,
      passes   = 1,
      vibrancy = 0.1696,
    },
  },

  animations = { enabled = true },

  -- 縦モニタを上下分割に戻すときのための dwindle 設定
  dwindle = {
    preserve_split = true,
  },

  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo   = false,
  },

  input = {
    repeat_delay = 140,
    repeat_rate  = 50,
    kb_layout    = "us",
    follow_mouse = 1,
    sensitivity  = 0,
    touchpad = {
      natural_scroll = false,
    },
  },
})

-- アニメーション https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1} } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- キーバインド https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Q",      hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + SHIFT + Q", hl.dsp.exit()) -- niri と同じ組み合わせにして誤爆を防ぐ
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.layout("colresize 1.0"))   -- niri の maximize-column
hl.bind(mainMod .. " + CTRL + F",  hl.dsp.window.fullscreen())

-- フォーカス移動 (vim 風)。左右はモニタ境界をまたぐ
hl.bind("ALT + h", hl.dsp.focus({ direction = "left" }))
hl.bind("ALT + l", hl.dsp.focus({ direction = "right" }))
hl.bind("ALT + k", hl.dsp.focus({ direction = "up" }))
hl.bind("ALT + j", hl.dsp.focus({ direction = "down" }))

-- 列の入れ替えと、列内でのウィンドウ移動
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- 列幅とウィンドウ高さの増減
hl.bind(mainMod .. " + CTRL + H", hl.dsp.layout("colresize -0.1"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.layout("colresize +0.1"))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = 0, y = 50,  relative = true }))

-- 列幅をプリセットで切り替える (niri の switch-preset-column-width)
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.layout("colresize +conf"))

-- 隣の列にウィンドウを統合する / 列から分離する (niri の consume-or-expel-window)
hl.bind(mainMod .. " + comma",  hl.dsp.layout("consume_or_expel prev"))
hl.bind(mainMod .. " + period", hl.dsp.layout("consume_or_expel next"))

-- ワークスペース切替と移動
for i = 1, 4 do
  hl.bind(mainMod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- マウスドラッグで移動とリサイズ
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- メディアキー
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
