-- ~/.config/awesome/lua/rules.lua
-- Window rules for AwesomeWM

local awful = require("awful")
local beautiful = require("beautiful")

return function(clientkeys, clientbuttons)
    return {
        {
            rule = {},
            except_any = { class = { "Polybar", "scratchkitty" } },
            properties = {
                border_width     = beautiful.border_width,
                border_color     = beautiful.border_normal,
                focus            = awful.client.focus.filter,
                raise            = true,
                keys             = clientkeys,
                buttons          = clientbuttons,
                screen           = awful.screen.preferred,
                placement        = awful.placement.no_overlap + awful.placement.no_offscreen,
                size_hints_honor = false,
            },
        },

        {
            rule_any = {
                type = { "dialog", "utility", "splash" },
                role = { "pop-up", "GtkFileChooserDialog" },
                name = { "Preferences", "Options" },
            },
            except_any = { class = { "polkit-gnome-authentication-agent-1", "kdialog" } },
            instance = { "kdialog" },
            properties = {
                floating = true,
                ontop    = true,
            },
            callback = function(c)
                local f = client.focus
                if f then
                    local fg = f:geometry()
                    local cg = c:geometry()
                    local nx = fg.x + math.floor((fg.width - cg.width) / 2)
                    local ny = fg.y + math.floor((fg.height - cg.height) / 2)
                    c:geometry({ x = nx, y = ny, width = cg.width, height = cg.height })
                else
                    awful.placement.centered(c, { honor_workarea = true })
                end
            end,
        },

        {
            rule_any = { class = { "Polybar" } },
            properties = { floating = true, below = true },
        },

        { rule = { class = "vlc" }, properties = { tag = "   " } },
        {
            rule = { class = "autokey-qt" },
            properties = { tag = awful.screen.focused().tags[7] },
        },
        {
            rule = { class = "VirtualBox Machine", name = "home ais [Running] - Oracle VirtualBox" },
            properties = {
                tag = function(c)
                    for _, t in ipairs(c.screen.tags) do
                        if t.name == " " then return t end
                    end
                    return c.screen.tags[1]
                end,
                maximized = false,
            },
        },

        { rule = { class = "Rquickshare" }, properties = { floating = true } },
        {
            rule = { class = "kdialog" },
            properties = { floating = true, ontop = true, placement = awful.placement.centered },
        },
        {
            rule = { class = "Brave-browser", instance = "crx_nngceckbapebfimnlniiiahkandclblb" },
            properties = { floating = true, ontop = true },
        },
        {
            rule_any = {
                instance = { "DTA", "blueman-manager", "copyq" },
                class = { "Blueberry", "Qalculate-gtk", "kcolorchooser", "Blueman-manager", "qt5ct", "qt6ct" },
            },
            properties = { floating = true, ontop = true },
            callback = function(c)
                c:geometry({ width = 550, height = 440 })
                awful.placement.centered(c, { honor_workarea = true })
            end,
        },

        { rule = { class = "VirtualBox Manager" }, properties = { maximized = false } },
        { rule = { class = "Xfce4-settings-manager" }, properties = { floating = false } },
    }
end
