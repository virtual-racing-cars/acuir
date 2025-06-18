local Widgets = {
        Checkbox = 1,
        Slider = 2,
}

local settings = {
        General = {

                { key = "autoStart", label = "Auto-Start new UI", default = true, widget = Widgets.Checkbox },
                {
                        key = "hideOtherTrackSetups",
                        label = "Hide Other Track Setups",
                        default = false,
                        widget = Widgets.Checkbox,
                },
                {
                        key = "sortTrackSetupsAZ",
                        label = "Sort Track Setups A-Z",
                        default = false,
                        widget = Widgets.Checkbox,
                },
                {
                        key = "defaultSetupPage",
                        label = "Open Garage on Startup",
                        default = false,
                        widget = Widgets.Checkbox,
                },
                {
                        key = "autoLoadLastSetup",
                        label = "Load Last Setup on Startup",
                        default = true,
                        widget = Widgets.Checkbox,
                },
                { key = "developerMode", label = "Developer Mode", default = false, widget = Widgets.Checkbox },
        },
        UI = {
                {
                        key = "scrollDelayTimeMs",
                        label = "Scroll Delay Time",
                        default = 25,
                        min = 10,
                        max = 100,
                        format = "%.0f ms",
                        widget = Widgets.Slider,
                },
                {
                        key = "showConfirmDialogs",
                        label = "Show Confirmation Dialogs",
                        default = true,
                        widget = Widgets.Checkbox,
                },
                {
                        key = "showVersions",
                        label = "Show App and CSP versions",
                        default = true,
                        widget = Widgets.Checkbox,
                },
        },
        Appearance = {
                {
                        key = "uiColorBackground",
                        label = "Background Color",
                        default = rgbm(0.12, 0.12, 0.14, 1),
                        widget = 1,
                },
                {
                        key = "uiColorBackgroundShade",
                        label = "Background Shade Color",
                        default = rgbm(0.15, 0.15, 0.17, 1),
                        widget = 1,
                },
                { key = "uiColorText", label = "Text Color", default = rgbm.colors.white, widget = 1 },
                { key = "uiColorTextDim", label = "Text Dim Color", default = rgbm.new("#707070"), widget = 1 },
                { key = "uiColorPrimary", label = "Primay Color", default = rgbm.new("#3e3c46"), widget = 1 },
                {
                        key = "uiColorPrimaryShade",
                        label = "Primay Shade Color",
                        default = rgbm.new("#5c5966"),
                        widget = 1,
                },
                {
                        key = "uiColorSecondary",
                        label = "Secondary Color",
                        default = rgbm.new("#EB141F"),
                        widget = 1,
                },
                {
                        key = "uiColorSecondaryShade",
                        label = "Secondary Shade Color",
                        default = rgbm.new("#f3535b"),
                        widget = 1,
                },
                { key = "uiColorAccent", label = "Accent Color", default = rgbm.colors.white, widget = 1 },
                { key = "uiColorError", label = "Error Color", default = rgbm.colors.red, widget = 1 },
                { key = "uiColorSuccess", label = "Success Color", default = rgbm.colors.green, widget = 1 },
                { key = "uiColorRed", label = "Red Color", default = rgbm.colors.red, widget = 1 },
                { key = "uiColorPurple", label = "Purple Color", default = rgbm.colors.red, widget = 1 },
                { key = "uiColorOrange", label = "Orange Color", default = rgbm.colors.orange, widget = 1 },
                { key = "uiColorBlue", label = "Blue Color", default = rgbm.colors.blue, widget = 1 },
                { key = "uiColorGreen", label = "Green Color", default = rgbm.colors.green, widget = 1 },
                { key = "uiColorYellow", label = "Yellow Color", default = rgbm.colors.yellow, widget = 1 },
                { key = "uiColorGold", label = "Gold Color", default = rgbm.colors.yellow, widget = 1 },
                { key = "uiColorSilver", label = "Silver Color", default = rgbm.colors.yellow, widget = 1 },
                { key = "uiColorBronze", label = "Bronze Color", default = rgbm.colors.yellow, widget = 1 },
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
