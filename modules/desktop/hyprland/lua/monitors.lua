hl.monitor({
  output = "DP-2",
  mode = "2560x1440@144.0",
  position = "0x0",
  scale = 1,
  bitdepth = 10,
  cm = "dcip3",
  supports_hdr = -1,
})
hl.monitor({
  output = "DP-1",
  mode = "2560x1440@144.0",
  position = "2560x0",
  scale = 1,
  bitdepth = 10,
  cm = "dcip3",
  supports_hdr = -1,
})
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 20 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 20 })
hl.workspace_rule({ workspace = "special:special", gaps_out = 20 })

for workspace = 1, 5 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-2", default = workspace == 1 })
end
for workspace = 6, 10 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-1", default = workspace == 6 })
end
for workspace = 11, 15 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-2" })
end
for workspace = 16, 20 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-1" })
end
