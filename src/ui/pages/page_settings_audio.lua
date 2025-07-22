local WidgetWindow = require("classes.WidgetWindow")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")

local page = {}

local audioWindow = WidgetWindow("audio")
audioWindow:addWidget("Audio", require("ui.widgets.audio_levels"))

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:undo() end,
        },
}

function page.draw()
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.75)

        cui.pushFittedWindow("settings_audio_main_window")
        topSubBar("Audio")

        audioWindow:setPosition(ui.windowWidth() * 0.25, 180 * cui.scale())
        audioWindow:setSize(ui.windowWidth() * 0.5, ui.windowHeight() - 303 * cui.scale())
        audioWindow:draw()

        bottomBar(bottomBarButtons)

        cui.popWindow()

        return "finalize"
end

return page
