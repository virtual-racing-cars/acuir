local setupExchangeAPI = require("setup_exchange")

local setupExchangeBrowser = {}

local cui = require("src.ui.cui")
local settings = require("settings")
local style = require("src.ui.style")

local mainCarID = ac.getCarID(0)

-- if settings.General.autoStart then ac.uninstallApp("SetupExchange") end

local function formatNumber(n)
        local abs = math.abs(n)
        local sign = n < 0 and "-" or ""
        local value, suffix

        if abs >= 1e9 then
                value, suffix = abs / 1e9, "B"
        elseif abs >= 1e6 then
                value, suffix = abs / 1e6, "M"
        elseif abs >= 1e3 then
                value, suffix = abs / 1e3, "k"
        else
                return tostring(n)
        end

        -- Check if value is whole number
        if value == math.floor(value) then
                return string.format("%s%d%s", sign, value, suffix)
        else
                return string.format("%s%.1f%s", sign, value, suffix)
        end
end

local function likeButtons(path, item, likedList, dislikedList, itemID, contextTable)
        local fontSize = style.main.font.small.size
        local fontSpace = style.main.font.small.space
        local actionBlockSize = vec2(ui.availableSpaceX() / 4 - 10 * cui.scale(), fontSpace)
        cui.offsetCursorY(fontSpace / 6)
        local voteZoneButton =
                ui.invisibleButton("##vote_zone_setup_exchange", actionBlockSize, ui.ButtonFlags.Disabled)
        local r1, r2 = ui.itemRect()

        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackgroundShade, 6 * cui.scale())

        local likeDelta = item.statLikes - item.statDislikes
        -- ui.setCursor(p)

        local liked = table.contains(setupExchangeAPI.likedSetups, itemID)
        local disliked = table.contains(setupExchangeAPI.dislikedSetups, itemID)

        ui.setCursor(r1)
        local likeClicked =
                ui.invisibleButton("##setup_exchange_like_" .. itemID, vec2(actionBlockSize.x / 3, fontSpace))
        local likeSize = ui.itemRectSize()
        local likeColor = rgbm.colors.gray * 0.7

        if ui.itemHovered() or liked then likeColor = rgbm.colors.green end
        ui.addIcon(ui.Icons.Up, likeSize * 0.5, vec2(0.5, 0.5), likeColor, 0)

        if likeClicked then
                if liked then
                        item.statLikes = item.statLikes - 1
                        table.removeItem(likedSetups, itemID)
                        rest("PATCH", path .. "/" .. itemID, contextTable)
                else
                        item.statLikes = item.statLikes + 1
                        table.insert(setupExchangeAPI.likedSetups, itemID)
                        setupExchangeAPI:rest(
                                "PATCH",
                                path .. "/" .. itemID,
                                table.chain(contextTable, { direction = 1 })
                        )
                        if disliked then
                                item.statDislikes = item.statDislikes - 1
                                table.removeItem(setupExchangeAPI.dislikedSetups, itemID)
                        end
                end
        end

        ui.sameLine()
        cui.snapCursor()
        ui.dwriteTextAligned(
                formatNumber(likeDelta),
                style.main.font.small.size,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(actionBlockSize.x / 3, fontSpace),
                false,
                settings.Appearance.uiColorText
        )
        ui.sameLine()

        local dislikeClicked =
                ui.invisibleButton("##setup_exchange_dislike_" .. itemID, vec2(actionBlockSize.x / 3, fontSpace))
        local dislikeSize = ui.itemRectSize()
        local dislikeColor = rgbm.colors.gray * 0.7

        if ui.itemHovered() or disliked then dislikeColor = rgbm.colors.red end
        ui.addIcon(ui.Icons.Down, dislikeSize * 0.5, vec2(0.5, 0.5), dislikeColor, 0)

        if dislikeClicked then
                if disliked then
                        item.statDislikes = item.statDislikes - 1
                        table.removeItem(setupExchangeAPI.dislikedSetups, itemID)
                        setupExchangeAPI:rest("PATCH", path .. "/" .. itemID, contextTable)
                else
                        item.statDislikes = item.statDislikes + 1
                        table.insert(setupExchangeAPI.dislikedSetups, itemID)
                        setupExchangeAPI:rest(
                                "PATCH",
                                path .. "/" .. itemID,
                                table.chain(contextTable, { direction = -1 })
                        )
                        if liked then
                                item.statLikes = item.statLikes - 1
                                table.removeItem(likedSetups, itemID)
                        end
                end
        end
end

local function timeAgo(timestamp)
        local now = os.time()
        local diff = now - timestamp
        local timeNum = diff
        local timeUnit = "second"

        if diff < 60 then
        elseif diff < 3600 then
                timeNum = math.floor(diff / 60)
                timeUnit = "minute"
        elseif diff < 86400 then
                timeNum = math.floor(diff / 3600)
                timeUnit = "hour"
        elseif diff < 604800 then
                timeNum = math.floor(diff / 86400)
                timeUnit = "day"
        elseif diff < 2629746 then -- ~1 month
                timeNum = math.floor(diff / 604800)
                timeUnit = "week"
        elseif diff < 31556952 then -- ~1 year
                timeNum = math.floor(diff / 2629746)
                timeUnit = "month"
        else
                timeNum = math.floor(diff / 31556952)
                timeUnit = "year"
        end

        return string.format("%s %s%s ago", timeNum, timeUnit, timeNum > 1 and "s" or "")
end

local commentSize = vec2(100, 130)
local itemSize = vec2(100, 130)

local function commentsBlock()
        ui.setCursorX(0)
        cui.offsetCursorY(15)
        local item = setupExchangeAPI.discussingItem
        local comment = setupExchangeAPI.discussingComments[item.setupID] or ""
        local comments = setupExchangeAPI:refreshComments()
        if not comments then
                ui.drawLoadingSpinner(ui.windowSize() / 2 - 20, ui.windowSize() / 2 + 20)
                -- ui.text('Loading list of comments…')
                return
        end

        if type(comments) == "string" then
                ui.text("Failed to load comments:")
                ui.text(comments)
                return
        end

        ui.childWindow("commentsScroll", ui.availableSpace(), function()
                local fontSize = style.main.font.small.size
                local fontSpace = style.main.font.small.space
                local setupItemWidth = ui.windowWidth() - 10 * cui.scale()
                local actionBlockSize = vec2(ui.availableSpaceX() / 4 - 10 * cui.scale(), fontSpace)

                cui.offsetCursorY(15)
                if #comments == 0 then
                        cui.snapCursor()
                        cui.offsetCursorX(15)
                        ui.dwriteTextAligned(
                                "No comments yet",
                                fontSize,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(setupItemWidth, fontSpace),
                                false,
                                settings.Appearance.uiColorTextDim
                        )
                end
                for _, v in ipairs(comments) do
                        if ui.areaVisible(commentSize) then
                                if _ == #comments then setupExchangeAPI:loadMoreComments() end
                                local y = ui.getCursorY()
                                ui.pushID(v.commentID)
                                local disliked = v.statDislikes > v.statLikes + 1

                                cui.offsetCursorX(30)
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        string.format("%s • %s", v.userName, timeAgo(v.createdDate)),
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Center,
                                        vec2(setupItemWidth, fontSpace),
                                        false,
                                        v.userID == setupExchangeAPI.ownUserID and settings.Appearance.uiColorYellow
                                                or settings.Appearance.uiColorText
                                )

                                cui.offsetCursorX(30)
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        v.data,
                                        fontSize,
                                        ui.Alignment.Start,
                                        ui.Alignment.Start,
                                        vec2(setupItemWidth, fontSpace),
                                        true
                                )

                                -- local i = string.find(v.data, "@" .. stored.userName, 1, true)
                                -- if i then ui.setNextTextSpanStyle(i, i + 1 + #stored.userName, ownColor, true) end
                                -- ui.textWrapped(v.data)

                                cui.setCursorX(30)
                                likeButtons(
                                        "comment-likes",
                                        v,
                                        setupExchangeAPI.likedComments,
                                        setupExchangeAPI.dislikedComments,
                                        v.commentID,
                                        { setupID = item.setupID }
                                )

                                ui.sameLine()
                                cui.offsetCursorX(5)

                                if
                                        ui.invisibleButton(
                                                "##reply_setup_exchange_" .. (v.commmentID or ""),
                                                vec2(actionBlockSize.x * 0.75, actionBlockSize.y)
                                        )
                                then
                                        comment = "@" .. v.userName .. " " .. comment
                                end
                                local r1, r2 = ui.itemRect()

                                ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackgroundShade, 6 * cui.scale())
                                ui.addIcon(ui.Icons.Chat, vec2(10 * cui.scale(), 10 * cui.scale()), vec2(0.5, 0.5))

                                ui.setCursor(r1)
                                cui.snapCursor()
                                ui.dwriteTextAligned(
                                        "Reply",
                                        fontSize,
                                        ui.Alignment.Center,
                                        ui.Alignment.Center,
                                        vec2(actionBlockSize.x * 0.75, actionBlockSize.y),
                                        true
                                )

                                if v.userID == setupExchangeAPI.ownUserID then
                                        ui.sameLine()
                                        cui.offsetCursorX(5)

                                        if
                                                ui.invisibleButton(
                                                        "##delete_setup_exchange_" .. (v.commmentID or ""),
                                                        vec2(actionBlockSize.x * 0.75, actionBlockSize.y)
                                                )
                                        then
                                                removeComment(v.commentID, true)
                                                item.statComments = item.statComments - 1
                                        end
                                        local r1, r2 = ui.itemRect()

                                        ui.drawRectFilled(
                                                r1,
                                                r2,
                                                settings.Appearance.uiColorBackgroundShade,
                                                6 * cui.scale()
                                        )
                                        ui.addIcon(
                                                ui.Icons.Delete,
                                                vec2(10 * cui.scale(), 10 * cui.scale()),
                                                vec2(0.5, 0.5)
                                        )

                                        ui.setCursor(r1)
                                        cui.snapCursor()
                                        ui.dwriteTextAligned(
                                                "Delete",
                                                fontSize,
                                                ui.Alignment.Center,
                                                ui.Alignment.Center,
                                                vec2(actionBlockSize.x * 0.75, actionBlockSize.y),
                                                true
                                        )
                                end

                                ui.popID()
                                ui.offsetCursorY(12)
                                itemSize.y = ui.getCursorY() - y
                        else
                                ui.offsetCursorY(commentSize.y)
                        end
                end
                if setupExchangeAPI.scrollCommentsDown then ui.setScrollY(1e9, false, true) end
        end)

        local _, submitted
        comment, _, submitted = ui.inputText("Add a comment…", comment, ui.InputTextFlags.Placeholder)
        if ui.isWindowAppearing() or setupExchangeAPI.scrollCommentsDown then
                ui.setKeyboardFocusHere(-1)
                if #comments == commentsTotalCount or ui.windowScrolling() then scrollCommentsDown = false end
        end
        ui.sameLine(0, 4)
        local canSend = #comment:trim() > 0
                and not setupExchangeAPI.currentlySubmittingComment
                and setupExchangeAPI.session.id ~= nil
        if
                (
                        ui.button("Send", vec2(ui.availableSpaceX(), 0), canSend and 0 or ui.ButtonFlags.Disabled)
                        or submitted
                ) and canSend
        then
                setupExchangeAPI.currentlySubmittingComment = true
                setupExchangeAPI:rest(
                        "POST",
                        "comments",
                        { setupID = item.setupID, userName = setupExchangeAPI.stored.userName, data = comment:trim() },
                        function(response)
                                currentlySubmittingComment = false
                                ui.toast(ui.Icons.Settings, "Comment posted", function()
                                        removeComment(response.commentID)
                                        item.statComments = item.statComments - 1
                                end)
                                listOfComments = nil
                                discussingComments[item.setupID] = ""
                                item.statComments = item.statComments + 1
                        end,
                        function(err)
                                currentlySubmittingComment = false
                                ui.toast(ui.Icons.Warning, "Failed to post a comment: " .. err)
                        end
                )
        end
        if ui.itemHovered() and setupExchangeAPI.session.id == nil then
                ui.setTooltip(setupExchangeAPI.session.error or "Connecting…")
        end
        setupExchangeAPI.discussingComments[item.setupID] = comment
end

-- local function userControls()
--         ui.sameLine(0, 4)
--         if ui.button("…") then
--                 ui.popup(function()
--                         ui.text("Your name: " .. stored.userName)
--                         if ui.selectable("Change name", false) then
--                                 ui.modalPrompt("Change name", "New name:", stored.userName, function(newName)
--                                         if not newName or #newName:trim() == 0 then return end
--                                         rest(
--                                                 "POST",
--                                                 "user",
--                                                 { userName = newName:trim() },
--                                                 function()
--                                                         ui.toast(ui.Icons.Confirm, "Name changed")
--                                                         stored.userName = newName:trim()
--                                                         listOfSetups = nil
--                                                 end,
--                                                 function(err)
--                                                         ui.toast(ui.Icons.Warning, "Couldn’t change name: " .. err)
--                                                 end
--                                         )
--                                 end)
--                         end
--                         if ui.itemHovered() then
--                                 ui.setTooltip("Changing name would also change it for all published content")
--                         end
--                         ui.separator()
--                         if ui.selectable("Your setups…") then
--                                 authorUsernameFilter = stored.userName
--                                 listOfSetups = nil
--                         end
--                 end, { position = ui.windowPos() + ui.itemRectMin() + vec2(0, 20) })
--         end
-- end

local function drawSetupItem(i, v)
        local fontSize = style.main.font.small.size
        local fontSpace = style.main.font.small.space
        local setupItemWidth = ui.windowWidth() - 20 * cui.scale()
        local setupItemHeight = fontSpace * 4
        cui.setCursorX(10)
        ui.setCursorY((setupItemHeight + 5 * cui.scale()) * (i - 1) + 10 * cui.scale())
        ui.pushID(v.setupID)

        local p = ui.getCursor()
        ui.dummy(vec2(setupItemWidth, setupItemHeight))
        local clicked = ui.itemClicked()
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()
        local buttonColor = settings.Appearance.uiColorPrimary
        local fontColor = settings.Appearance.uiColorText
        local subFontColor = settings.Appearance.uiColorText
        local borderThickness = 1 * cui.scale()

        if clicked then setupExchangeAPI.selectedSetup = v end
        local active = setupExchangeAPI.selectedSetup and v.setupID == setupExchangeAPI.selectedSetup.setupID

        if hovered and ui.mouseDoubleClicked(ui.MouseButton.Left) then
                setupExchangeAPI.selectedSetup = v

                setupExchangeAPI.currentlyApplying = true
                setupExchangeAPI:getSetupData(setupExchangeAPI.selectedSetup, true, function(err, data)
                        currentlyApplying = false
                        if err then
                                cui.menuBanner("Failed to load setup", nil, rgbm.colors.red)
                        else
                                ac.saveCurrentSetup(temporaryBackupName)

                                io.save(temporaryName, data)
                                ac.loadSetup(temporaryName)

                                cui.menuBanner("Setup applied", nil, rgbm.colors.green)
                        end
                end)
        end

        -- active = true

        if active then
                borderThickness = 5 * cui.scale()
                buttonColor = settings.Appearance.uiColorAccent
        elseif hovered then
                borderThickness = 5 * cui.scale()
                buttonColor = settings.Appearance.uiColorSecondary
        end

        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorPrimary, 6 * cui.scale(), ui.CornerFlags.All)
        ui.drawRect(r1, r2, buttonColor, 6 * cui.scale(), ui.CornerFlags.All, borderThickness)

        ui.setCursor(r1)
        cui.offsetCursorY(fontSpace / 6)
        cui.setCursorX(20)
        cui.snapCursor()
        style:pushFontBold()
        ui.dwriteTextAligned(
                v.trackID .. " / " .. v.name:trim(),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(setupItemWidth - 10 * cui.scale(), fontSpace),
                false,
                fontColor
        )
        ui.popDWriteFont()

        cui.offsetCursorY(fontSpace / 6)
        cui.setCursorX(20)
        local usernameButtonSize =
                vec2(ui.measureDWriteText(string.format("%s....", v.userName), fontSize).x, fontSpace)

        local usernameClicked = ui.invisibleButton("##username_button_" .. v.userName, usernameButtonSize)
        local r1, r2 = ui.itemRect()
        ui.drawRectFilled(
                r1,
                r2,
                v.userID == setupExchangeAPI.ownUserID and settings.Appearance.uiColorYellow
                        or settings.Appearance.uiColorBackgroundShade,
                6 * cui.scale()
        )

        ui.setCursor(r1)
        cui.snapCursor()
        ui.dwriteTextAligned(
                v.userName,
                style.main.font.small.size,
                ui.Alignment.Center,
                ui.Alignment.Center,
                usernameButtonSize,
                false,
                v.userID == setupExchangeAPI.ownUserID and settings.Appearance.uiColorTextDim
                        or settings.Appearance.uiColorText
        )
        ui.sameLine()

        cui.offsetCursorX(10)
        cui.snapCursor()
        ui.dwriteTextAligned(
                timeAgo(v.createdDate),
                style.main.font.small.size,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX() - 10 * cui.scale(), fontSpace),
                false,
                subFontColor
        )
        ui.sameLine()
        ui.setCursorX(0)

        cui.offsetCursorX(-5)
        cui.snapCursor()
        ui.dwriteTextAligned(
                string.format("%s Downloads", formatNumber(v.statDownloads)),
                style.main.font.small.size,
                ui.Alignment.End,
                ui.Alignment.Center,
                vec2(setupItemWidth, fontSpace),
                false,
                subFontColor
        )

        local actionBlockSize = vec2(ui.availableSpaceX() / 4 - 10 * cui.scale(), fontSpace)
        cui.setCursorX(20)

        likeButtons(
                "likes",
                v,
                setupExchangeAPI.likedSetups,
                setupExchangeAPI.dislikedSetups,
                v.setupID,
                { carID = v.carID }
        )

        ui.sameLine()
        cui.offsetCursorX(5)

        local hasComments = v.statComments > 0
        local commentsClicked = ui.invisibleButton("##setup_exchange_comments_" .. v.setupID, actionBlockSize)
        local commentsColor = rgbm.colors.gray * 0.7
        local r1, r2 = ui.itemRect()
        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackgroundShade, 6 * cui.scale())

        if ui.itemHovered() then
                commentsColor = settings.Appearance.uiColorSecondary
        elseif hasComments then
                commentsColor = settings.Appearance.uiColorText
        end

        if commentsClicked then
                if setupExchangeAPI.discussingItem == v then
                        setupExchangeAPI.discussingItem = nil
                else
                        setupExchangeAPI.discussingItem = v
                        setupExchangeAPI.listOfComments = nil
                        setupExchangeAPI.listOfCommentsPrev = nil
                        local closeCounter = 0

                        -- ui.popup(function()
                        --         if discussingItem ~= v or closeCounter > 1 then
                        --                 ui.closePopup()
                        --                 return
                        --         end
                        --         commentsBlock()
                        -- end, {
                        --         size = { initial = vec2(400, ui.windowHeight()) },
                        --         position = ui.windowPos() + vec2(ui.windowWidth() + 20),
                        --         padding = vec2(12, 0),
                        --         title = "Comments (" .. v.name:trim() .. " by " .. v.userName .. ")",
                        --         backgroundColor = settings.Appearance.uiColorBackgroundShade,
                        --         flags = bit.bor(ui.WindowFlags.NoCollapse, ui.WindowFlags.NoResize),
                        --         onClose = function()
                        --                 if discussingItem == v then discussingItem = nil end
                        --         end,
                        -- })
                end
        end

        ui.setCursor(r1)
        cui.snapCursor()
        ui.dwriteTextAligned(
                formatNumber(v.statComments) .. " Comments",
                style.main.font.small.size,
                ui.Alignment.Center,
                ui.Alignment.Center,
                actionBlockSize,
                false,
                hasComments and settings.Appearance.uiColorText or settings.Appearance.uiColorTextDim
        )
        ui.sameLine()
        ui.offsetCursorX(actionBlockSize.x)
        cui.offsetCursorX(5)

        if active then
                local applyAvailable = ac.isSetupAvailableToEdit() and v.carID == mainCarID and not currentlyApplying
                local applyClicked = ui.invisibleButton(
                        "##download_setup_" .. v.setupID,
                        actionBlockSize,
                        applyAvailable and 0 or ui.ButtonFlags.Disabled
                )
                local r1, r2 = ui.itemRect()
                ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackgroundShade, 6 * cui.scale())

                ui.setCursor(r1)
                cui.snapCursor()
                ui.dwriteTextAligned(
                        "Apply Setup",
                        style.main.font.small.size,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        actionBlockSize,
                        false,
                        applyAvailable and settings.Appearance.uiColorText or settings.Appearance.uiColorTextDim
                )

                if applyClicked then
                        setupExchangeAPI.selectedSetup = v

                        setupExchangeAPI.currentlyApplying = true
                        setupExchangeAPI:getSetupData(setupExchangeAPI.selectedSetup, true, function(err, data)
                                currentlyApplying = false
                                if err then
                                        cui.menuBanner("Failed to load setup", nil, rgbm.colors.red)
                                else
                                        ac.saveCurrentSetup(temporaryBackupName)

                                        io.save(temporaryName, data)
                                        ac.loadSetup(temporaryName)

                                        cui.menuBanner("Setup applied", nil, rgbm.colors.green)
                                end
                        end)
                end
        else
                ui.dummy(actionBlockSize)
        end

        if setupExchangeAPI.discussingItem == v then commentsBlock() end

        ui.popID()
end

local function setupsListWindow(setups)
        ui.setCursor(0)

        if setupExchangeAPI.discussingItem then
                drawSetupItem(1, setupExchangeAPI.discussingItem)
                return
        end

        ui.childWindow("scroll_setup_exchange", ui.windowSize(), function()
                if #setups == 0 then
                        cui.offsetCursorX(15)
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "No fitting setups available yet.",
                                style.main.font.body.size,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), 28 * cui.scale()),
                                false,
                                settings.Appearance.uiColorTextDim
                        )

                        return
                end

                local fontSpace = style.main.font.small.space
                local setupItemHeight = fontSpace * 4 + 5 * cui.scale()

                local f = 1 + math.floor(ui.getScrollY() / setupItemHeight)
                local t = 2 + math.floor((ui.getScrollY() + ui.windowHeight()) / setupItemHeight)

                if t > #setups then setupExchangeAPI:loadMoreSetups() end
                for i = f, math.min(t, #setups) do
                        local v = setups[i]

                        if v then drawSetupItem(i, v) end
                end

                ui.setMaxCursorY(
                        math.max(setupExchangeAPI.setupsTotalCount, #setups) * setupItemHeight + 20 * cui.scale()
                )
        end)
end

local function shareSetupButton()
        local iconButtonHeight = 32 * cui.scale()
        local buttonWidth = ui.windowWidth() * 0.99
        local groupBegin = (ui.windowWidth() / 24)
        local fontSize = style.main.font.body.size

        cui.offsetCursorY(100)

        -- if ac.isSetupAvailableToEdit() and setupExchangeAPI.selectedSetup and setupExchangeAPI.selectedSetup.carID == mainCarID then
        --         ui.setCursorX(ui.windowWidth() * 0.005)
        --         if
        --                 cui.menuButton(
        --                         "Download Setup",
        --                         vec2(buttonWidth * 0.49, iconButtonHeight),
        --                         nil,
        --                         nil,
        --                         (setupExchangeAPI.selectedSetup and downloadedAsFiles[setupExchangeAPI.selectedSetup.setupID]) and ui.ButtonFlags.Active
        --                                 or not currentlyApplying and 0
        --                                 or ui.ButtonFlags.Disabled,
        --                         false,
        --                         false
        --                 )
        --         then
        --                 downloadSetupAsFile(setupExchangeAPI.selectedSetup)
        --         end

        -- else
        --         ui.setCursorX(ui.windowWidth() * 0.005)
        --         if
        --                 cui.menuButton(
        --                         "Download Setup",
        --                         vec2(buttonWidth, iconButtonHeight),
        --                         nil,
        --                         nil,
        --                         (setupExchangeAPI.selectedSetup and currentlyApplying) and 0 or ui.ButtonFlags.Disabled,
        --                         false,
        --                         false
        --                 )
        --         then
        --                 downloadSetupAsFile(setupExchangeAPI.selectedSetup)
        --         end
        -- end

        ui.setCursorX(ui.windowWidth() * 0.005)
        if
                cui.menuButton(
                        "Share Current Setup",
                        vec2(buttonWidth, iconButtonHeight),
                        0,
                        0,
                        sessionID ~= nil and 0 or ui.ButtonFlags.Disabled
                )
        then
                ui.modalPrompt("Share setup", "Name the setup:", nil, "Share", "Cancel", nil, nil, function(name)
                        if name and #name:trim() > 0 then shareSetup(name:trim()) end
                end)
        end
        if ui.itemHovered() and setupExchangeAPI.session.id == nil then
                ui.setTooltip(setupExchangeAPI.session.error or "Connecting…")
        end
end

local function failureBlock(setups)
        ui.pushAlignment(true)
        ui.text("Failed to load setups:")
        ui.text(setups)
        ui.setNextItemIcon(ui.Icons.Restart)
        if ui.button("Try again", vec2(-0.1, 0)) then listOfSetups = nil end
        ui.popAlignment()
end

local newSearchFilter = ""

local function searchFilters()
        local iconButtonHeight = 32 * cui.scale()
        local buttonWidth = ui.windowWidth() * 0.99
        local groupBegin = (ui.windowWidth() / 24)
        local fontSize = style.main.font.body.size
        local comboSize = vec2((ui.windowWidth() - 20 * cui.scale()) * 0.5, 32 * cui.scale())

        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackgroundShade, 6 * cui.scale())

        cui.offsetCursorX(10)
        cui.setCursorY(10)
        local textInputWidth = ui.windowWidth() * 0.25
        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + comboSize,
                settings.Appearance.uiColorBackground * 0.25,
                6 * cui.scale()
        )
        ui.drawRect(ui.getCursor(), ui.getCursor() + comboSize, settings.Appearance.uiColorText * 0.75, 6 * cui.scale())

        newSearchFilter = cui.inputText("##controlsSearcher", comboSize, "", newSearchFilter, "Search setups...", "")

        if setupExchangeAPI.searchFilter ~= newSearchFilter then
                setupExchangeAPI.searchFilter = newSearchFilter
                setupExchangeAPI.listOfSetups = nil
        end

        ui.sameLine()
        ui.setCursorX(comboSize.x)
        ui.icon(ui.Icons.ZoomIn, 32 * cui.scale(), rgbm.colors.gray, 32 * cui.scale() * 0.5)

        ui.sameLine()
        ui.setCursorX(ui.windowWidth() * 0.5 + 10 * cui.scale())

        cui.combo(
                "##sort_setup_exchange",
                comboSize,
                setupExchangeAPI.setupsOrder[setupExchangeAPI.stored.setupsOrder][1],
                ui.Alignment.Start,
                true,
                vec2(comboSize.x, comboSize.y * (#setupExchangeAPI.setupsOrder + 3)),
                function()
                        cui.offsetCursorX(25)
                        cui.offsetCursorY(15)
                        local showTracksChanged = false
                        local showTracksValue = not setupExchangeAPI.stored.setupsFilterTrack
                        showTracksValue, showTracksChanged = drawCheckbox(
                                "##setup_exchange_show_current_track",
                                "Show All Tracks",
                                style.main.font.small.size,
                                showTracksValue
                        )

                        if showTracksChanged then
                                setupExchangeAPI.stored.setupsFilterTrack = not showTracksValue
                                setupExchangeAPI.listOfSetups = nil
                        end

                        cui.offsetCursorY(15)

                        for i, v in ipairs(setupExchangeAPI.setupsOrder) do
                                cui.setCursorX(15)
                                if
                                        cui.menuButton(
                                                v[1],
                                                vec2(ui.windowWidth() - 30 * cui.scale(), comboSize.y),
                                                ui.Alignment.Center
                                        )
                                then
                                        setupExchangeAPI.stored.setupsOrder = i
                                        setupExchangeAPI.listOfSetups = nil
                                end
                                cui.offsetCursorY(5)
                        end

                        cui.offsetCursorY(15)
                end
        )
end

function setupExchangeBrowser.body()
        local setups = setupExchangeAPI:refreshSetups()
        if not setups then
                ui.drawLoadingSpinner(ui.windowSize() / 2 - 20, ui.windowSize() / 2 + 20)
                setupExchangeAPI:refreshSetups()
                return
        end

        if type(setups) == "string" then
                failureBlock(setups)
                return
        end

        local filterSpaceSize = 5 * cui.scale()

        if not setupExchangeAPI.discussingItem then
                filterSpaceSize = 50 * cui.scale()
                searchFilters()
        end

        cui.pushWindow(
                "setup_exchange_setups",
                0,
                filterSpaceSize,
                ui.windowWidth(),
                ui.windowHeight() - filterSpaceSize,
                false,
                ui.ButtonFlags.None
        )
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackground, 6 * cui.scale())

        setupsListWindow(setups)
        cui.popWindow()
end

return setupExchangeBrowser
