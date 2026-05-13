local submapNotifyPassthru = 'notify-send "Enabled VM Passthrough" ""'
local submapNotifyDefault = 'notify-send "Disabled VM Passthrough" ""'
local delete = "code:119"

hl.unbind("SUPER + Delete")
hl.unbind("SUPER + delete")
hl.unbind("SUPER + DELETE")
hl.unbind("SUPER + " .. delete)
hl.bind(
  "SUPER + Delete",
  hl.dsp.exec_cmd("hyprctl dispatch submap passthru; " .. submapNotifyPassthru),
  { description = "Virtual Machine SUPER Key Passthru" }
)

-- Lua-native submap helpers are not exposed in the public examples yet. Keep
-- hyprctl dispatch fallbacks for first 0.55 validation.
hl.bind(
  "Delete",
  hl.dsp.exec_cmd("hyprctl dispatch submap reset; " .. submapNotifyDefault),
  { description = "End VM Passthru", submap = "passthru" }
)
