
--Acquire environment
local awful = require("awful")
local beautiful = require("beautiful")

local rules = {}

-----------------------------------------------
-------{{Application Window Properites}}-------
-----------------------------------------------
-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).

rules.all_clients = {
    border_width = beautiful.border_width,
    border_color = beautiful.border_normal,
    keys = clientkeys,
    buttons = clientbuttons,
    focus = awful.client.focus.filter,
    raise = true,
    screen = awful.screen.preferred,
    placement = awful.placement.no_offscreen+awful.placement.no_overlap,
}


rules.notitlebar = {
    class = {
        "GLava",
    },
}

rules.floating_clients = {
    instance = {
      "DTA",  -- Firefox addon DownThemAll.
      "copyq",  -- Includes session name in class.
    },
    class = {
      "Arandr",
      "Gpick",
	  "Steam",
      "Kruler",
      "MessageWin",  -- kalarm.
      "Sxiv",
      "Wpa_gui",
      "pinentry",
      "veromix",
      "xtightvncviewer",
      "file_progress",
      "terminator"
    },
    type = {
        "dialog",
    },
    name = {
      "Event Tester",  -- xev.
      "sforzando (GUI)",
    },
    role = {
      "AlarmWindow",  -- Thunderbird's calendar.
      "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
      "toolbox_window", -- e.g. Dia's toolbox
    }
}

rules.nofloat = {
    name = {
        "MIDI take"
    }
}

rules.fullscreen = {
    class = {
        "edex-ui"
    }
}

rules.COMMS = {
    class = {
        "discord",
        "Android Messages",
        "teams-for-linux",
    }
}

rules.CREATE = {
    class = {
        "gimp-2.10",
        "Inkscape",
        "Natron",
        "Blender",
        "Krita",
--        "REAPER"
    }
}

rules.DEVELOP = {
    class = {
        "jetbrains-idea",
        "jetbrains-clion",
        "jetbrains-toolbox",
        "jetbrains-studio"
    }
}

rules.EDEX = {
    class = {
        "edex-ui"
    }
}

function rules:enable()
    self.rules = {
        {
            rule = {},
            properties = self.all_clients
        },
        {
            rule_any = self.floating_clients,
            --except_any = self.nofloat ,
            properties = { floating = true, ontop = true, placement = awful.placement.centered} 
        },
        {
            rule_any = rules.fullscreen,
            properties = { fullscreen = true}
        },
        {
            rule_any = rules.COMMS,
            properties = { tag = "COMMS" }
        },
        {
            rule_any = rules.CREATE,
            properties = { tag = "CREATE" }
        },
        {
            rule_any = rules.DEVELOP,
            properties = { tag = "DEVELOP" }
        },
        {
            rule_any = rules.EDEX,
            properties = { tag = "EDEX" }
        },
        {
            rule_any = { type = { "normal", "dialog" }},
            except_any = self.notitlebar ,
            properties = { titlebars_enabled = true }
        }
    }

-- Set rules
    awful.rules.rules = rules.rules
end

return rules
