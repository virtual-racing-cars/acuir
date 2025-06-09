local page = {}

local bindindWindow = require("ui.pages.settings.binding_window")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:goToSettings() end,
        },
}

function page.draw()
        cui.pushWindowFitted("settings_controls_main_window")
        topSubBar("/ Settings / Controls")

        cui.pushWindow(
                "settings_controls_window",
                0,
                180 * cui.uiScale(),
                ui.windowWidth(),
                ui.windowHeight() - 303 * cui.uiScale(),
                false
        )

        bindindWindow:draw()

        cui.popWindow()

        bottomBar(bottomBarButtons)
        cui.popWindow()
        return ""
end

return page
