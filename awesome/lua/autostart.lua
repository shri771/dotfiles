-- ~/.config/awesome/autostart.lua
-- Auto-start applications and scripts for AwesomeWM

local awful = require("awful")

-- Apps and scripts autostarted using appropriate spawn method
awful.spawn.with_shell("lxsession")
awful.spawn.with_shell("picom --config ~/.config/picom/picom.conf")
awful.spawn.with_shell("xss-lock --transfer-sleep-lock -- betterlockscreen -l &")
awful.spawn("nm-applet")
awful.spawn("nm-applet --indicator")
awful.spawn("blueman-applet")
awful.spawn("greenclip daemon")
awful.spawn("kdeconnectd")
awful.spawn("numlockx on")
awful.spawn("xset r rate 250 50")
awful.spawn.with_shell("~/.fehbg")
awful.spawn.with_shell("sleep 3 && ~/scripts/startups/connect_realmebuds.sh")
awful.spawn.with_shell("sleep 5 && ~/.config/awesome/scripts/AppsAtutostart.sh")
awful.spawn.with_shell("~/.config/polybar/lauch.sh")
awful.spawn("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
awful.spawn("lxqt-policykit")

-- Special case: run autokey-qt -c only if not already running
awful.spawn.with_shell("pgrep -x autokey-qt > /dev/null || autokey-qt -c")

-- To load this autostart file, add the following to your rc.lua:
--
--   -- After other requires near the top of ~/.config/awesome/rc.lua:
--   -- Option 1: using dofile:
--   local gears = require("gears")
--   local config_dir = gears.filesystem.get_configuration_dir()
--   dofile(config_dir .. "autostart.lua")
--
--   -- Option 2: using require (with autostart.lua in lua/ folder):
--   require("autostart")
