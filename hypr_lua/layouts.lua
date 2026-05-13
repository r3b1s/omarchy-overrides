-- Master and scrolling layout overrides.

hl.config({
  general = {
    resize_on_border = true,
    hover_icon_on_border = true,
    layout = "master",
  },

  master = {
    orientation = "left",
    new_status = "slave",
    mfact = 0.5,
    slave_count_for_center_master = 0,
  },

  scrolling = {
    column_width = 0.33,
    focus_fit_method = 1,
  },
})

local masterRoll = "~/.config/hypr/scripts/master-roll"
local orientationCycle = "~/.config/hypr/scripts/orientation-cycle"

hl.unbind("SUPER + S")
hl.bind("SUPER + S", hl.dsp.layout("swapwithmaster"), { description = "Swap Focused Window <-> Master" })

hl.unbind("SUPER + N")
hl.bind("SUPER + N", hl.dsp.exec_cmd(masterRoll .. " next; hyprctl dispatch 'hl.dsp.layout(\"focusmaster\")'"), { description = "Roll to Next Window (Master Layout)" })

hl.unbind("SUPER + SHIFT + N")
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd(masterRoll .. " prev"), { description = "Roll to Prev Window (Master Layout)" })

hl.unbind("SUPER + SHIFT + S")
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(orientationCycle), { description = "Cycle Workspace Orientation (Master Layout)" })
