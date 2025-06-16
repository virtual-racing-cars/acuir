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
        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.75)

        cui.pushWindowFitted("settings_controls_main_window")
        topSubBar("Controls")

        cui.pushContentWindow(
                "settings_controls_window",
                0,
                180 * cui.uiScale(),
                ui.windowWidth() * 0.7 - 7.5 * cui.uiScale(),
                ui.windowHeight() - 303 * cui.uiScale(),
                function() bindindWindow:drawHeader() end,
                nil,
                true
        )

        bindindWindow:draw()
        cui.popContentWindow()

        cui.pushContentWindow(
                "settings_controls_window_tweaks",
                ui.windowWidth() * 0.7 + 7.5 * cui.uiScale(),
                180 * cui.uiScale(),
                ui.windowWidth() * 0.3 - 7.5 * cui.uiScale(),
                ui.windowHeight() - 303 * cui.uiScale(),
                function() tweaksWindow:drawHeader() end,
                nil,
                true
        )

        tweaksWindow:draw()

        cui.popContentWindow()

        bottomBar(bottomBarButtons)
        cui.popWindow()
        return ""
end

return page
