local settings = {
        General = {
                {
                        key = "hideOtherTrackSetups",
                        label = "Hide Other Track Setups",
                        default = false,
                        widget = 1,
                },
                { key = "autoStart", label = "Auto-Start new UI", default = true, widget = 1 },
                {
                        key = "scrollDelayTimeMs",
                        label = "Scroll Delay Time",
                        default = 25,
                        min = 10,
                        max = 100,
                        format = "%.0f ms",
                        widget = 2,
                },
                { key = "showConfirmDialogs", label = "Show Confirmation Dialogs", default = true, widget = 1 },
                { key = "showVersions", label = "Show App and CSP versions", default = true, widget = 1 },
                { key = "defaultSetupPage", label = "Open Setup Page on Startup", default = false, widget = 1 },
                {
                        key = "autoLoadLastSetup",
                        label = "Load Last Setup on Startup",
                        default = true,
                        widget = 1,
                },
                { key = "developerMode", label = "Developer Mode", default = false, widget = 1 },
        },
        Appearance = {
                { key = "uiThemeColor1", label = "Primay UI Color", default = rgbm.new("#3e3c46"), widget = 1 },
                {
                        key = "uiThemeColor2",
                        label = "Secondary UI Color",
                        default = rgbm(0.92, 0.08, 0.12, 1),
                        widget = 1,
                },
                { key = "uiThemeColor3", label = "Tertiary UI Color", default = rgbm(1, 1, 1, 1), widget = 1 },
        },
}

local db = require("database")

for category, settingsTable in pairs(settings) do
        db:register(category, settingsTable)

        setmetatable(settings[category], {
                __index = function(_, key) return db:get(category, key) end,
                __newindex = function(_, key, value) db:set(category, key, value) end,
        })
end

return settings
