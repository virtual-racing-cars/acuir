local page = {}

local telemetryViewer = require("src.ui.widgets.telemetry_viewer")

function page:draw(dt)
        ui.setCursor(0)

        telemetryViewer:draw(0, 0, ui.windowWidth(), ui.windowHeight())

        return ""
end

return page
