local page = {}

local configs = require("configs")
local controllerTweaks = require("controller_tweaks")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")

local bottomBarButtons = {
        {
                label = "BACK",
                enabled = true,
                func = function() pages:undo() end,
        },
}

local WidgetWindow = require("classes.WidgetWindow")

local bindingWindow = WidgetWindow("binding_window")
bindingWindow:addWidget("Bindings", require("ui.widgets.control_bindings"))

local tweaksWidget = require("ui.widgets.control_tweaks")
local tweaksWindow = WidgetWindow("tweaks_window")
for i, tab in ipairs(controllerTweaks[configs.CONTROLS.ini:get("HEADER", "INPUT_METHOD", "WHEEL")]) do
        tweaksWindow:addWidget(tab.label, tweaksWidget)
end

function page.draw()
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.75)

        cui.pushFittedWindow("settings_controls_main_window")
        topSubBar("Controls")

        bindingWindow:setPosition(0, 180 * cui.scale())
        bindingWindow:setSize(ui.windowWidth() * 0.7 - 7.5 * cui.scale(), ui.windowHeight() - 303 * cui.scale())
        bindingWindow:draw()

        tweaksWindow:setPosition(ui.windowWidth() * 0.7 + 7.5 * cui.scale(), 180 * cui.scale())
        tweaksWindow:setSize(ui.windowWidth() * 0.3 - 7.5 * cui.scale(), ui.windowHeight() - 303 * cui.scale())
        tweaksWindow:draw()
        tweaksWidget.section = tweaksWindow.activeWidgetIndex

        bottomBar(bottomBarButtons)
        cui.popWindow()

        return "finalize"
end

return page
