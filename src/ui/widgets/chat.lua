local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()

local chat = {
        log = {

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

ac.onOnlineWelcome(
        function(message, config)
                table.insert(chat.log, {
                        sender = -1,
                        msg = message,
                        color = rgbm.colors.orange,
                        timestamp = "",
                })
        end
)

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

        local msgBlocks = string.split(message, "\n")

        for i, msg in ipairs(msgBlocks) do
                table.insert(chat.log, {
                        sender = senderCarIndex,
                        msg = msg,
                        color = chatColor,
                        timestamp = i == 1 and os.date("%H:%M", os.time()) or "",
                })
        end
end)

ac.onClientConnected(
        function(connectedCarIndex, connectedSessionID)
                table.insert(chat.log, {
                        sender = -1,
                        msg = ac.getDriverName(connectedCarIndex) .. " joined",
                        color = rgbm.colors.gray,
                        timestamp = os.date("%H:%M", os.time()),
                })
        end
)

ac.onClientDisconnected(
        function(connectedCarIndex, connectedSessionID)
                table.insert(chat.log, {
                        sender = -1,
                        msg = ac.getDriverName(connectedCarIndex) .. " left",
                        color = rgbm.colors.gray,
                        timestamp = os.date("%H:%M", os.time()),
                })
        end
)

local function logWindow(height)
        cui.pushWindow("chat_log_window", 0, 0, ui.windowWidth(), height, true)
        ui.pushTextWrapPosition(ui.windowWidth() * 0.93)

        ui.setCursorY(0)
        for i, line in ipairs(chat.log) do
                ui.setCursorX(ui.windowWidth() * 0.01)

                if line.sender == -1 then
                        ui.dwriteTextWrapped(line.msg, 18 * cui.uiScale(), line.color)
                        ui.sameLine()
                        ui.setCursorX(0)
                        ui.dwriteTextAligned(
                                line.timestamp,
                                18 * cui.uiScale(),
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth() * 0.98, 24 * cui.uiScale()),
                                false,
                                rgbm.colors.gray
                        )
                else
                        ui.dwriteTextAligned(
                                string.format("%s: %s", ac.getDriverName(line.sender), line.msg),
                                18 * cui.uiScale(),
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth() * 0.98, 24 * cui.uiScale()),
                                false,
                                line.color
                        )
                        ui.sameLine()
                        ui.setCursorX(0)
                        ui.dwriteTextAligned(
                                line.timestamp,
                                18 * cui.uiScale(),
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth() * 0.98, 24 * cui.uiScale()),
                                false,
                                rgbm.colors.gray
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

        ui.popTextWrapPosition()
        cui.popWindow()
end

local chatActive = false

local function chatInput(height)
        if not isempty(chat.inputMessage) and ui.keyPressed(ui.Key.Enter) and chatActive then
                ac.sendChatMessage(chat.inputMessage)
                chat.inputMessage = ""
        end

        cui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() - height)

        chat.inputMessage, chatActive =
                cui.inputText("##chatInput", "", chat.inputMessage, "", vec2(ui.windowWidth() * 0.75, height))
        ui.drawRect(
                vec2(0, ui.windowHeight() - height),
                ui.windowSize(),
                settings.Appearance.uiThemeColor1 * 2,
                0,
                ui.CornerFlags.None,
                2
        )

        cui.setCursorX(ui.windowWidth() * 0.75)
        ui.setCursorY(ui.windowHeight() - height)

        if
                cui.iconButton(
                        "##chatClearButton",
                        ui.Icons.Cancel,
                        height,
                        height,
                        isempty(chat.inputMessage) and ui.ButtonFlags.Disabled or ui.ButtonFlags.None,
                        false,
                        1
                )
        then
                chat.inputMessage = ""
        end
        ui.sameLine()
        cui.iconButton("##chatEmojiButton", ui.Icons.Smile, height, height, ui.ButtonFlags.Disabled, false, 1)
        ui.sameLine()
        cui.iconButton("##chatAttachmentButton", ui.Icons.Paperclip, height, height, ui.ButtonFlags.Disabled, false, 1)
        ui.sameLine()
        cui.iconButton("##chatGroupButton", ui.Icons.Group, height, height, ui.ButtonFlags.Disabled, false, 1)
        ui.sameLine()

        if
                cui.iconButton(
                        "##chatSendButton",
                        ui.Icons.Send,
                        height,
                        height,
                        isempty(chat.inputMessage) and ui.ButtonFlags.Disabled or ui.ButtonFlags.None,
                        false,
                        1
                )
        then
                ac.sendChatMessage(chat.inputMessage)
                chat.inputMessage = ""
        end

        ui.setCursorX(ui.windowWidth() * 0.01)
        ui.setCursorY(ui.windowHeight() - height)
        ui.dwriteTextAligned(
                isempty(chat.inputMessage) and "Type message..." or "",
                math.floor(height * 0.55),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() * 0.75, height),
                false,
                rgbm.colors.gray
        )
end

function chat:draw(xPos, yPos, width, height)
        if not sim.isOnlineRace then return end

        local chatInputHeight = 40 * cui.uiScale()

        cui.pushWindow("chat_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiThemeColor1)

        logWindow(height - chatInputHeight)
        chatInput(chatInputHeight)

        cui.popWindow()
end

return chat
