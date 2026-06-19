-- Browser Profiles Submap
--
-- Enter with SUPER+SHIFT+CTRL+ALT+B to launch a specific browser profile.
--   0-9: Launch browser with selected profile
--   SHIFT+0-9, SHIFT+D: Launch browser with selected profile in incognito mode
--   P: Launch browser in incognito mode with a fresh temp profile
--   Esc: exit submap

-- Browser CLI entry point and flags template.
-- %s is replaced with the profile name (e.g. "Profile 4") at call time.
local browserCli       = "brave-origin-beta"
local browserFlags     = '--profile-directory="%s"'
local browserIncognito = "--incognito"

local submapNotify = 'notify-send "Browser Profiles [ON]" "0-9: Launch profile  |  Esc: exit"'

-- ── submap definition ─────────────────────────────────────────────────────────

hl.define_submap("browser-profiles", function()
	-- Bind number row keys 0-9 to launch the browser with the corresponding profile.
	-- Each binding also exits the submap after execution.
	for i = 0, 9 do
		local keyLabel = tostring(i)
		local profileName = "Profile " .. tostring(i)

		hl.bind(keyLabel, function()
			hl.dispatch(hl.dsp.exec_cmd(browserCli .. " " .. string.format(browserFlags, profileName)))
			hl.dispatch(hl.dsp.submap("reset"), { description = "Exit browser profiles", submap = "browser-profiles" })
		end)
	end

	-- Bind "D" to launch with the "Default" profile.
	hl.bind("d", function()
		hl.dispatch(hl.dsp.exec_cmd(browserCli .. " " .. string.format(browserFlags, "Default")))
		hl.dispatch(hl.dsp.submap("reset"), { description = "Exit browser profiles", submap = "browser-profiles" })
	end)

	-- Bind SHIFT+0-9 to launch the corresponding profile in incognito mode.
	for i = 0, 9 do
		local keyLabel    = tostring(i)
		local profileName = "Profile " .. tostring(i)

		hl.bind("SHIFT + " .. keyLabel, function()
			hl.dispatch(hl.dsp.exec_cmd(browserCli .. " " .. string.format(browserFlags, profileName) .. " " .. browserIncognito))
			hl.dispatch(hl.dsp.submap("reset"), { description = "Exit browser profiles", submap = "browser-profiles" })
		end)
	end

	-- Bind SHIFT+D to launch the "Default" profile in incognito mode.
	hl.bind("SHIFT + d", function()
		hl.dispatch(hl.dsp.exec_cmd(browserCli .. " " .. string.format(browserFlags, "Default") .. " " .. browserIncognito))
		hl.dispatch(hl.dsp.submap("reset"), { description = "Exit browser profiles", submap = "browser-profiles" })
	end)

	-- Bind P to launch in incognito mode with a fresh temp profile.
	hl.bind("p", function()
		hl.dispatch(hl.dsp.exec_cmd(browserCli .. " --profile-directory=\"/run/user/$UID/" .. browserCli .. "/private-tmp\" " .. browserIncognito))
		hl.dispatch(hl.dsp.submap("reset"), { description = "Exit browser profiles", submap = "browser-profiles" })
	end)

	-- Bind "N" to launch the profile creation GUI.
	hl.bind("n", function()
		hl.dispatch(hl.dsp.exec_cmd(browserCli .. " --profile-directory='System Profile'"))
		hl.dispatch(hl.dsp.submap("reset"), { description = "Exit browser profiles", submap = "browser-profiles" })
	end)

	-- Escape exits submap without launching anything.
	hl.bind("Escape", function()
		hl.dispatch(hl.dsp.submap("reset"), { description = "Exit browser profiles", submap = "browser-profiles" })
	end)
end)

-- ── entry binding ─────────────────────────────────────────────────────────────

hl.unbind("SUPER + SHIFT + CTRL + ALT + B")
hl.unbind("SUPER + SHIFT + CTRL + ALT + " .. "code:56") -- b keycode
--
hl.bind("SUPER + SHIFT + CTRL + ALT + B", function()
	hl.dispatch(hl.dsp.submap("browser-profiles"), { description = "Launch browser with selected profile" })
	hl.dispatch(hl.dsp.exec_cmd(submapNotify))
end)
