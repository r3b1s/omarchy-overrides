-- Gaps Resize Submap
--
-- Enter with SUPER+CTRL+G to adjust gaps_out on specific axes.
--   l: increase left+right gaps  |  h: decrease left+right gaps
--   k: increase top+bottom gaps  |  j: decrease top+bottom gaps
--   Esc: exit submap

-- Call hypr/scripts/delta-resize to get screen-percentage-based step values.
local home = os.getenv("HOME") or ""
local delta_script = home .. "/.config/hypr/scripts/delta-resize"

local function get_step_x()
	local handle = io.popen(delta_script .. " --print x")
	local v = tonumber(handle:read("*a")) or 10
	handle:close()
	return math.max(1, v)
end

local function get_step_y()
	local handle = io.popen(delta_script .. " --print y")
	local v = tonumber(handle:read("*a")) or 10
	handle:close()
	return math.max(1, v)
end

local submapNotify = 'notify-send "Gaps Resize [ON]" "h/l: sides  |  j/k: top/bottom  |  Esc: exit"'

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
		local s = get_step_x()
		local g = norm(hl.get_config("general.gaps_out"))
		g.left = clamp(g.left + s)
		g.right = clamp(g.right + s)
		hl.config({ general = { gaps_out = pack(g) } })
	end)

	hl.bind("h", function()
		local s = get_step_x()
		local g = norm(hl.get_config("general.gaps_out"))
		g.left = clamp(g.left - s)
		g.right = clamp(g.right - s)
		hl.config({ general = { gaps_out = pack(g) } })
	end)

	hl.bind("k", function()
		local s = get_step_y()
		local g = norm(hl.get_config("general.gaps_out"))
		g.top = clamp(g.top + s)
		g.bottom = clamp(g.bottom + s)
		hl.config({ general = { gaps_out = pack(g) } })
	end)

	hl.bind("j", function()
		local s = get_step_y()
		local g = norm(hl.get_config("general.gaps_out"))
		g.top = clamp(g.top - s)
		g.bottom = clamp(g.bottom - s)
		hl.config({ general = { gaps_out = pack(g) } })
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
