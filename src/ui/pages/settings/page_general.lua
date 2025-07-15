local page = { tab = 1 }

local app = require("app")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")

local WindowWidget = require("classes.WidgetWindow")

local generalSettingsWindow = WindowWidget("settings_general")

generalSettingsWindow:addWidget("General", require("ui.widgets.settings_general"))
generalSettingsWindow:addWidget("UI", require("ui.widgets.settings_ui"))

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:undo() end,
        },
}

function page.draw()
        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.75)

        cui.pushFittedWindow("general_page_window")

        topSubBar(app.name)

        generalSettingsWindow:setPosition(ui.windowWidth() * 0.25, 180 * cui.scale())
        generalSettingsWindow:setSize(ui.windowWidth() * 0.5, ui.windowHeight() - 303 * cui.scale())
        generalSettingsWindow:draw()

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return "finalize"
end

return page
