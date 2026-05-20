-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.env("GDK_SCALE", "1")

hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60.00Hz", position = "0x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "1920x1080@60.00Hz", position = "1920x0", scale = 1 })
