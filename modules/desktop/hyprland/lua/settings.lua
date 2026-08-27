hl.config({
  general = {
    gaps_workspaces = 20,
    gaps_in = 5,
    gaps_out = 10,
    border_size = 1,
    col = {
      active_border = { colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" }, angle = 45 },
      inactive_border = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 },
    },
    resize_on_border = false,
    layout = "dwindle",
    allow_tearing = true,
  },
  decoration = {
    shadow = {
      enabled = true,
      range = 15,
      render_power = 4,
      color = "rgba(59599210)",
    },
    rounding = isCaelestia and 15 or 0,
    dim_special = 0.3,
    blur = {
      enabled = true,
      xray = false,
      special = false,
      ignore_opacity = true,
      new_optimizations = true,
      popups = true,
      input_methods = true,
      size = 8,
      passes = 2,
    },
  },
  group = {
    col = {
      border_active = { colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" }, angle = 45 },
      border_inactive = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 },
      border_locked_active = { colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" }, angle = 45 },
      border_locked_inactive = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 },
    },
  },
  input = {
    kb_layout = kbdLayout,
    numlock_by_default = true,
    repeat_delay = 250,
    repeat_rate = 35,
    follow_mouse = 1,
    off_window_axis_events = 2,
    touchpad = {
      natural_scroll = false,
      disable_while_typing = true,
      clickfinger_behavior = true,
      scroll_factor = 0.7,
    },
    tablet = { output = "current" },
    sensitivity = 0,
    accel_profile = "flat",
  },
  render = {
    cm_auto_hdr = 0,
    direct_scanout = 2,
  },
  ecosystem = {
    no_update_news = true,
    no_donation_nag = true,
  },
  misc = {
    middle_click_paste = false,
    on_focus_under_fullscreen = false,
    anr_missed_pings = 3,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    mouse_move_focuses_monitor = true,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = true,
    animate_manual_resizes = false,
    animate_mouse_windowdragging = false,
    force_default_wallpaper = 0,
    swallow_regex = "(foot|kitty|allacritty|Alacritty)",
    enable_swallow = false,
    disable_autoreload = true,
    disable_hyprland_guiutils_check = true,
    vrr = vrr,
    allow_session_lock_restore = true,
    session_lock_xray = true,
    initial_workspace_tracking = false,
    focus_on_activate = true,
    background_color = "rgb(201f23)",
  },
  cursor = {
    no_hardware_cursors = 2,
    enable_hyprcursor = true,
    sync_gsettings_theme = false,
    zoom_factor = 1.0,
    zoom_rigid = false,
    zoom_disable_aa = true,
    hotspot_padding = 1,
  },
  xwayland = {
    force_zero_scaling = true,
  },
  gestures = {
    workspace_swipe_distance = 700,
    workspace_swipe_cancel_ratio = 0.2,
    workspace_swipe_min_speed_to_force = 5,
    workspace_swipe_direction_lock = true,
    workspace_swipe_direction_lock_threshold = 10,
    workspace_swipe_create_new = true,
  },
  dwindle = {
    preserve_split = true,
    smart_split = false,
    smart_resizing = false,
  },
  master = {
    new_status = "master",
    new_on_top = true,
    mfact = 0.5,
  },
  debug = {
    disable_logs = false,
    enable_stdout_logs = false,
  },
})

hl.gesture({ fingers = 3, direction = "swipe", action = "move" })
hl.gesture({ fingers = 3, direction = "pinch", action = "fullscreen" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

hl.on("hyprland.start", function()
  hl.exec_cmd(barCommand)
  hl.exec_cmd(clipboardTextCommand)
  hl.exec_cmd(clipboardImageCommand)
  hl.exec_cmd(clearClipboardCommand)
  hl.exec_cmd("uwsm app -s b -- kdeconnect-indicator")
  hl.exec_cmd("hyprctl setcursor catppuccin-mocha-mauve-cursors 24")
  if nmAppletCommand ~= nil then
    hl.exec_cmd(nmAppletCommand)
  end
  if batteryNotifyCommand ~= nil then
    hl.exec_cmd(batteryNotifyCommand)
  end
end)
