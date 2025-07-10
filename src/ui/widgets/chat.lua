local cui = require("ui.cui")
local messages = require("messages")
local settings = require("settings")
local style = require("src.ui.style")
local sim = ac.getSim()

local chat = {
        autoScroll = true,
        emojisOpen = false,
}

local function logWindow(height)
        cui.pushWindow("chat_log_window", 0, 0, ui.windowWidth(), height, true)
        ui.pushTextWrapPosition(ui.windowWidth() * 0.93)

        local fontSize = style.main.font.body.size
        local chatLineSize = 24 * cui.scale()

        ui.setCursorY(5 * cui.scale())
        for i, line in ipairs(messages.log) do
                if line.sender == -1 then
                        ui.setCursorX(ui.windowWidth() * 0.01)
                        cui.snapCursor()
                        ui.dwriteTextWrapped(line.msg, fontSize, line.color)
                        ui.sameLine()
                        ui.setCursorX(0)
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                line.timestamp,
                                fontSize,
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth() * 0.98, chatLineSize * cui.scale()),
                                false,
                                rgbm.colors.gray
                        )
                else
                        ui.setCursorX(0)
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                line.timestamp,
                                fontSize,
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth() * 0.98, chatLineSize * cui.scale()),
                                false,
                                rgbm.colors.gray
                        )
                        ui.sameLine()

                        ui.setCursorX(ui.windowWidth() * 0.01)
                        cui.snapCursor()
                        ui.dwriteText("%s:" % ac.getDriverName(line.sender), fontSize, line.color)
                        ui.sameLine()
                        ui.offsetCursorX(5 * cui.scale())

                        local maxMessageLength = 80
                        local messageRepeat = math.ceil(#line.msg / maxMessageLength) - 1
                        local tempX = ui.getCursorX()
                        ui.dwriteText(string.sub(line.msg, 1, maxMessageLength), fontSize, line.color)

                        for j = 1, messageRepeat do
                                ui.setCursorX(tempX)
                                cui.snapCursor()
                                local messageBlock = j * maxMessageLength + 1
                                ui.dwriteTextAligned(
                                        string.format(
                                                "%s",
                                                string.sub(line.msg, messageBlock, messageBlock + maxMessageLength)
                                        ),
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(ui.windowWidth() * 0.98, chatLineSize * cui.scale()),
                                        false,
                                        line.color
                                )
                        end
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
        if not isempty(messages.input) and ui.keyPressed(ui.Key.Enter) and chatActive then
                ac.sendChatMessage(messages.input)
                messages.input = ""
        end

        cui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() - height)

        messages.input, chatActive = cui.inputText(
                "##chatInput",
                vec2(ui.windowWidth() * 0.75, height),
                "",
                messages.input,
                "",
                "Type message..."
        )
        ui.drawRect(
                vec2(3, ui.windowHeight() - height),
                ui.windowSize() - vec2(3, 0),
                settings.Appearance.uiColorPrimary * 2,
                6 * cui.scale(),
                ui.CornerFlags.All,
                2
        )

        ui.setCursorX(ui.windowWidth() * 0.75)
        ui.setCursorY(ui.windowHeight() - height)

        if
                cui.iconButton(
                        "##chatClearButton",
                        ui.Icons.Cancel,
                        height,
                        height,
                        isempty(messages.input) and ui.ButtonFlags.Disabled or ui.ButtonFlags.None,
                        false,
                        nil
                )
        then
                messages.input = ""
        end
        ui.sameLine()

        if chat.emojisOpen then
                local tempCursor = ui.getCursor()

                ui.setCursorX(ui.windowWidth() * 0.5)
                ui.setCursorY(0)
                cui.pushWindow(
                        "emoji_window",
                        ui.windowWidth() * 0.5,
                        0,
                        ui.windowWidth() * 0.5,
                        ui.windowHeight() - 40 * cui.scale(),
                        true
                )

                ui.drawRectFilled(
                        vec2(0, 0),
                        vec2(ui.windowWidth(), 2000 * cui.scale()),
                        settings.Appearance.uiColorBackground
                )
                ui.setCursorX(ui.windowWidth() * 0.02)
                ui.setCursorY(10 * cui.scale())
                ui.dwriteTextAligned(
                        "Emojis",
                        22 * cui.scale(),
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.98, 24 * cui.scale())
                )

                ui.setCursorY(38 * cui.scale())
                ui.setCursorX(ui.windowWidth() * 0.02)

                for i, emoji in ipairs(messages.emojiList) do
                        if i > 1 and (i - 1) % 10 == 0 then
                                ui.newLine()
                                ui.setCursorX(ui.windowWidth() * 0.02)
                        end

                        if
                                cui.emojiButton(
                                        "emoji" .. emoji.label,
                                        emoji.icon,
                                        38 * cui.scale(),
                                        38 * cui.scale(),
                                        ui.ButtonFlags.None,
                                        false
                                )
                        then
                                messages.input = messages.input .. emoji.icon
                        end
                        ui.sameLine()
                end

                ui.newLine()
                cui.dummy(19, 19)

                cui.popWindow(true)
                ui.setCursor(tempCursor)
        end

        if
                cui.iconButton(
                        "##chatEmojiButton",
                        ui.Icons.Smile,
                        height,
                        height,
                        ui.ButtonFlags.None,
                        false,
                        nil,
                        chat.emojisOpen
                )
        then
                chat.emojisOpen = not chat.emojisOpen
        end

        ui.sameLine()
        cui.iconButton(
                "##chatAttachmentButton",
                ui.Icons.Paperclip,
                height,
                height,
                ui.ButtonFlags.Disabled,
                false,
                nil
        )
        ui.sameLine()
        cui.iconButton("##chatGroupButton", ui.Icons.Group, height, height, ui.ButtonFlags.Disabled, false, nil)
        ui.sameLine()

        if
                cui.iconButton(
                        "##chatSendButton",
                        ui.Icons.Send,
                        height,
                        height,
                        isempty(messages.input) and ui.ButtonFlags.Disabled or ui.ButtonFlags.None,
                        false,
                        nil
                )
        then
                ac.sendChatMessage(messages.input)
                messages.input = ""
        end
end

function chat:draw(xPos, yPos, width, height)
        -- if not sim.isOnlineRace then return end

        local chatInputHeight = 40 * cui.scale()

        cui.pushWindow("chat_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorBackground, 6 * cui.scale())

        logWindow(height - chatInputHeight)
        chatInput(chatInputHeight)

        cui.popWindow()
end

return chat
