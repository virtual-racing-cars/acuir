local settings = {
        General = {
                {
                        key = "hideOtherTrackSetups",
                        label = "Hide Other Track Setups",
                        default = false,
                        widget = 1,
                },
                { key = "autoStart", label = "Auto-Start new UI", default = true, widget = 1 },
                { key = "showConfirmDialogs", label = "Show Confirmation Dialogs", default = true, widget = 1 },
                { key = "showVersions", label = "Show App and CSP versions", default = true, widget = 1 },
                { key = "developerMode", label = "Developer Mode", default = false, widget = 1 },
                { key = "defaultSetupPage", label = "Open Setup Page on Startup", default = false, widget = 1 },
        },
        Appearance = {
                { key = "uiColor1", label = "Primay UI Color", default = rgbm.new("#3e3c46"), widget = 1 },
                { key = "uiColor2", label = "Secondary UI Color", default = rgbm(1, 0, 0, 1), widget = 1 },
                { key = "uiColor3", label = "Tertiary UI Color", default = rgbm(1, 1, 1, 1), widget = 1 },
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
