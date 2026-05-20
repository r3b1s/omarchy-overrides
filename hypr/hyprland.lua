-- Staged Hyprland 0.55 Lua entrypoint.
-- hypr_lua/ is only a temporary repository location; runtime module paths are
-- written as hypr.* so these files can be moved to ~/.config/hypr unchanged.

local home = os.getenv("HOME") or ""

package.path = home
    .. "/.config/?.lua;"
    .. (os.getenv("OMARCHY_PATH") or (home .. "/.local/share/omarchy"))
    .. "/?.lua;"
    .. package.path

local paths = require("default.hypr.paths")

require("default.hypr.helpers")
require("default.hypr.autostart")
require("default.hypr.bindings.media")
require("default.hypr.bindings.clipboard")
require("default.hypr.bindings.tiling-v2")
require("default.hypr.bindings.utilities")
require("default.hypr.envs")
require("default.hypr.looknfeel")
require("default.hypr.input")
require("default.hypr.windows")

do
  local theme = io.open(paths.config_home .. "/omarchy/current/theme/hyprland.lua", "r")
  if theme then
    theme:close()
    require("omarchy.current.theme.hyprland")
  end
end

require("hypr.autostart")
require("hypr.monitors")
require("hypr.input")
require("hypr.looknfeel")
require("hypr.windows")
require("hypr.bindings")
require("hypr.bindings-submap-vm-passthru")
require("hypr.bindings-submap-voxtype_suppress")
require("hypr.layouts")

-- require("default.hypr.toggles")
