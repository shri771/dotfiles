-- Scratchpad

local awful = require("awful")
local gears = require("gears")

local scratchpads = {}

-- Helper: compute a coordinate given opts.value, total size, window size, start offset, and gap
local function compute_pos(value, total, size, start, gap)
    if type(value) == "number" then
        return start + value
    elseif value == "left" or value == "top" then
        return start + gap
    elseif value == "right" or value == "bottom" then
        return start + total - size - gap
    else
        -- "center" or nil
        return start + (total - size) / 2
    end
end

function make_scratchpad(name, spawn_cmd, opts)
    opts = opts or {}
    opts.width = opts.width or 1050
    opts.height = opts.height or 650
    opts.class = opts.class or name
    opts.gap = opts.gap or 20

    -- Toggle function
    local function toggle()
        local s = awful.screen.focused()
        local tag = s.selected_tag
        local sp = scratchpads[name]

        if sp and sp.valid then
            if not sp.minimized and sp:isvisible() then
                sp.minimized = true
            else
                sp.minimized = false
                sp:move_to_tag(tag)
                sp:raise()
                client.focus = sp
            end
        else
            awful.spawn(spawn_cmd)
        end
    end

    -- When a new client appears, configure it if it matches our scratchpad
    client.connect_signal("manage", function(c)
        if c.class == opts.class then
            scratchpads[name] = c
            c.floating = true
            c.ontop = true
            c.skip_taskbar = true
            c.width = opts.width
            c.height = opts.height

            local wa = c.screen.workarea
            -- figure out x,y
            local x = compute_pos(opts.x, wa.width, opts.width, wa.x, opts.gap)
            local y = compute_pos(opts.y, wa.height, opts.height, wa.y, opts.gap)

            c.x = x
            c.y = y

            if wa.selected_tag then
                c:move_to_tag(wa.selected_tag)
            end
        end
    end)

    -- Keep it on your current tag
    tag.connect_signal("property::selected", function(t)
        local sp = scratchpads[name]
        if sp and sp.valid and not sp.minimized then
            sp:move_to_tag(t)
        end
    end)

    return toggle
end

-- Create toggles
local toggle_pavcontrol = make_scratchpad("pavucontrol", "pavucontrol", {
    width = 800,
    height = 500,
    class = "pavucontrol",
    y = "bottom",
    gap = 230, -- 80px from the top edge
})

local toggle_resources = make_scratchpad("resources", "flatpak run net.nokyan.Resources", {
    width = 820,
    height = 550,
    class = "resources",
    y = "bottom",
    gap = 230,
})

local toggle_clock = make_scratchpad("kclock", "kclock", {
    width = 350,
    height = 450,
    class = "kclock",
    y = "bottom",
    gap = 230,
})

local toggle_kdeconnect = make_scratchpad("kdeconnect.app", "kdeconnect-app", {
    width = 450,
    height = 350,
    class = "kdeconnect.app",
    y = "bottom",
    gap = 230,
})

local toggle_cal = make_scratchpad("Qalculate-gtk", "qalculate-gtk", {
    width = 350,
    height = 520,
    class = "Qalculate-gtk",
    y = "bottom",
    gap = 80,
})

local toggle_terminal = make_scratchpad("scratchkitty", "kitty --class scratchkitty", {
    width = 1050,
    height = 650,
    class = "scratchkitty",
    y = 15, -- gap from top
})

local toggle_whatsie = make_scratchpad("whatsie", "flatpak run com.ktechpit.whatsie", {
    width = 1050,
    height = 650,
    class = "WhatSie",
    y = 15, -- gap from top
})

-- Bind them to keys
globalkeys = gears.table.join(
    globalkeys, -- keep previously defined globalkeys
    awful.key({ modkey,  "Control" }, "Return", toggle_terminal, { description = "Toggle scratch terminal", group = "scratchpads" }),
    awful.key({ modkey, "Control" }, "p", toggle_pavcontrol, { description = "Toggle PulseAudio control", group = "scratchpads" }),
    awful.key({ modkey, "Control" }, "r", toggle_resources, { description = "Toggle resource monitor", group = "scratchpads" }),
    awful.key({ modkey, "Control" }, "c", toggle_cal, { description = "Toggle calculator", group = "scratchpads" }),
    awful.key({ modkey, "Control" }, "k", toggle_clock, { description = "Toggle clock", group = "scratchpads" }),
    awful.key({ modkey, "Control" }, "d", toggle_kdeconnect, { description = "Toggle KDE Connect", group = "scratchpads" }),
    awful.key({ modkey, "Control" }, "w", toggle_whatsie, { description = "Toggle Whatsie", group = "scratchpads" }),
    awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end),
    awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next") end),
    awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous") end)
)

return globalkeys
