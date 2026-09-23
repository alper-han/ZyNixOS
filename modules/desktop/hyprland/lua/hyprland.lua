require("variables")
local schemePath = (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/hypr/scheme/current.lua"
local schemeOk, schemeValues = pcall(dofile, schemePath)
caelestiaScheme = schemeOk and type(schemeValues) == "table" and schemeValues or {}
require("settings")
require("animations")
require("binds")
require("rules")
require("monitors")
