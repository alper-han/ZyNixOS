-- Fallback for any output without an explicit rule (e.g. laptop panels).
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 20 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 20 })
hl.workspace_rule({ workspace = "special:special", gaps_out = 20 })

-- Per-host outputs and workspace pins (lua/monitors/<host>.lua), if any.
require("host-monitors")
