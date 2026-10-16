-- DankMaterialShell をデスクトップシェルとして使う
-- https://danklinux.com/docs/dankmaterialshell/compositors
hl.on("hyprland.start", function()
  hl.exec_cmd("dms run")
end)

hl.bind("SUPER + D", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))

-- DMS のレイヤーにはアニメーションを付けない
hl.layer_rule({ match = { namespace = "dms" }, no_anim = true })

-- DMS の設定ウィンドウ等をフローティングにする
hl.window_rule({ match = { class = "^(com\\.danklinux\\.dms)$" }, float = true })
