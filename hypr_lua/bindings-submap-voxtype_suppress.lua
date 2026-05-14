-- Define: VM Passthru Submap
hl.define_submap("voxtype_suppress", function()
	hl.bind("Delete", function()
		hl.dispatch(hl.dsp.submap("reset"), { description = "End Voxtype Suppression", submap = "voxtype_suppress" })
		hl.dispatch(hl.dsp.exec_cmd('notify-send "Disabled Submap: voxtype_suppress"'))
	end)
end)
