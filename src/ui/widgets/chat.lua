local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()

local chat = {
        log = {},
        inputMessage = "",
        autoScroll = true,
        emojisOpen = false,
}

local emojiList = {
        { label = "grin_face", icon = "😄" },
        { label = "grin_sweat_face", icon = "😅" },
        { label = "grin_tears_joy_face", icon = "😂" },
        { label = "upsidedown_face", icon = "🙃" },
        { label = "melting_face", icon = "🫠" },
        { label = "winking_face", icon = "😉" },
        { label = "smiling_face_halo", icon = "😇" },
        { label = "smiling_face_hearts", icon = "🥰" },
        { label = "smiling_face_heart_eyes", icon = "😍" },
        { label = "smiling_face_star_eyes", icon = "🤩" },
        { label = "face_blow_kiss", icon = "😘" },
        { label = "smiling_face_tear", icon = "🥲" },
        { label = "face_zany", icon = "🤪" },
        { label = "face_hand_over_mouth", icon = "🫢" },
        { label = "face_shush", icon = "🤫" },
        { label = "face_thinking", icon = "🤔" },
        { label = "face_salute", icon = "🫡" },
        { label = "face_neutral", icon = "😐" },
        { label = "face_expressionless", icon = "😑" },
        { label = "face_eye_roll", icon = "🙄" },
        { label = "face_hot", icon = "🥵" },
        { label = "face_cold", icon = "🥶" },
        { label = "face_eyes_crossed_out", icon = "😵" },
        { label = "exploding_head", icon = "🤯" },
        { label = "face_cowboy_hat", icon = "🤠" },
        { label = "face_partying", icon = "🥳" },
        { label = "face_sunglasses", icon = "😎" },
        { label = "face_nerd", icon = "🤓" },
        { label = "face_monocle", icon = "🧐" },
        { label = "face_pleading", icon = "🥺" },
        { label = "face_steam_nose", icon = "😤" },
        { label = "face_enraged", icon = "😡" },
        { label = "face_enraged_symbols", icon = "🤬" },
        { label = "face_angry", icon = "😠" },
        { label = "face_smiling_horns", icon = "😈" },
        { label = "face_angry_horns", icon = "👿" },
        { label = "skull", icon = "💀" },
        { label = "pile_of_poop", icon = "💩" },
        { label = "clown", icon = "🤡" },
        { label = "ogre", icon = "👹" },
        { label = "goblin", icon = "👺" },
        { label = "ghost", icon = "👻" },
        { label = "alien", icon = "👽" },
        { label = "alien_monster", icon = "👾" },
        { label = "robot", icon = "🤖" },
        { label = "monkey_see_no_evil", icon = "🙈" },
        { label = "monkey_hear_no_evil", icon = "🙉" },
        { label = "monkey_speak_no_evil", icon = "🙊" },
}

ac.onOnlineWelcome(function(message, config)
        if isempty(message) then return end

        table.insert(chat.log, {
                sender = -1,
                msg = message,
                color = rgbm.colors.orange,
                timestamp = "",
        })
end)

ac.onChatMessage(function(message, senderCarIndex, senderSessionID)
        if isempty(message) then return end

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
                        msg = string.format(
                                "%s joined, driving the %s",
                                ac.getDriverName(connectedCarIndex),
                                ac.getCarName(connectedCarIndex)
                        ),
                        color = rgbm.colors.gray,
                        timestamp = os.date("%H:%M", os.time()),
                })
        end
)

ac.onClientDisconnected(
        function(connectedCarIndex, connectedSessionID)
                table.insert(chat.log, {
                        sender = -1,
                        msg = string.format(
                                "%s left, the %s is now free",
                                ac.getDriverName(connectedCarIndex),
                                ac.getCarName(connectedCarIndex)
                        ),
                        color = rgbm.colors.gray,
                        timestamp = os.date("%H:%M", os.time()),
                })
        end
)

local function logWindow(height)
        cui.pushWindow("chat_log_window", 0, 0, ui.windowWidth(), height, true)
        ui.pushTextWrapPosition(ui.windowWidth() * 0.93)

        local fontSize = 18 * cui.uiScale()
        local chatLineSize = 24 * cui.uiScale()

        ui.setCursorY(5 * cui.uiScale())
        for i, line in ipairs(chat.log) do
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
                                vec2(ui.windowWidth() * 0.98, chatLineSize * cui.uiScale()),
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
                                vec2(ui.windowWidth() * 0.98, chatLineSize * cui.uiScale()),
                                false,
                                rgbm.colors.gray
                        )
                        ui.sameLine()

                        ui.setCursorX(ui.windowWidth() * 0.01)
                        cui.snapCursor()
                        ui.dwriteText("%s:" % ac.getDriverName(line.sender), fontSize, line.color)
                        ui.sameLine()
                        ui.offsetCursorX(5 * cui.uiScale())

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
                                        vec2(ui.windowWidth() * 0.98, chatLineSize * cui.uiScale()),
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

        ui.setCursorX(ui.windowWidth() * 0.75)
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

        if chat.emojisOpen then
                local tempCursor = ui.getCursor()

                ui.setCursorX(ui.windowWidth() * 0.5)
                ui.setCursorY(0)
                cui.pushWindow(
                        "emoji_window",
                        ui.windowWidth() * 0.5,
                        0,
                        ui.windowWidth() * 0.5,
                        ui.windowHeight() - 40 * cui.uiScale(),
                        true
                )

                ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), 2000 * cui.uiScale()), rgbm.colors.black)
                ui.setCursorX(ui.windowWidth() * 0.02)
                ui.setCursorY(10 * cui.uiScale())
                ui.dwriteTextAligned(
                        "Emojis",
                        22 * cui.uiScale(),
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(ui.windowWidth() * 0.98, 24 * cui.uiScale())
                )

                ui.setCursorY(38 * cui.uiScale())
                ui.setCursorX(ui.windowWidth() * 0.02)

                for i, emoji in ipairs(emojiList) do
                        if i > 1 and (i - 1) % 10 == 0 then
                                ui.newLine()
                                ui.setCursorX(ui.windowWidth() * 0.02)
                        end

                        if
                                cui.emojiButton(
                                        "emoji" .. emoji.label,
                                        emoji.icon,
                                        38 * cui.uiScale(),
                                        38 * cui.uiScale(),
                                        ui.ButtonFlags.None,
                                        false
                                )
                        then
                                chat.inputMessage = chat.inputMessage .. emoji.icon
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
                        1,
                        chat.emojisOpen
                )
        then
                chat.emojisOpen = not chat.emojisOpen
        end

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
        cui.snapCursor()
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
