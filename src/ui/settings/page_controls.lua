local page = {}

local bindindWindow = require("ui.settings.binding_window")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function()
                        pages:goToSettings()
                end,
        },
        {
                label = "APPLY",
                enabled = false,
                func = function() end,
        },
        {
                label = "CANCEL",
                enabled = false,
                func = function() end,
        },
}

function page.draw()
        ui.drawRectFilled(
                vec2(0, 0),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiColor1 / 1.1
        )

        cui.pushWindowFitted("settings_controls_main_window")
        topSubBar("/ Settings / Controls")

        cui.pushWindow(
                "settings_controls_window",
                0,
                200 * cui.scaleY(),
                ui.windowWidth(),
                ui.windowHeight() - 303 * cui.scaleY(),
                false
        )

        bindindWindow:draw()

        cui.popWindow()

        bottomBar(bottomBarButtons)
        cui.popWindow()
        return ""
end

return page
