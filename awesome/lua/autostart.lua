-- ~/.config/awesome/autostart.lua
-- Auto-start applications and scripts for AwesomeWM
-- sudo localectl set-x11-keymap us pc105 dvp
local awful = require("awful")

-- Apps and scripts autostarted using appropriate spawn method
awful.spawn.with_shell("sudo systemctl restart bluetooth.service")
awful.spawn("nm-applet")
awful.spawn("nm-applet --indicator")
awful.spawn("blueman-applet")
-- awful.spawn("greenclip daemon")
awful.spawn("kdeconnectd")
awful.spawn("numlockx on")
awful.spawn.with_shell("xset r rate 300 50")
awful.spawn("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
awful.spawn("lxqt-policykit")
awful.spawn.with_shell("picom --config ~/.config/picom/picom.conf")
awful.spawn.with_shell("xss-lock --transfer-sleep-lock -- betterlockscreen -l &")
awful.spawn.with_shell("~/.fehbg")
awful.spawn.with_shell("~/.config/polybar/lauch.sh")
awful.spawn.with_shell("~/.config/awesome/scripts/cliphist-watcher.sh")
awful.spawn.with_shell("sleep 2 && ~/scripts/startups/connect_realmebuds.sh")
awful.spawn.with_shell("sleep 3 && ~/.config/awesome/scripts/AppsAtutostart.sh")
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
