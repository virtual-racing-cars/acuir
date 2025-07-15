local page = {}

local WidgetWindow = require("classes.WidgetWindow")

local telemetryWindow = WidgetWindow("telemetry")
telemetryWindow:addWidget("Telemetry", require("ui.widgets.telemetry_viewer"))

function page:draw(dt)
        telemetryWindow:setPosition(0, 0)
        telemetryWindow:setSize(ui.windowWidth(), ui.windowHeight())
        telemetryWindow:draw()

        return "finalize"
end

return page
