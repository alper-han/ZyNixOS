local function window(match, effects)
  effects.match = match
  hl.window_rule(effects)
end

window({ fullscreen = false }, { opacity = "0.95 override" })
window({ class = ".*" }, { suppress_event = "maximize" })
window({ class = "org\\.quickshell|swappy" }, { opaque = true })
window({ float = true, xwayland = false }, { center = true })

for _, class in ipairs({ "yad", "org\\.gnome\\.FileRoller", "file-roller", "peazip", "PeaZip", "blueman-manager", "org\\.quickshell" }) do
  window({ class = class }, { float = true })
end

for _, title in ipairs({ "Open File", "Select a File", "Choose wallpaper", "Open Folder", "Save As", "Library", "File Upload" }) do
  window({ title = "^(" .. title .. ")(.*)$" }, { center = true })
  window({ title = "^(" .. title .. ")(.*)$" }, { float = true })
end
window({ title = "^(Choose wallpaper)(.*)$" }, { size = { "monitor_w * 0.60", "monitor_h * 0.65" } })
window({ title = "^(.*)(wants to save)$" }, { center = true })
window({ title = "^(.*)(wants to save)$" }, { float = true })
window({ title = "^(.*)(wants to open)$" }, { center = true })
window({ title = "^(.*)(wants to open)$" }, { float = true })

window({ class = "^(thunar)$", title = "^(File Operation Progress)$" }, { float = true, center = true })
window({ class = "^(thunar)$", title = "^(File Operation Progress)$" }, { size = { 500, 100 } })
window({ class = "^(pavucontrol)$" }, { float = true, size = { "monitor_w * 0.60", "monitor_h * 0.70" }, center = true })
window({ class = "^(org\\.pulseaudio\\.pavucontrol|yad-icon-browser)$" }, { float = true, size = { "monitor_w * 0.60", "monitor_h * 0.70" }, center = true })
window({ class = "^(nm-connection-editor)$" }, { float = true, size = { "monitor_w * 0.45", "monitor_h * 0.45" }, center = true })
window({ title = ".*Welcome" }, { float = true })
window({ class = "^(Xdg-desktop-portal-gtk)$" }, { border_size = 0 })

for _, title in ipairs({
  "(Select|Open)( a)? (File|Folder)(s)?",
  "File (Operation|Upload)( Progress)?",
  ".* Properties",
  "Export Image as PNG",
  "GIMP Crash Debug",
}) do
  window({ title = title }, { float = true })
end

window({ title = "Picture(-| )in(-| )[Pp]icture" }, { move = { "monitor_w - window_w - 2%", "monitor_h - window_h - 3%" } })
window({ title = "Picture(-| )in(-| )[Pp]icture" }, { keep_aspect_ratio = true })
window({ title = "Picture(-| )in(-| )[Pp]icture" }, { float = true })
window({ title = "Picture(-| )in(-| )[Pp]icture" }, { pin = true })
window({ class = "steam" }, { rounding = 10 })
window({ title = "Friends List", class = "steam" }, { float = true })
window({ title = ".*is sharing (a window|your screen).*" }, { float = true })
window({ title = ".*is sharing (a window|your screen).*" }, { pin = true })
window({ title = ".*is sharing (a window|your screen).*" }, { move = { "monitor_w * 0.50", "monitor_h - 12" } })

for _, class in ipairs({ "^(mpv)$", "^(jellyfin-desktop|Jellyfin Media Player|com.github.iwalton3.jellyfin-media-player)$", "^(com.github.th_ch.youtube_music)$" }) do
  window({ class = class }, { idle_inhibit = "focus" })
end
window({ class = "^([Zz]en(-beta|-browser)?)$" }, { idle_inhibit = "fullscreen" })
window({ xwayland = true, title = "win[0-9]+" }, { no_dim = true, no_shadow = true, rounding = 10 })

window({ class = "(steam_app_(default|[0-9]+))|gamescope" }, { opaque = true })
window({ class = "(steam_app_(default|[0-9]+))|gamescope" }, { immediate = true })
window({ class = "(steam_app_(default|[0-9]+))|gamescope" }, { idle_inhibit = "always" })
window({ class = "^(steam_app_.*|gamescope|.*\\.exe|pathofexilesteam\\.exe)$" }, { tag = "+games" })
window({ initial_class = "^(.*\\.exe)$" }, { tag = "+games" })
window({ tag = "games" }, { immediate = true, fullscreen = true, border_size = 0, no_anim = true, no_initial_focus = true, idle_inhibit = "always" })

local function layer(namespace, effects)
  effects.match = { namespace = namespace }
  hl.layer_rule(effects)
end

for _, namespace in ipairs({ "walker", "overview", "anyrun", "indicator.*", "osk", "noanim", "caelestia-(border-exclusion|area-picker)", "quickshell:actionCenter", "quickshell:lockWindowPusher", "quickshell:overlay", "quickshell:overview", "quickshell:polkit", "quickshell:regionSelector", "quickshell:screenshot", "quickshell:session", "gtk4-layer-shell" }) do
  layer(namespace, { no_anim = true })
end
layer("hyprpicker", { animation = "fade" })
layer("logout_dialog", { animation = "fade" })
layer("selection", { animation = "fade" })
layer("wayfreeze", { animation = "fade" })
layer("launcher", { animation = "popin 80%", blur = true })
layer("caelestia-(drawers|background)", { animation = "fade" })
layer("quickshell:bar", { animation = "slide" })
layer("quickshell:cheatsheet", { animation = "slide bottom" })
layer("quickshell:dock", { animation = "slide bottom" })
layer("quickshell:screenCorners", { animation = "popin 120%" })
layer("quickshell:notificationPopup", { animation = "fade" })
layer("quickshell:overlay", { no_anim = true, ignore_alpha = 1 })
layer("quickshell:osk", { animation = "slide bottom", order = -1 })
layer("quickshell:reloadPopup", { animation = "slide" })
layer("quickshell:sidebarRight", { animation = "slide right" })
layer("quickshell:sidebarLeft", { animation = "slide left" })
layer("quickshell:verticalBar", { animation = "slide" })
