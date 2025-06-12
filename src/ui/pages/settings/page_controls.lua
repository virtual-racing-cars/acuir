local page = {}

local bindindWindow = require("ui.pages.settings.controls.bindings")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local tweaksWindow = require("ui.pages.settings.controls.tweaks")

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:undo() end,
        },
}

function page.draw()
        topSubBar("Controls")
        cui.pushWindowFitted("settings_controls_main_window")

        cui.pushWindow(
                "settings_controls_window",
                0,
                180 * cui.uiScale(),
                ui.windowWidth(),
                ui.windowHeight() - 303 * cui.uiScale(),
                false
        )

        bindindWindow:draw()
        tweaksWindow:draw()

        cui.popWindow()

        bottomBar(bottomBarButtons)
        cui.popWindow()
        return ""
end

return page
