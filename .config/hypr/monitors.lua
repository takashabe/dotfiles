-- niri の monitor.kdl (nwg-displays 生成) と同じ配置に揃える
-- HDMI-A-1 を縦置き (90度) で左に、DP-2 をその右下に置き、下端を揃える
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0",       scale = 1, transform = 1 })
hl.monitor({ output = "DP-2",     mode = "3840x2160@60", position = "2160x1680", scale = 1 })
