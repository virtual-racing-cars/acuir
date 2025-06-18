local cui = require("src.ui.cui")

local page = {}

local telemetryViewer = require("src.ui.widgets.telemetry_viewer")

function page:draw(dt)
        ui.setCursor(0)

        cui.pushContentWindow("telemetry_main_window", 0, 0, ui.windowWidth(), ui.windowHeight(), function()
                ui.setCursor(0)
                if cui.windowTabButton("Telemetry", 36, ui.ButtonFlags.None, false) then
                end
        end, function() telemetryViewer:drawFooter() end)

        telemetryViewer:draw(0, 0, ui.windowWidth(), ui.windowHeight())

        cui.popContentWindow()

        return ""
end

return page
