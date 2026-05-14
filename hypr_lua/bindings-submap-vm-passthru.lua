local submapNotifyPassthru = 'notify-send "Enabled VM Passthrough" ""'
local submapNotifyDefault = 'notify-send "Disabled VM Passthrough" ""'
local delete = "code:119"

-- Define: VM Passthru Submap
hl.define_submap("passthru", function()
	hl.bind("Delete", function()
		hl.dispatch(hl.dsp.submap("reset"), { description = "End VM Passthru", submap = "passthru" })
		hl.dispatch(hl.dsp.exec_cmd(submapNotifyDefault))
	end)
end)

-- Bind: Enable VM Passthru Submap
hl.unbind("SUPER + Delete")
hl.unbind("SUPER + delete")
hl.unbind("SUPER + DELETE")
hl.unbind("SUPER + " .. delete)
--
hl.bind("SUPER + Delete", function()
	hl.dispatch(hl.dsp.submap("passthru"), { description = "Suppress user input during voxtype:type input" })
	hl.dispatch(hl.dsp.exec_cmd(submapNotifyPassthru))
end)
