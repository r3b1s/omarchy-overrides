-- Gaps Resize Submap
--
-- Enter with SUPER+CTRL+G to adjust gaps on specific axes.
--   h/l: gaps_out (sides)  |  j/k: gaps_out (top/bottom)
--   arrows: gaps_in (same axes)
--   Esc: exit submap

-- Screen-percentage step (same 5.5% factor as hypr/scripts/delta-resize).
-- Uses hl.* API directly (no subprocess/hyprctl calls) to avoid IPC deadlocks
-- since this runs inside Hyprland's Lua callback context.
local FACTOR = 0.055

local function mon_dim(axis)
	local mon = hl.get_active_monitor() or hl.get_monitor_at_cursor()
	local dim = mon and tonumber(mon[axis]) or (axis == "width" and 1920 or 1080)
	return dim
end

local function step_for(axis)
	return math.max(1, math.floor(mon_dim(axis) * FACTOR))
end

local submapNotify = 'notify-send "Gaps Resize [ON]" "h/l: out  |  j/k: out  |  arrows: in  |  Esc: exit"'

-- ── gap helpers ───────────────────────────────────────────────────────────────

-- Normalize gaps_out to a table with top/right/bottom/left keys.
-- Hyprland stores uniform gaps as a single number and asymmetric gaps as a table.
local function norm(val)
	if type(val) == "number" then
		return { top = val, right = val, bottom = val, left = val }
	end
	if type(val) ~= "table" then
		return { top = 0, right = 0, bottom = 0, left = 0 }
	end
	return {
		top = tonumber(val.top) or 0,
		right = tonumber(val.right) or 0,
		bottom = tonumber(val.bottom) or 0,
		left = tonumber(val.left) or 0,
	}
end

-- Pack back to a single number if all sides equal, otherwise a table.
local function pack(g)
	if g.top == g.right and g.right == g.bottom and g.bottom == g.left then
		return g.top
	end
	return { top = g.top, right = g.right, bottom = g.bottom, left = g.left }
end

-- Clamp to zero (negative gaps are nonsensical).
local function clamp(v)
	return math.max(0, v)
end

-- ── submap definition ─────────────────────────────────────────────────────────

hl.define_submap("gaps-resize", function()
	hl.bind("l", function()
		local s = step_for("width")
		local g = norm(hl.get_config("general.gaps_out"))
		g.left = clamp(g.left + s)
		g.right = clamp(g.right + s)
		hl.config({ general = { gaps_out = pack(g) } })
	end)

	hl.bind("h", function()
		local s = step_for("width")
		local g = norm(hl.get_config("general.gaps_out"))
		g.left = clamp(g.left - s)
		g.right = clamp(g.right - s)
		hl.config({ general = { gaps_out = pack(g) } })
	end)

	hl.bind("k", function()
		local s = step_for("height")
		local g = norm(hl.get_config("general.gaps_out"))
		g.top = clamp(g.top + s)
		g.bottom = clamp(g.bottom + s)
		hl.config({ general = { gaps_out = pack(g) } })
	end)

	hl.bind("j", function()
		local s = step_for("height")
		local g = norm(hl.get_config("general.gaps_out"))
		g.top = clamp(g.top - s)
		g.bottom = clamp(g.bottom - s)
		hl.config({ general = { gaps_out = pack(g) } })
	end)

	-- Arrow keys → gaps_in (same axis pattern, same step)
	hl.bind("Right", function()
		local s = step_for("width")
		local g = norm(hl.get_config("general.gaps_in"))
		g.left = clamp(g.left + s)
		g.right = clamp(g.right + s)
		hl.config({ general = { gaps_in = pack(g) } })
	end)

	hl.bind("Left", function()
		local s = step_for("width")
		local g = norm(hl.get_config("general.gaps_in"))
		g.left = clamp(g.left - s)
		g.right = clamp(g.right - s)
		hl.config({ general = { gaps_in = pack(g) } })
	end)

	hl.bind("Up", function()
		local s = step_for("height")
		local g = norm(hl.get_config("general.gaps_in"))
		g.top = clamp(g.top + s)
		g.bottom = clamp(g.bottom + s)
		hl.config({ general = { gaps_in = pack(g) } })
	end)

	hl.bind("Down", function()
		local s = step_for("height")
		local g = norm(hl.get_config("general.gaps_in"))
		g.top = clamp(g.top - s)
		g.bottom = clamp(g.bottom - s)
		hl.config({ general = { gaps_in = pack(g) } })
	end)

	hl.bind("Escape", function()
		hl.dispatch(hl.dsp.submap("reset"), { description = "Exit Gaps Resize", submap = "gaps-resize" })
	end)
end)

-- ── entry binding ─────────────────────────────────────────────────────────────

hl.unbind("SUPER + CTRL + G")
hl.unbind("SUPER + CTRL + " .. "code:42") -- g keycode
--
hl.bind("SUPER + CTRL + G", function()
	hl.dispatch(hl.dsp.submap("gaps-resize"), { description = "Adjust gaps_out" })
	hl.dispatch(hl.dsp.exec_cmd(submapNotify))
end)
