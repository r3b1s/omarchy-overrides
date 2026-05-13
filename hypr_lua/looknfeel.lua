-- Change the default Omarchy look'n'feel.

hl.config({
  general = {
    border_size = 0,
    gaps_in = 0,
    gaps_out = 0,
    float_gaps = 4,
  },

  decoration = {
    active_opacity = 0.90,
    inactive_opacity = 0.72,
    fullscreen_opacity = 1,
    rounding = 0,
    rounding_power = 2.0,
    dim_special = 0.4,

    blur = {
      enabled = true,
      -- Validate this 0.54-era option against /usr/share/hypr/stubs after the
      -- 0.55 upgrade; it is kept here for parity with the active config.
      new_optimizations = true,
      noise = 0.21,
      contrast = 1.5,
      xray = true,
      special = false,
      popups = false,
      passes = 2,
    },
  },

  animations = {
    enabled = true,
  },

  ecosystem = {
    no_donation_nag = true,
  },

  binds = {
    workspace_back_and_forth = true,
    hide_special_on_workspace_change = true,
  },
})

hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "default", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 3, bezier = "default", style = "slidefade top" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3, bezier = "default", style = "slidefade bottom" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "default", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "default", style = "gnomed" })
