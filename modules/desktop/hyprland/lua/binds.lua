local function run(command)
  return hl.dsp.exec_cmd(command)
end

local function focus(direction)
  return hl.dsp.focus({ direction = direction })
end

local function move(direction)
  return hl.dsp.window.move({ direction = direction })
end

local function workspace(id, follow)
  return hl.dsp.window.move({ workspace = id, follow = follow })
end

local function bindWorkspace(key, id)
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = id }))
  hl.bind(mainMod .. " + SHIFT + " .. key, workspace(id, true))
  hl.bind(mainMod .. " + CTRL + " .. key, workspace(id, false))
end

for _, binding in ipairs({
  { "right", 30, 0 }, { "left", -30, 0 },
  { "up", 0, -30 }, { "down", 0, 30 },
  { "l", 30, 0 }, { "h", -30, 0 },
  { "k", 0, -30 }, { "j", 0, 30 },
}) do
  hl.bind(mainMod .. " + SHIFT + " .. binding[1],
    hl.dsp.window.resize({ x = binding[2], y = binding[3] }), { repeating = true })
end

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

for _, binding in ipairs({
  { "XF86AudioLowerVolume", "pamixer -d 1" },
  { "XF86AudioRaiseVolume", "pamixer -i 1" },
}) do
  hl.bind(binding[1], run(binding[2]), { repeating = true })
end

if isCaelestia then
  hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { repeating = true })
  hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { repeating = true })
  hl.bind(mainMod .. " + ALT + L", hl.dsp.global("caelestia:lock"))
  hl.bind(mainMod .. " + backspace", hl.dsp.global("caelestia:session"))
  hl.bind(mainMod .. " + A", hl.dsp.global("caelestia:launcher"))
  hl.bind(mainMod .. " + SPACE", hl.dsp.global("caelestia:showall"))
  hl.bind(mainMod .. " + SHIFT + I", hl.dsp.global("caelestia:nexus"))
  hl.bind(mainMod .. " + SHIFT + D", hl.dsp.global("caelestia:dashboard"))
  hl.bind(mainMod .. " + SHIFT + U", hl.dsp.global("caelestia:utilities"))
  hl.bind(mainMod .. " + SHIFT + N", hl.dsp.global("caelestia:sidebar"))
  hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.global("caelestia:clearNotifs"))
  hl.bind(mainMod .. " + Z", run("pkill -x fuzzel || " .. caelestia .. " emoji -p"))
  hl.bind(mainMod .. " + V", run("pkill -x fuzzel || " .. caelestia .. " clipboard"))
  hl.bind(mainMod .. " + SHIFT + R", run(caelestia .. " record -r -s"))
  hl.bind(mainMod .. " + CTRL + R", run(caelestia .. " record -s"))
  hl.bind(mainMod .. " + P", run(caelestia .. " screenshot -r"))
  hl.bind(mainMod .. " + CTRL + P", run(caelestia .. " screenshot -r -f"))
  hl.bind(mainMod .. " + print", run(caelestia .. " screenshot"))
  hl.bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"))
  hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"))
  hl.bind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"))
  hl.bind("xf86AudioNext", hl.dsp.global("caelestia:mediaNext"))
  hl.bind("xf86AudioPrev", hl.dsp.global("caelestia:mediaPrev"))
else
  hl.bind("XF86MonBrightnessDown", run("brightnessctl set 1%-"), { repeating = true })
  hl.bind("XF86MonBrightnessUp", run("brightnessctl set +1%"), { repeating = true })
  hl.bind(mainMod .. " + ALT + L", run("hyprlock"))
  hl.bind(mainMod .. " + backspace", run("pkill -x wlogout || uwsm app -- wlogout -b 4"))
  hl.bind(mainMod .. " + A", run(launcher .. " drun"))
  hl.bind(mainMod .. " + SPACE", run(launcher .. " drun"))
  hl.bind(mainMod .. " + SHIFT + W", run(launcher .. " wallpaper"))
  hl.bind(mainMod .. " + Z", run(launcher .. " emoji"))
  hl.bind(mainMod .. " + SHIFT + N", run("swaync-client -t -sw"))
  hl.bind(mainMod .. " + SHIFT + Q", run("swaync-client -t -sw"))
  hl.bind(mainMod .. " + V", run(clipmanager))
  hl.bind(mainMod .. " + SHIFT + R", run(screen_record .. " a"))
  hl.bind(mainMod .. " + CTRL + R", run(screen_record .. " m"))
  hl.bind(mainMod .. " + P", run(screenshot .. " s"))
  hl.bind(mainMod .. " + CTRL + P", run(screenshot .. " sf"))
  hl.bind(mainMod .. " + print", run(screenshot .. " p"))
  for _, binding in ipairs({
    { "XF86AudioPlay", "playerctl play-pause" },
    { "XF86AudioPause", "playerctl play-pause" },
    { "XF86AudioStop", "playerctl stop" },
    { "xf86AudioNext", "playerctl next" },
    { "xf86AudioPrev", "playerctl previous" },
  }) do
    hl.bind(binding[1], run(binding[2]))
  end
end

hl.bind(mainMod .. " + question", run(keybinds_yad))
hl.bind(mainMod .. " + slash", run(keybinds_yad))
hl.bind(mainMod .. " + CTRL + K", run(keybinds_yad))
hl.bind(mainMod .. " + F9", run(night_mode))
hl.bind(mainMod .. " + F10", run("pkill hyprsunset"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.kill())
hl.bind(mainMod .. " + delete", run("uwsm stop"))
hl.bind(mainMod .. " + W", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.toggle())
hl.bind("ALT + return", hl.dsp.window.fullscreen())
hl.bind("CONTROL + ESCAPE", run(bar_toggle))

hl.bind(mainMod .. " + Return", run(term))
hl.bind(mainMod .. " + T", run(term))
hl.bind(mainMod .. " + E", run(file_manager_script .. " " .. file_manager))
hl.bind(mainMod .. " + C", run(editor))
hl.bind(mainMod .. " + F", run(browser))
hl.bind(mainMod .. " + SHIFT + Y", run(pear))
hl.bind("CONTROL + ALT + DELETE", run(term .. " -e '" .. btop .. "'"))
hl.bind(mainMod .. " + CTRL + C", run("hyprpicker --autocopy --format=hex"))
hl.bind(mainMod .. " + SHIFT + T", run(tmux))
hl.bind(mainMod .. " + G", run(games))
hl.bind(mainMod .. " + ALT + K", run(keyboardswitch))
hl.bind(mainMod .. " + ALT + G", run(gamemode))
hl.bind(mainMod .. " + SHIFT + M", run(music))
hl.bind(mainMod .. " + CTRL + print", run(screenshot .. " m"))
hl.bind("xf86Sleep", run("systemctl suspend"))
hl.bind("XF86AudioMicMute", run("pamixer --default-source -t"))
hl.bind(mainMod .. " + M", run("pamixer --default-source -t"))
hl.bind("XF86AudioMute", run("pamixer -t"))

hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + Tab", hl.dsp.window.bring_to_top())
hl.bind(mainMod .. " + X", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.focus({ workspace = "empty" }))

for _, binding in ipairs({
  { "left", "l" }, { "right", "r" }, { "up", "u" }, { "down", "d" },
  { "h", "l" }, { "l", "r" }, { "k", "u" }, { "j", "d" },
}) do
  hl.bind(mainMod .. " + " .. binding[1], focus(binding[2]))
end
hl.bind("ALT + Tab", focus("d"))

hl.bind(mainMod .. " + mouse:276", hl.dsp.focus({ workspace = "5" }))
hl.bind(mainMod .. " + mouse:275", hl.dsp.focus({ workspace = "6" }))
hl.bind(mainMod .. " + SHIFT + mouse:276", workspace("5", true))
hl.bind(mainMod .. " + SHIFT + mouse:275", workspace("6", true))
hl.bind(mainMod .. " + CTRL + mouse:276", workspace("5", false))
hl.bind(mainMod .. " + CTRL + mouse:275", workspace("6", false))
hl.bind(mainMod .. " + U", run(term .. " -e rebuild"))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + ALT + right", workspace("r+1", true))
hl.bind(mainMod .. " + CTRL + ALT + left", workspace("r-1", true))

for _, binding in ipairs({
  { "left", "l" }, { "right", "r" }, { "up", "u" }, { "down", "d" },
  { "H", "l" }, { "L", "r" }, { "K", "u" }, { "J", "d" },
}) do
  hl.bind(mainMod .. " + SHIFT + CTRL + " .. binding[1], move(binding[2]))
end

hl.bind(mainMod .. " + CTRL + mouse_down", run(zoom .. " in"))
hl.bind(mainMod .. " + CTRL + mouse_up", run(zoom .. " out"))
hl.bind(mainMod .. " + CTRL + S", workspace("special", false))
hl.bind(mainMod .. " + ALT + S", workspace("special", false))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("special"))

hl.bind("F9", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))
hl.bind("F10", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))

for i = 1, 10 do
  local key = i % 10
  bindWorkspace(key, i)
end
for i = 11, 20 do
  local key = i % 10
  hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + ALT + " .. key, workspace(i, true))
  hl.bind(mainMod .. " + CTRL + ALT + " .. key, workspace(i, false))
end
