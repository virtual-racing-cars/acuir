local cui = require("ui.cui")
local settings = require("settings")

local chat = {}

function chat:draw(xPos, yPos, width, height)
        local chatInputHeight = 50 * cui.scaleY()

        cui.pushWindow("chat_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiColor1)

        cui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() - chatInputHeight)
        cui.inputText(
                "##SetupName",
                ">",
                " Hello there",
                ui.InputTextFlags.None,
                vec2(ui.windowWidth(), chatInputHeight)
        )

        cui.popWindow()
end

return chat
