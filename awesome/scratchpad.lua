local awful = require("awful")

local scratchpads = {}

-- Scratchpad generator
local function make_scratchpad(name, spawn_cmd, opts)
	opts = opts or {}
	opts.width = opts.width or 1050
	opts.height = opts.height or 650
	opts.class = opts.class or name

	local function toggle()
		local s = awful.screen.focused()
		local tag = s.selected_tag
		local spad = scratchpads[name]

		if spad and spad.valid then
			if not spad.minimized and spad:isvisible() then
				spad.minimized = true
			else
				spad.minimized = false
				spad:move_to_tag(tag)
				spad:raise()
				client.focus = spad
			end
		else
			awful.spawn(spawn_cmd)
		end
	end

	client.connect_signal("manage", function(c)
		if c.class == opts.class then
			scratchpads[name] = c
			c.floating = true
			c.ontop = true
			c.skip_taskbar = true
			c.width = opts.width
			c.height = opts.height

			local wa = c.screen.workarea
			local gap = opts.gap or 20
			c.x = wa.x + (wa.width - opts.width) / 2
			c.y = wa.y + gap

			local tag = c.screen.selected_tag
			if tag then
				c:move_to_tag(tag)
			end
		end
	end)

	tag.connect_signal("property::selected", function(t)
		local spad = scratchpads[name]
		if spad and spad.valid and not spad.minimized then
			spad:move_to_tag(t)
		end
	end)

	return toggle
end

-- Define your toggles here
local toggle_term = make_scratchpad("scratchterm", "kitty --class scratchterm", { width = 1000, height = 600 })
local toggle_music = make_scratchpad("scratchmusic", "spotify --class scratchmusic", { width = 900, height = 500 })

-- Export them
return {
	toggle_term = toggle_term,
	toggle_music = toggle_music,
}
