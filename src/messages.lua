local settings = require("settings")

local messages = {
        log = {},
        input = "",
        emojiList = {
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
        },
}

ac.onOnlineWelcome(function(message, config)
        if isempty(message) then return end

        table.insert(messages.log, 1, {
                sender = -1,
                msg = message,
                color = settings.Appearance.uiColorOrange,
                timestamp = "",
        })
end)

ac.onChatMessage(function(message, senderCarIndex, senderSessionID)
        if isempty(message) then return end

        local chatColor = settings.Appearance.uiColorText

        if senderCarIndex == 0 then
                chatColor = settings.Appearance.uiColorYellow
        elseif senderCarIndex == -1 then
                chatColor = settings.Appearance.uiColorOrange
        else
                if ac.DriverTags(ac.getDriverName(senderCarIndex)).friend then
                        chatColor = settings.Appearance.uiColorGreen
                end
        end

        local msgBlocks = string.split(message, "\n")

        for i, msg in ipairs(msgBlocks) do
                table.insert(messages.log, {
                        sender = senderCarIndex,
                        msg = msg,
                        color = chatColor,
                        timestamp = i == 1 and os.date("%H:%M", os.time()) or "",
                })
        end
end)

ac.onClientConnected(
        function(connectedCarIndex, connectedSessionID)
                table.insert(messages.log, {
                        sender = -1,
                        msg = string.format(
                                "%s joined, driving the %s",
                                ac.getDriverName(connectedCarIndex),
                                ac.getCarName(connectedCarIndex)
                        ),
                        color = settings.Appearance.uiColorTextDim,
                        timestamp = os.date("%H:%M", os.time()),
                })
        end
)

ac.onClientDisconnected(
        function(connectedCarIndex, connectedSessionID)
                table.insert(messages.log, {
                        sender = -1,
                        msg = string.format(
                                "%s left, the %s is now free",
                                ac.getDriverName(connectedCarIndex),
                                ac.getCarName(connectedCarIndex)
                        ),
                        color = settings.Appearance.uiColorTextDim,
                        timestamp = os.date("%H:%M", os.time()),
                })
        end
)

return messages
