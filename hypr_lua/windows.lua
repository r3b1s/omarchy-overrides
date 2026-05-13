-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- Omarchy's default.hypr.windows already loads default.hypr.apps.

hl.window_rule({
  match = { class = "(blueberry.py|Impala|nmtui|Wiremix|org.gnome.NautilusPreviewer|com.gabm.satty|Omarchy|About|TUI.float)" },
  tag = "+floating-window",
})

hl.window_rule({ match = { tag = "OPAQUE" }, opacity = "1.0 override 1.0 override" })

hl.window_rule({
  name = "opaque",
  match = { class = ".*" },
  tag = "+OPAQUE",
})

hl.window_rule({
  name = "clear",
  match = { class = ".*" },
  tag = "-OPAQUE",
})

local protonclass = "proton.vpn.app.gtk"

hl.window_rule({
  match = { title = "(Proton VPN)", class = protonclass },
  move = "((monitor_w*1)-416) ((monitor_h*0.03))",
})

hl.window_rule({
  match = { title = "Settings", class = "protonvpn-app" },
  move = "((monitor_w*1)-1168) ((monitor_h*0.03))",
  size = "750 (monitor_h*0.96)",
})

hl.window_rule({
  match = { initial_class = "org.omarchy.Gazelle" },
  float = true,
  center = true,
  size = "800 600",
})

hl.window_rule({ match = { class = "net.mkiol.SpeechNote" }, workspace = "special:SpeechNote" })
hl.window_rule({ match = { class = "Bitwarden" }, workspace = "special:Password-Manager" })
hl.window_rule({ match = { class = "org.cryptomator.launcher.Cryptomator$MainApp" }, workspace = "special:Cryptomator" })

-- Rules from scratchpad app sections in bindings.conf.
hl.window_rule({ match = { class = "vesktop" }, workspace = "special:Discord" })
hl.window_rule({ match = { class = "com.moonlight_stream.Moonlight" }, workspace = "special:Moonlight" })
