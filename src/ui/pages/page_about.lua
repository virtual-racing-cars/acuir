local WidgetWindow = require("classes.WidgetWindow")
local cui = require("ui.cui")

local aboutWindow = WidgetWindow("about_window")
aboutWindow:addWidget("About", require("ui.widgets.about"))

local sim = ac.getSim()

local page = {}

function page.update() end

function page.draw()
        aboutWindow:setSize(ui.windowWidth() * 0.5 - 7.5 * cui.scale(), ui.windowHeight() - 255 * cui.scale())
        aboutWindow:setPosition(0, 0)
        aboutWindow:draw()

        bottomWidgetBar()

        return "finalize"
end

return page
