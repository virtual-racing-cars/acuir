local page = {}

local bindindWindow = require("ui.pages.settings.controls.bindings")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")
local tweaksWindow = require("ui.pages.settings.controls.tweaks")

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:undo() end,
        },
}

function page.draw()
        ui.drawRectFilled(
                vec2(0, 0),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiColorPrimary / 1.1
        )

        cui.pushWindowFitted("settings_controls_main_window")
        topSubBar("Controls")

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
