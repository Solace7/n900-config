
local gfs = ("gears.filesystem")
local gears = require("gears")
local awful = require("awful")
local naughty = require("naughty")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Extra plugins!
local lain = require("lain")

--Credit to Worron @github.com/worron for the Following--
local redflat = require("redflat")
local timestamp = require("redflat.timestamp")
local env = require("modules.env-config")

----------------------------------{{{ERROR HANDLING}}}----------------------------------
errorcheck = require("modules.errorcheck")

env:init({ theme = "gruvbox" })

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.top,
	awful.layout.suit.fair,
    awful.layout.suit.max,
}

redflat.layout.map.notification = true

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ env.mod }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ env.mod }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end)
)

-------------------------
-------{{WIDGETS}}-------
-------------------------
local widgets = require("modules.widgets")
widgets:init({ env = env })

function round(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) /mult
end

-- Separator Widget
local widgetseparator = widgets.widgetseparator

-- Create a textclock widget
local mytextclock = widgets.mytextclock

-- CPU Governor Widget
local cpugovernor = widgets.cpugovernor

-- Memory Widget
local memwidget = lain.widget.mem({
    settings = function()
        widget:set_markup(round((mem_now.used/1024),2).. "GB/" .. round(mem_now.total/1024,2) .. "GB")
    end
})

--Temperature widget
local tempwidget = widgets.tempwidget 

-- Keyboard map indicator and switcher
local mykeyboardlayout = widgets.mykeyboardlayout

-- Power widget
local powwidget = widgets.battwidget 

-- Volume widget
local volwidget = widgets.volume

--{{Network widget
local wifi_icon = widgets.wifi_icon
local eth_icon = widgets.eth_icon
--}}

-- Pacman need update widgets
-- if [[ pacman -Qu | grep -v ignored  | wc -l ]] > 0
--local watchpacman = widgets.watchpacman

-- Systemtray widget
local systemtray = wibox.widget.systray()

--TODO Layoutbox

-----------Screen Setup-----------
awful.screen.connect_for_each_screen(function(s)
----------------------------
-------{{WORKSPACES}}-------
----------------------------

    -- Each screen has its own tag table.
awful.tag(
{
    "MAIN",
    "SECONDARY",
    "TERTIARY",
    "QUATERNARY",
    "EDEX",
    "DEVELOP",
    "EXT",
    "COMMS",
    "NONARY" ,
    "CREATE",
}, s, awful.layout.layouts[1])

--------------------------------
-------{{END WORKSPACES}}-------
--------------------------------
env.wallpaper(s)
------------------------------
---------{{TITLEBAR}}---------
------------------------------

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.noempty, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create a layoutbox widget
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc( -1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc( -1) end)))

    --Change Volume on Scrollwheel up/down
    volwidget.widget:buttons(awful.util.table.join(
        awful.button({ }, 4, function()
            awful.spawn("amixer -c 0 -q sset Master 5%+") --scroll up
            volwidget.update()
        end),
        awful.button({ }, 5, function()
            awful.spawn("amixer -c 0 -q sset Master 5%-") --scroll down
            volwidget.update()
        end)
    ))

    -- Create the wibox
    s.toppanel = awful.wibar({ position = "top", screen = s, height=beautiful.panel_height })

    -- Add widgets to the wibox
    s.toppanel:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- Left Widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
            -- Middle Widgets
            mytextclock,
        { -- Right Widgets
            layout = wibox.layout.fixed.horizontal,
            widgets.mpdwidget,
            s.mylayoutbox,
        },
    }

    --TODO
    --CPU (All 8 threads), jack_control status and MEM usage
    -- create second wibar
    s.botpanel = awful.wibar({ position = "bottom", screen = s, height=beautiful.panel_height })
    s.botpanel:setup {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        {-- Left Widgets
            layout = wibox.layout.fixed.horizontal,
            cpugovernor,
            widgetseparator,
            memwidget.widget,
            widgetseparator,
            tempwidget,
            widgetseparator,
            s.mytasklist,
        },
            --Middle Wdigets
              nil,
            {-- Right Widgets
            layout = wibox.layout.fixed.horizontal,
            powwidget,
            widgetseparator,
            volwidget,
            widgetseparator,
            wifi_icon,
            eth_icon,
            systemtray,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

--------------------------
-------{{KEYBINDS}}-------
--------------------------

globalkeys = gears.table.join(
    awful.key({ env.mod,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ env.mod,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ env.mod, "Control" }, "space", naughty.destroy_all_notifications,
              {description = "destroy notification", group = "awesome"}),
--    awful.key({ "Control",         }, "Print", function() awful.spawn("scrot -s -e ' mv $f ~/Pictures/Screenshots/") end,
             -- {description = "take a screenshot",   group = "awesome"}),

    --Switching Windows
    awful.key({ env.mod,           }, "Right",
        function ()
            local l = awful.layout.getname(awful.layout.get(awful.screen.focused()))
            if(l == "max") then
                awful.client.focus.byidx(1)
            else
                awful.client.focus.global_bydirection("right")
            end
            if client.focus then client.focus:raise() end
        end,
        {description = "focus window next", group = "client"}
    ),
    awful.key({ env.mod,           }, "Left",
        function ()
            local l = awful.layout.getname(awful.layout.get(awful.screen.focused()))
            if(l == "max") then
                awful.client.focus.byidx(-1)
            else 
                awful.client.focus.global_bydirection("left")
            end
            if client.focus then client.focus:raise() end
        end,
        {description = "focus window previous", group = "client"}
    ),
    awful.key({ env.mod,           }, "Down",
        function()
            awful.client.focus.global_bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus window below", group = "client"}
    ),
    awful.key({ env.mod,           }, "Up",
        function()
        if client.focus then client.focus:raise() end
            awful.client.focus.global_bydirection("up")
        end,
        {description = "focus window above", group = "client"}
    ),

    --Moving Windows
    awful.key({ env.mod, "Shift"   }, "Left",
    function ()
        awful.client.swap.global_bydirection("left")
    end,
              {description = "swap with client to the left", group = "client"}),
    awful.key({ env.mod, "Shift"   }, "Right",
    function ()
        awful.client.swap.global_bydirection("right")
    end,
              {description = "swap with client to the right", group = "client"}),
    awful.key({ env.mod, "Shift"   }, "Down",
    function ()
        awful.client.swap.global_bydirection("down")
    end,
              {description = "swap with client below", group = "client"}),
    awful.key({ env.mod, "Shift"   }, "Up",
    function ()
        awful.client.swap.global_bydirection("up")
    end,
              {description = "swap with client above", group = "client"}),

    awful.key({ env.mod,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    awful.key({ env.mod,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    awful.key({ env.mod,           }, "j", function () awful.screen.focus_bydirection("left") end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ env.mod,           }, "k", function () awful.screen.focus_bydirection("right") end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ env.mod,   "Shift" }, "j",   awful.client.movetoscreen,
              {description = "move to next screen, cycling", group = "client"}),

    -- Standard program
    awful.key({ env.mod, "Shift" }, "Return", function () awful.spawn(env.terminal) end,
              {description = "open a env.terminal", group = "launcher"}),
    awful.key({ env.mod, "Shift" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ env.mod, "Shift"   }, "e", function () awful.spawn("sh " .. env.scripts_folder .. "logout.sh") end,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ env.mod, "Control"   }, "l", function () awful.spawn("betterlockscreen -l") end,
              {description = "lock awesome", group = "awesome"}),

    awful.key({ env.mod, "Control" }, "-",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),
	awful.key({env.mod}, 			"d", function() awful.spawn("rofi -show") end,
			  {description = "rofi prompt", group = "launcher"}),

    --{{{Volume Control
    awful.key({},"XF86AudioLowerVolume",
        function()
            awful.spawn("amixer -q sset Master 5%-")
            volwidget.update()
        end,
    	{description = "Lower volume by 5%", group="client"}),
    awful.key({},"XF86AudioRaiseVolume",
        function()
            awful.spawn("amixer -q sset Master 5%+")
            volwidget.update()
        end,
    	{description = "Raise volume by 5%", group="client"}),
    awful.key({}, "XF86AudioMute",
        function()
            awful.spawn("amixer -q sset Master toggle")
            volwidget.update()
        end,
    	{description = "Mute audio", group="client"})
)

clientkeys = gears.table.join(
    awful.key({ env.mod,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
     awful.key({ env.mod, "Shift"   }, "q",      function (c) c:kill()                         end,
              {description = "close focused client", group = "client"}),
     awful.key({ env.mod, "Shift" }, "space",  awful.client.floating.toggle)                     ,
     
     awful.key({ env.mod,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
               {description = "increase master width factor", group = "layout"}),
     awful.key({ env.mod,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
               {description = "decrease master width factor", group = "layout"}),
     awful.key({ env.mod, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
               {description = "increase the number of master clients", group = "layout"}),
     awful.key({ env.mod, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
               {description = "decrease the number of master clients", group = "layout"}),
     awful.key({ env.mod, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
               {description = "increase the number of columns", group = "layout"}),
     awful.key({ env.mod, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
               {description = "decrease the number of columns", group = "layout"}),
     awful.key({ env.mod,           }, "space", function () awful.layout.inc( 1)                end,
          {description = "toggle floating", group = "client"}),
    awful.key({ env.mod, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),

    awful.key({ env.mod,           }, "-",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ env.mod,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c.ontop = not c.ontop
            c:raise()
        end ,
        {description = "(un)maximize", group = "tag"}),
    awful.key({ env.mod, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ env.mod, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)


----------------------------------{{{WORKSPACE KEYBINDS}}}----------------------------------

-- Bind all key function numbers to tags.
local FKEY = 66;
local curr = client.focus and client.focus.first_tag or nil
for i = 1, #root.tags() do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ env.mod }, "#" .. i + FKEY,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                            if tag then
                               tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ env.mod, "Control" }, "#" .. i + FKEY,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ env.mod, "Shift" }, "#" .. i + FKEY,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ env.mod, "Control", "Shift" }, "#" .. i + FKEY,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

----------------------------------{{{Mouse Buttons}}}----------------------------------
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ env.mod }, 1, awful.mouse.client.move),
    awful.button({ env.mod }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
----------------------------------{{{RULES}}}----------------------------------
local rules = require("modules.rules")
rules:enable()
----------------------------------{{{SIGNALS}}}----------------------------------
local signals = require("modules.signals")
    signals:listen({ env = env })

    -- Add a titlebar if titlebars_enabled is set to true in the rules.
    client.connect_signal("request::titlebars", function(c)
        -- buttons for the titlebar
        local buttons = gears.table.join(
            awful.button({ }, 1, function()
                client.focus = c
                c:raise()
                awful.mouse.client.move(c)
            end),
            awful.button({ }, 3, function()
                client.focus = c
                c:raise()
                awful.mouse.client.resize(c)
            end)
        )

        awful.titlebar(c):setup {
            { -- Left
                awful.titlebar.widget.iconwidget(c),
                buttons = buttons,
                layout  = wibox.layout.fixed.horizontal
            },
            { -- Middle
                { -- Title
                    align  = "center",
                    widget = awful.titlebar.widget.titlewidget(c)
                },
                buttons = buttons,
                layout  = wibox.layout.flex.horizontal
            },
            { -- Right
                awful.titlebar.widget.floatingbutton (c),
                awful.titlebar.widget.maximizedbutton(c),
                awful.titlebar.widget.stickybutton   (c),
                awful.titlebar.widget.ontopbutton    (c),
                awful.titlebar.widget.closebutton    (c),
                layout = wibox.layout.fixed.horizontal()
            },
            layout = wibox.layout.align.horizontal
        }
    end)
----------------------------------{{AUTOSTART}}----------------------------------
local autostart = require("modules.autostart")
if timestamp.is_startup() then
    autostart:run(env)
end
