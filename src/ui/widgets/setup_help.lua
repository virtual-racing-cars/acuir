local cui = require("ui.cui")
local settings = require("settings")
local style = require("ui.style")

local setupHelpWidget = {}

function setupHelpWidget.body()
        if sm.activeHelpString == "" then return end

        cui.setCursorY(10)
        cui.setCursorX(15)
        ui.pushTextWrapPosition(ui.windowWidth() - 15 * cui.scale())
        cui.snapCursor()
        ui.dwriteText(sm.activeHelpString, style.main.font.body.size)

        ui.popTextWrapPosition()
end

return setupHelpWidget
