local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi = require("beautiful.xresources").apply_dpi

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme = {}
theme.dir = os.getenv("HOME") .. "/.config/awesome/"
theme.font = "sans 11"

theme.fg_normal = "#FEFEFE"
theme.fg_focus = "#32D6FF"
theme.fg_urgent = "#C83F"

theme.bg_normal = "#282a36"
theme.bg_focus = "#282a36"
theme.bg_urgent = "#282a36"
theme.taglist_fg_focus = "#00CCFF"
theme.tasklist_bg_focus = "#282a36"
theme.tasklist_fg_focus = "#00CCFF"

theme.border_width = dpi(1.3)
theme.border_normal = "#00000088"
theme.border_focus = "#ff007f"
theme.border_marked = "#91231c"
theme.titlebar_bg_focus = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"

theme.titlebar_bg_focus = theme.bg_focus
theme.titlebar_bg_normal = theme.bg_normal
theme.titlebar_fg_focus = theme.fg_focus
theme.menu_height = dpi(15)
theme.menu_width = dpi(150)

local separators = lain.util.separators

-- Separators
local arrow = separators.arrow_left
local spr = wibox.widget.textbox(" ")

function theme.powerline_rl(cr, width, height)
	local arrow_depth, offset = height / 2, 0

	-- Avoid going out of the (potential) clip area
	if arrow_depth < 0 then
		width = width + 2 * arrow_depth
		offset = -arrow_depth
	end

	cr:move_to(offset + arrow_depth, 0)
	cr:line_to(offset + width, 0)
	cr:line_to(offset + width - arrow_depth, height / 2)
	cr:line_to(offset + width, height)
	cr:line_to(offset + arrow_depth, height)
	cr:line_to(offset, height / 2)

	cr:close_path()
end

-- Add this anywhere in theme.lua
theme.volume = {
	channel = "Master", -- or "PCM", "Speaker", etc.
	togglechannel = "Master", -- optional, use different if needed
	update = function() end, -- optional: set to a function or leave as dummy
}
function theme.at_screen_connect(s)
	-- Quake application
	s.quake = lain.util.quake({ app = awful.util.terminal })

	-- Tags
	awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(my_table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 2, function()
			awful.layout.set(awful.layout.layouts[1])
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

	-- Create a tasklist widget
	--s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

	-- Create the wibox
	--s.mywibox = awful.wibar({ position = "top", screen = s, height = 25, bg = theme.bg_normal, fg = theme.fg_normal })

	-- Add widgets to the wibox
end

theme.useless_gap = 2.4

return theme
