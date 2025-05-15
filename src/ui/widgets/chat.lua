local cui = require("ui.cui")
local settings = require("settings")

local chat = {
        log = {
                -- { sender = -1, msg = "THIS SERVER IS FOR CUCKOLDS ONLY!!!!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "NON CUCKS NEED TO LEAVE RIGHT NOW!" },
                -- { sender = -1, msg = "HERE!" },
        },
        inputMessage = "",
        autoScroll = true,
}

ac.onChatMessage(function(message, senderCarIndex, senderSessionID)
        local chatColor = rgbm.colors.white

        if senderCarIndex == 0 then
                chatColor = rgbm.colors.yellow
        elseif senderCarIndex == -1 then
                chatColor = rgbm.colors.orange
        else
                local tags = ac.DriverTags(ac.getDriverName(senderCarIndex))
                if tags.friend then chatColor = rgbm.colors.green end
        end

        table.insert(chat.log, { sender = senderCarIndex, msg = message, color = chatColor })
end)

local function logWindow(height)
        cui.pushWindow("chat_log_window", 0, 0, ui.windowWidth(), height, true)

        for i, line in ipairs(chat.log) do
                if line.sender == -1 then
                        ui.dwriteText(line.msg, 18 * cui.uiScale(), rgbm.colors.orange)
                else
                        ui.dwriteText(
                                string.format("%s: %s", ac.getDriverName(line.sender), line.msg),
                                18 * cui.uiScale(),
                                line.color
                        )
                end
        end
        ui.newLine()

        if ui.mouseWheel() ~= 0 then
                if ui.getScrollY() ~= ui.getScrollMaxY() then chat.autoScroll = false end
        elseif ui.getScrollY() == ui.getScrollMaxY() then
                chat.autoScroll = true
        end

        if chat.autoScroll then ui.setScrollY(ui.getScrollMaxY()) end

        cui.popWindow()
end

local function chatInput(height)
        if chat.inputMessage ~= "" and ui.keyPressed(ui.Key.Enter) then
                ac.sendChatMessage(chat.inputMessage)
                chat.inputMessage = ""
        end

        cui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() - height)
        chat.inputMessage = cui.inputText("##chatInput", ">", chat.inputMessage, "", vec2(ui.windowWidth(), height))
end

function chat:draw(xPos, yPos, width, height)
        if true then return end

        local chatInputHeight = 50 * cui.uiScale()

        cui.pushWindow("chat_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiColor1)

        logWindow(height - chatInputHeight)
        chatInput(chatInputHeight)

        cui.popWindow()
end

return chat
