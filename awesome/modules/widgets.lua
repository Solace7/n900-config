local awful = require("awful")
local wibox = require("wibox")
local redflat = require("redflat")
local beautiful = require("beautiful")
local gears = require("gears.shape")

--Include plugins from lain library
local lain = require("lain")

local widgets = {}

-------------------------
-------{{WIDGETS}}-------
-------------------------

function widgets:init(args)
    local args = args or {}
    local env = args.env

    -- Separator Widget
    self.widgetseparator = wibox.widget.textbox(" | ")
    
    -- Keyboard map indicator and switcher
    self.mykeyboardlayout = awful.widget.keyboardlayout()
    
    -- Create a textclock widget
    self.mytextclock = wibox.widget.textclock("%H:%M:%S § %Y-%m-%d",1)

    self.monthcal = awful.widget.calendar_popup.month()
    self.monthcal:attach(self.mytextclock,"tm" ,{on_hover=false})
    
    -- CPU Governor Widget
    self.cpugovernor = awful.widget.watch('cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor', 60, function(widget, stdout)
        for line in stdout:gmatch("[^\r\n]+") do
            if line:match("performance") then 
                widget:set_image(env.themedir .. "/cpu-frequency-indicator-performance.svg")
            else if line:match("powersave") then
                widget:set_image(env.themedir .. "/cpu-frequency-indicator-powersave.svg")
                end
            end
            cpugov_t = awful.tooltip({
                objects = { cpugovernor },
                timer_function = function()
                    return line
                end,
            })
        end
    
    end, wibox.widget.imagebox())
    
    battimeleft = "NA"
    batpercent = "NA"
    
    self.battwidget = lain.widget.bat({
        settings = function()
            if(bat_now.perc < 25) then 
                widget:set_markup("  POW")
            else if(bat_now.perc < 50) then
                widget:set_markup("  POW")
            else
                widget:set_markup("  POW")
            end
            end
            if(bat_now.status == "Charging") then
                widget:set_markup("  CHRG")
                battimeleft = "Full in: " .. bat_now.time
            else
                battimeleft = "Time Left: " .. bat_now.time
            end
            batpercent = "Percent: " .. bat_now.perc .. "%"
            bat_notification_charged_preset = {
                title       = "Battery Charged",
                text        = "You can unplug the cable",
                timeout     = 10,
                bg          = "#282828",
                fg          = "#ebdbb2"
            }
    
            bat_notification_critical_preset = {
                fg = "#282828",
                bg = "#fb4934"
            }
        end
    })
    
    local bat_t = awful.tooltip({
        objects = { self.battwidget.widget },
        timer_function = function()
            return battimeleft .. "\n" .. batpercent
        end
    })
    
    --Systemtray widget
    self.systemtray = wibox.widget.systray()
    
    --{{Network widget
    local wifi_icon = wibox.widget.imagebox()
    local eth_icon = wibox.widget.imagebox()
    local nm = lain.widget.net({
            notify = "on",
            wifi_state = "on",
            eth_state = "on",
        settings = function()
            local eth0 = net_now.devices.enp0s31f6
            if eth0 then
                if eth0.ethernet then
                    eth_icon:set_image(env.icon_dir .. "/status/symbolic/network-wired-symbolic.svg")
                else
                    eth_icon:set_image()
                end
            end
            local wlan0 = net_now.devices["wlp2s0"]
            if wlan0 then
                if wlan0.wifi then
                    local signal = wlan0.signal
                    if signal < -83 then
                        wifi_icon:set_image(env.icon_dir .. "/status/symbolic/network-wireless-signal-weak-symbolic.svg")
                    elseif signal < -70 then
                        wifi_icon:set_image(env.icon_dir .. "/status/symbolic/network-wireless-signal-ok-symbolic.svg")
                    elseif signal < -53 then
                        wifi_icon:set_image(env.icon_dir .. "/status/symbolic/network-wireless-signal-good-symbolic.svg")
                    elseif signal >= -53 then
                        wifi_icon:set_image(env.icon_dir .. "/status/symbolic/network-wireless-signal-excellent-symbolic.svg")
                    else
                        wifi_icon:set_image(env.icon_dir .. "/status/symbolic/network-wireless-offline-symbolic.svg")
                    end
                else
                    wifi_icon:set_image(env.icon_dir .. "/status/symbolic/network-wireless-offline-symbolic.svg")
                end
            end
        end
    })
    self.wifi_icon = wifi_icon
    self.eth_icon = eth_icon

    wifi_icon:buttons(awful.util.table.join(
        awful.button({}, 1, function() awful.spawn.with_shell("networkmanager_dmenu") end)))
    eth_icon:buttons(awful.util.table.join(
        awful.button({}, 1, function() awful.spawn.with_shell("networkmanager_dmenu") end)))
     
--[[    self.watchpacman = wibox.widget.imagebox()
    
    local paccheck = awful.widget.watch('pacman -Qu | grep -v ignored | wc -l ', 60, function(widget, stdout)
            if tonumber(stdout) > 0 then 
                awful.spawn("notify-send 'There are '" .. line .. "' package(s) to be upgraded ' ")
                watchpacman:set_image(env.icon_dir .. "/apps/symbolic/aptdaemon-upgrade-symbolic.svg")
            else
                awful.spawn("notify-send 'all good' ")
                watchpacman:set_image(env.icon_dir .. "/status/symbolic/software-update-available-symbolic.svg")
            end
            watchpacman_t = awful.tooltip({
                objects = { self.watchpacman },
                timer_function = function()
                    return stdout
                end,
            })
    end)]]--
    
    --MPD Widget
    local mpd = lain.widget.mpd({
--         host = "~/.config/mpd/socket",
         music_dir = "~/Music/My Music",
         timeout = 1,
         followtag = true,
    settings = function ()
            local elapsed = mpd_now.elapsed
            local duration = mpd_now.time
            if mpd_now.state == "play" then
                    widget:set_markup( mpd_now.title .. " - " .. mpd_now.artist .. " ")
            elseif mpd_now.state == "pause" then
                widget:set_markup("MPD PAUSED ")                
            else
                widget:set_markup("MPD OFFLINE ")
            end
        mpd_notification_preset = {
            title = "Now Playing",
            timeout = 6,
            text = string.format("%s | (%s) \n%s", mpd_now.artist, mpd_now.album, mpd_now.title)
        }
        end
    })
    
    self.mpdwidget = wibox.container.background(mpd.widget)
--[[    self.mpdwidget:buttons(awful.util.table.join(
        awful.button({}, 1, function() awful.spawn.with_shell("terminator -l Music") end)))]]--
    
    --Volume widget
    self.volume = lain.widget.alsa({
        cmd = "amixer -c 0",
        settings = function()
            widget:set_markup(" " .. volume_now.level .. " ")
        end
    })
 
    --Temperature widget
    self.tempwidget = lain.widget.temp({
        settings = function()
            if coretemp_now > 60 then
                widget:set_markup('<span color="#FB4934">' .. coretemp_now .. "°C" .. '</span>')
            else 
                widget:set_markup(coretemp_now .. "°C")
            end
        end
    })
    
        -- We need one layoutbox per screen.
    end
return widgets
