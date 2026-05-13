local submapNotifyPassthru = 'notify-send "Enabled VM Passthrough" ""'
local submapNotifyDefault = 'notify-send "Disabled VM Passthrough" ""'
local delete = "code:119"

hl.unbind("SUPER + Delete")
hl.unbind("SUPER + delete")
hl.unbind("SUPER + DELETE")
hl.unbind("SUPER + " .. delete)
hl.bind(
  "SUPER + Delete",
  hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.submap(\"passthru\")'; " .. submapNotifyPassthru),
  { description = "Virtual Machine SUPER Key Passthru" }
)

hl.bind(
  "Delete",
  hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.submap(\"reset\")'; " .. submapNotifyDefault),
  { description = "End VM Passthru", submap = "passthru" }
)
