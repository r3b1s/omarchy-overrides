-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
  input = {
    kb_layout = "us",
    kb_options = "caps:caps",
    numlock_by_default = true,

    touchpad = {
      scroll_factor = 1.6,
    },
  },
})

local scrollspeed_tpad = 1.8

-- scroll_touchpad is a Hyprland 0.55 window-rule effect; validate against the
-- installed stubs after upgrade.
hl.window_rule({ match = { class = "Alacritty" }, scroll_touchpad = scrollspeed_tpad })
hl.window_rule({ match = { class = "com.mitchellh.ghostty" }, scroll_touchpad = scrollspeed_tpad })
