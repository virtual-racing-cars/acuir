--[[
  Simplest client for exchanging setups with comments and likes.
]]

local cui = require("src.ui.cui")
local settings = require("settings")
local style = require("style")

-- if settings.General.autoStart then ac.uninstallApp("SetupExchange") end

local setupExchange = {}

local mainCarID = ac.getCarID(0)
local v2 = const(ac.getPatchVersionCode() >= 3044)
local v3 = const(ac.getPatchVersionCode() >= 3050)
local endpoint = "http://se.acstuff.club"
-- local endpoint = 'http://127.0.0.1:12016'
local temporaryName = ac.getFolder(ac.FolderID.AppDataLocal) .. "/Temp/ac-se-shared.ini"
local temporaryBackupName = ac.getFolder(ac.FolderID.AppDataLocal) .. "/Temp/ac-se-backup.ini"

if not v2 then
        local json = require("lib/json")
        JSON = {
                stringify = json.encode,
                parse = json.decode,
        }
end

local trackNames = {}
do
        local cfg = ac.INIConfig.load(
                ac.getFolder(ac.FolderID.ExtCfgSys) .. "/data_track_params.ini",
                ac.INIFormat.Extended
        )
        for k, v in pairs(cfg.sections) do
                if v.NAME then trackNames[k] = v.NAME[1] end
        end
end

---@param callback fun(err: string?, sessionData: {sessionID: string, userID: string, likes: string, dislikes: string}?, userKey: string?)
local function createSession(callback)
        ac.uniqueMachineKeyAsync(function(err, data)
                if err then
                        callback(err)
                        return
                end

                local userID = ac.checksumSHA256("LB83XurHhTPhpmTc" .. data)
                if not v3 then
                        callback(nil, nil, userID)
                        return
                end

                web.request(
                        "POST",
                        endpoint .. "/session",
                        { ["X-Session-ID"] = "0" },
                        JSON.stringify({ userID = userID }),
                        function(err, response)
                                if err then
                                        callback(err)
                                else
                                        local parsed = JSON.parse(response.body)
                                        if type(parsed) == "table" and parsed.key then
                                                require("shared/utils/signing").blob(
                                                        "{UniqueMachineKeyChecksum}",
                                                        parsed.key,
                                                        function(signature, header)
                                                                web.request(
                                                                        "PATCH",
                                                                        endpoint .. "/session",
                                                                        { ["X-Session-ID"] = "0" },
                                                                        JSON.stringify({
                                                                                userID = userID,
                                                                                header = ac.encodeBase64(header),
                                                                                signature = ac.encodeBase64(signature),
                                                                                carID = mainCarID,
                                                                                carName = ac.getCarName(0),
                                                                                trackID = ac.getTrackID(),
                                                                                trackName = ac.getTrackName(),
                                                                        }),
                                                                        function(err, response)
                                                                                if err then
                                                                                        callback(err)
                                                                                else
                                                                                        local parsed = JSON.parse(
                                                                                                response.body
                                                                                        )
                                                                                        if
                                                                                                type(parsed)
                                                                                                        == "table"
                                                                                                and parsed.sessionID
                                                                                                and parsed.userID
                                                                                        then
                                                                                                callback(nil, parsed)
                                                                                        else
                                                                                                callback(
                                                                                                        "Server is not working correctly"
                                                                                                )
                                                                                        end
                                                                                end
                                                                        end
                                                                )
                                                        end
                                                )
                                        else
                                                callback("Server is not working correctly")
                                        end
                                end
                        end
                )
        end)
end

local ownUserID
local likedSetups, dislikedSetups = {}, {}

---@type string? string?, string?, number
local userKey, sessionID, sessionError, sessionCooldown = nil, nil, nil, 0
local function tryRecreateSession()
        if os.preciseClock() < sessionCooldown then return end
        sessionCooldown = os.preciseClock() + 2
        createSession(function(err, session, newUserKey)
                if newUserKey then
                        userKey = newUserKey
                elseif err then
                        sessionError, sessionID = tostring(err), nil
                        ac.error("Failed to create a session: " .. tostring(err))
                else
                        sessionError, sessionID, ownUserID = nil, session.sessionID, session.userID
                        ac.log("New session: " .. session.sessionID .. ", user ID: " .. ownUserID)
                        table.clear(likedSetups)
                        table.clear(dislikedSetups)
                        for i, v in ipairs(session.likes:split(";", nil, false, true)) do
                                likedSetups[i] = tonumber(v, 36)
                        end
                        for i, v in ipairs(session.dislikes:split(";", nil, false, true)) do
                                dislikedSetups[i] = tonumber(v, 36)
                        end
                end
        end)
end

tryRecreateSession()

if not string.urlEncode then
        string.urlEncode = function(str)
                str = string.gsub(str, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
                str = string.gsub(str, " ", "+")
                return str
        end
end

local function rest(method, url, data, callback, errorHandler)
        if not sessionID and not userKey and (method ~= "GET" or url ~= "setups") then
                setTimeout(function() rest(method, url, data, callback, errorHandler) end, 0.5)
                return
        end

        if method == "GET" and data then
                local f = true
                for k, v in pairs(data) do
                        url = url .. (f and "?" or "&") .. k .. "=" .. string.urlEncode(v)
                        f = false
                end
        end

        if not callback then
                callback = function(response, headers)
                        ac.log("Successfully executed: " .. url .. ", response: " .. stringify(response))
                end
        end
        if not errorHandler then errorHandler = function(err) ac.warn(err) end end

        local start = os.preciseClock()
        web.request(
                method,
                endpoint .. "/" .. url,
                {
                        ["Content-Type"] = "application/json",
                        [userKey and "X-User-Key" or "X-Session-ID"] = userKey or sessionID or "0",
                },
                method ~= "GET" and JSON.stringify(data) or nil,
                function(err, response)
                        ac.log("Request: %s, %.1f ms" % { endpoint .. "/" .. url, 1e3 * (os.preciseClock() - start) })
                        if err then return errorHandler(tostring(err)) end

                        if response.status >= 400 then
                                local parsed = try(function() return JSON.parse(response.body) end, function() end)
                                if parsed and parsed.error then
                                        err = parsed.error
                                else
                                        err = response.body
                                end
                                err = tostring(err)
                                if err:sub(1, 7) == "Error: " then err = err:sub(8) end
                                if err == "Invalid session ID" then tryRecreateSession() end
                                return errorHandler(err)
                        end

                        try(function() callback(JSON.parse(response.body), response.headers) end, errorHandler)
                end
        )
end

local limit = 40

local function refreshGenList(uniqueKey, url, params, callback, continuationState)
        rest(
                "GET",
                url,
                table.chain(params, { offset = continuationState and #continuationState[3] or 0, limit = limit }),
                function(response, headers)
                        local totalCount = tonumber(headers["x-total-count"]) or #response
                        if callback then
                                local continuationState = {
                                        #response < totalCount,
                                        totalCount,
                                        response,
                                        table.map(response, function(item) return true, item[uniqueKey] end),
                                }
                                callback(response, continuationState[1] and function()
                                        if continuationState[1] then
                                                continuationState[1] = false
                                                refreshGenList(uniqueKey, url, params, nil, continuationState)
                                        end
                                end, totalCount)
                        elseif continuationState and #response > 0 then
                                for _, v in ipairs(response) do
                                        if not continuationState[4][v[uniqueKey]] then
                                                continuationState[4][v[uniqueKey]] = true
                                                table.insert(continuationState[3], v)
                                        end
                                end
                                continuationState[2] = totalCount
                                continuationState[1] = #continuationState[3] < continuationState[2]
                        end
                end,
                function(err)
                        ac.warn("Failed to get list of " .. url .. ": " .. err)
                        if callback then callback(err) end
                end
        )
end

local setupsOrder = {
        {
                "Hot",
                "(statDislikes*200-statLikes*20-statDownloads-statComments*2)*1e6/sqrt(max(60.0,@now-createdDate)/60)",
        },
        { "Popular", "-statDownloads" },
        { "Liked", "statDislikes-statLikes*2" },
        { "Newest", "-createdDate" },
        { "Title", "name" },
}

local stored = ac.storage({
        introduced = false,
        userName = "",
        setupsFilterTrack = true,
        setupsOrder = 1,
})

if #stored.userName == 0 then stored.userName = ac.getDriverName(0) or "User" end

local authorUsernameFilter = ""
local searchFilter = ""
local listOfSetups, listOfComments
local listOfSetupsPrev, listOfCommentsPrev
local likedComments, dislikedComments = {}, {}
local downloadedSetups = {}
local initializing = false
local currentlyApplying = false
local currentlySubmittingComment = false
local itemSize = vec2(100, 48)
local commentSize = vec2(100, 130)
local discussingItem
local discussingComments = {}
local setupTooltips = {}
local downloadedAsFiles = {}
local ownColor = rgbm(1, 1, 0, 1)

local function getSetupData(setupInfo, incrementDownloads, callback)
        local cached = downloadedSetups[setupInfo.setupID]
        if cached and (cached.data or cached.err) then
                if incrementDownloads and not cached.incremented then
                        cached.incremented = true
                        setupInfo.statDownloads = setupInfo.statDownloads + 1
                        rest("POST", "setup-download-counts/" .. setupInfo.setupID)
                end
                callback(cached.err, cached.data)
        elseif cached then
                table.insert(cached, callback)
        else
                downloadedSetups[setupInfo.setupID] = { callback }
                rest("GET", "setups/" .. setupInfo.setupID, nil, function(response)
                        if incrementDownloads then
                                setupInfo.statDownloads = setupInfo.statDownloads + 1
                                rest("POST", "setup-download-counts/" .. setupInfo.setupID)
                        end
                        local list = downloadedSetups[setupInfo.setupID]
                        downloadedSetups[setupInfo.setupID] = { data = response.data, incremented = incrementDownloads }
                        for _, v in ipairs(list) do
                                v(nil, response.data)
                        end
                end, function(err)
                        local list = downloadedSetups[setupInfo.setupID]
                        downloadedSetups[setupInfo.setupID] = { err = err, incremented = true }
                        for _, v in ipairs(list) do
                                v(err, nil)
                        end
                end)
        end
end

local function downloadSetupAsFile(setupInfo)
        if currentlyApplying or downloadedAsFiles[setupInfo.setupID] then return end
        currentlyApplying = true
        getSetupData(setupInfo, true, function(err, data)
                currentlyApplying = false
                local name = "generic/loaded-" .. setupInfo.name .. ".ini"
                local filename = ac.getFolder(ac.FolderID.UserSetups)
                        .. "/"
                        .. (setupInfo.carID or mainCarID)
                        .. "/"
                        .. name
                io.save(filename, data)
                ac.refreshSetups()

                cui.menuBanner("Setup downloaded as %s" % name, nil, rgbm.colors.green)

                downloadedAsFiles[setupInfo.setupID] = true
        end)
end

local knownNames = {
        ["FUEL"] = function(v) return string.format("Fuel set to %s L", v) end,
        ["BRAKE_POWER_MULT"] = function(v) return string.format("Brake power set to %s%%", v) end,
        ["ENGINE_LIMITER"] = function(v) return string.format("Engine limiter set to %s%%", v) end,
        ["FRONT_BIAS"] = function(v) return string.format("Brake bias set to %s%%", v) end,
        ["FINAL_RATIO"] = "Final gear ratio",
        ["GEARSET"] = "Gear set",
        ["ARB_FRONT"] = "ARB (front)",
        ["ARB_REAR"] = "ARB (rear)",
}

local function getItemDisplayName(item, value, hint)
        local n = knownNames[item]
        if n then return type(n) == "function" and n(value) or n end
        if item:find("PRESSURE_[LR]F") then return "Tyre pressure (front)" end
        if item:find("PRESSURE_[LR]R") then return "Tyre pressure (rear)" end
        if item:find("ROD_LENGTH_[LR]F") then return "Suspension height (front)" end
        if item:find("ROD_LENGTH_[LR]R") then return "Suspension height (rear)" end
        if item:find("SPRING_RATE_[LR]F") then return "Suspension wheel rate (front)" end
        if item:find("SPRING_RATE_[LR]R") then return "Suspension wheel rate (rear)" end
        if item:find("TOE_OUT_[LR]F") then return "Toe (front)" end
        if item:find("TOE_OUT_[LR]R") then return "Toe (rear)" end
        if item:find("CAMBER_[LR]F") then return "Camber (front)" end
        if item:find("CAMBER_[LR]R") then return "Camber (rear)" end
        if hint then return type(hint) == "string" and string.replace(hint, " Gear", " gear") or hint end
        local id = item:find("WING_(%d)")
        if id then return "Wing #" .. id end
        return item
end

local function getSetupTooltip(setupInfo)
        local known = setupTooltips[setupInfo.setupID]
        if known == nil then
                setupTooltips[setupInfo.setupID] = false
                getSetupData(setupInfo, false, function(err, data)
                        if err then
                                setupTooltips[setupInfo.setupID] = "Failed to get setup data: " .. err
                        else
                                local parsed = table.map(
                                        ac.INIConfig.parse(data).sections,
                                        function(item, index) return item.VALUE and tonumber(item.VALUE[1]), index end
                                )
                                local spinners = table.map(
                                        ac.getSetupSpinners(),
                                        function(i) return i.defaultValue and { i.defaultValue, i.label }, i.name end
                                )
                                local custom = {}
                                for k, v in pairs(parsed) do
                                        if spinners[k] and spinners[k][1] ~= v then
                                                table.insert(custom, getItemDisplayName(k, v, spinners[k][2]))
                                        end
                                end
                                custom = table.distinct(table.filter(custom, function(item) return #item > 0 end))
                                table.sort(custom)
                                if #custom == 0 then
                                        setupTooltips[setupInfo.setupID] = "No changes from default setup are detected."
                                else
                                        setupTooltips[setupInfo.setupID] = "Changes:\n• "
                                                .. table.join(custom, ";\n• ")
                                                .. "."
                                end

                                local tyresName = ac.getTyresLongName(0, parsed["TYRES"] or 999)
                                if #tyresName > 0 then
                                        setupTooltips[setupInfo.setupID] = setupTooltips[setupInfo.setupID]
                                                .. "\n\nTyres: "
                                                .. ac.getTyresLongName(0, parsed["TYRES"])
                                end
                        end
                end)
        end
        return setupTooltips[setupInfo.setupID]
end

local listOfSetupsContinuation
local setupsTotalCount = 0
local function refreshSetups()
        if not listOfSetups then
                local key = math.random()
                listOfSetups, listOfSetupsContinuation = key, nil
                refreshGenList("setupID", "setups", {
                        carID = authorUsernameFilter == "" and mainCarID or nil,
                        trackID = authorUsernameFilter == "" and stored.setupsFilterTrack and ac.getTrackID() or nil,
                        userName = authorUsernameFilter ~= "" and authorUsernameFilter or nil,
                        search = authorUsernameFilter == "" and searchFilter ~= "" and searchFilter or nil,
                        orderBy = setupsOrder[stored.setupsOrder][2],
                }, function(ret, continuation, totalCount)
                        if listOfSetups == key then
                                listOfSetups = ret
                                listOfSetupsPrev = ret
                                listOfSetupsContinuation = continuation and { ret, continuation }
                                setupsTotalCount = totalCount or 0
                        end
                end)
        end
        return (type(listOfSetups) == "table" or type(listOfSetups) == "string") and listOfSetups or listOfSetupsPrev
end

local function loadMoreSetups()
        if
                type(listOfSetups) == "table"
                and listOfSetupsContinuation
                and listOfSetupsContinuation[1] == listOfSetups
        then
                listOfSetupsContinuation[2]()
        end
end

local listOfCommentsContinuation
local commentsTotalCount = 0
local scrollCommentsDown = false
local function refreshComments()
        if not listOfComments then
                local key = math.random()
                listOfComments = key
                refreshGenList(
                        "commentID",
                        "comments",
                        { setupID = discussingItem.setupID },
                        function(ret, continuation, totalCount)
                                if listOfComments == key then
                                        listOfComments = ret
                                        listOfCommentsPrev = ret
                                        scrollCommentsDown = true
                                        listOfCommentsContinuation = continuation and { ret, continuation }
                                        commentsTotalCount = totalCount or 0
                                end
                        end
                )
                table.clear(likedComments)
                table.clear(dislikedComments)
                rest("GET", "comment-likes", { setupID = discussingItem.setupID }, function(data)
                        for _, v in ipairs(data) do
                                table.insert(v.direction == 1 and likedComments or dislikedComments, v.commentID)
                        end
                end)
        end
        return (type(listOfComments) == "table" or type(listOfComments) == "string") and listOfComments
                or listOfCommentsPrev
end

local function loadMoreComments()
        if
                type(listOfComments) == "table"
                and listOfCommentsContinuation
                and listOfCommentsContinuation[1] == listOfComments
        then
                listOfCommentsContinuation[2]()
        end
end

local function initialLoading()
        if initializing or v3 then return end
        initializing = true
        rest("GET", "user", {
                carID = mainCarID,
                carName = ac.getCarName(0),
                trackID = ac.getTrackID(),
                trackName = ac.getTrackName(),
        }, function(response)
                ownUserID = response.userID or error("UserID is missing")
                ac.log("My user ID: " .. ownUserID)
        end, function(err) ac.warn("Failed to get own user ID: " .. err) end)
        rest("GET", "likes", { carID = mainCarID }, function(data)
                for _, v in ipairs(data) do
                        table.insert(v.direction == 1 and likedSetups or dislikedSetups, v.setupID)
                end
        end)
end

local removingIDs = {}

local function removeSetup(id, withUndo)
        if removingIDs[id] then return end
        removingIDs[id] = true
        rest("DELETE", "setups/" .. id, nil, function()
                ui.toast(ui.Icons.Delete, "Shared setup removed", withUndo and function()
                        rest(
                                "POST",
                                "setups-restore/" .. id,
                                nil,
                                function() listOfSetups = nil end,
                                function(err) ui.toast(ui.Icons.Warning, "Failed to restore setup: " .. err) end
                        )
                end or nil)
                listOfSetups = nil
                removingIDs[id] = nil
        end, function(err)
                ui.toast(ui.Icons.Warning, "Failed to remove setup: " .. err)
                removingIDs[id] = nil
        end)
end

local function removeComment(id, withUndo)
        rest(
                "DELETE",
                "comments/" .. id,
                nil,
                function() listOfComments = nil end,
                function(err) ui.toast(ui.Icons.Warning, "Failed to remove comment: " .. err) end
        )
end

local icons = ui.atlasIcons("res/icons.png", 4, 1, {
        Like = { 1, 1 },
        Dislike = { 1, 2 },
        Comments = { 1, 3 },
        Download = { 1, 4 },
})

local iconSize = vec2(10, 10)
local iconAlign = vec2(0, 0.6)
local iconLikeAlign = vec2(0, 0)
local iconDislikeAlign = vec2(0, 1)

local function shareSetup(name)
        ac.saveCurrentSetup(temporaryName)
        rest("POST", "setups", {
                carID = mainCarID,
                trackID = ac.getTrackID(),
                name = name,
                userName = stored.userName,
                data = io.load(temporaryName),
        }, function(response)
                ui.toast(ui.Icons.Settings, "Setup shared", function() removeSetup(response.setupID) end)
                listOfSetups = nil
        end, function(err) ui.toast(ui.Icons.Warning, "Failed to share setup: " .. err) end)
end

local function likeButtons(path, item, likedList, dislikedList, itemID, contextTable)
        local fontSize = style.main.font.small.size
        local fontSpace = style.main.font.small.space
        local actionBlockSize = vec2(ui.availableSpaceX() / 4 - 10 * cui.uiScale(), fontSpace)
        cui.offsetCursorY(fontSpace / 6)
        local voteZoneButton =
                ui.invisibleButton("##vote_zone_setup_exchange", actionBlockSize, ui.ButtonFlags.Disabled)
        local r1, r2 = ui.itemRect()

        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackgroundShade, 6 * cui.uiScale())

        local likeDelta = item.statLikes - item.statDislikes
        -- ui.setCursor(p)

        local liked = table.contains(likedSetups, itemID)
        local disliked = table.contains(dislikedSetups, itemID)

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
                        table.insert(likedSetups, itemID)
                        rest("PATCH", path .. "/" .. itemID, table.chain(contextTable, { direction = 1 }))
                        if disliked then
                                item.statDislikes = item.statDislikes - 1
                                table.removeItem(dislikedSetups, itemID)
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
                        table.removeItem(dislikedSetups, itemID)
                        rest("PATCH", path .. "/" .. itemID, contextTable)
                else
                        item.statDislikes = item.statDislikes + 1
                        table.insert(dislikedSetups, itemID)
                        rest("PATCH", path .. "/" .. itemID, table.chain(contextTable, { direction = -1 }))
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

local function commentsBlock()
        ui.setCursorX(0)
        cui.offsetCursorY(15)
        local item = discussingItem
        local comment = discussingComments[item.setupID] or ""
        local comments = refreshComments()
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
                local setupItemWidth = ui.windowWidth() - 10 * cui.uiScale()
                local actionBlockSize = vec2(ui.availableSpaceX() / 4 - 10 * cui.uiScale(), fontSpace)

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
                                if _ == #comments then loadMoreComments() end
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
                                        v.userID == ownUserID and settings.Appearance.uiColorYellow
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
                                        likedComments,
                                        dislikedComments,
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

                                ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackgroundShade, 6 * cui.uiScale())
                                ui.addIcon(ui.Icons.Chat, iconSize, iconAlign)

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

                                if v.userID == ownUserID then
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
                                                6 * cui.uiScale()
                                        )
                                        ui.addIcon(ui.Icons.Delete, iconSize, iconAlign)

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
                if scrollCommentsDown then ui.setScrollY(1e9, false, true) end
        end)

        local _, submitted
        comment, _, submitted = ui.inputText("Add a comment…", comment, ui.InputTextFlags.Placeholder)
        if ui.isWindowAppearing() or scrollCommentsDown then
                ui.setKeyboardFocusHere(-1)
                if #comments == commentsTotalCount or ui.windowScrolling() then scrollCommentsDown = false end
        end
        ui.sameLine(0, 4)
        local canSend = #comment:trim() > 0 and not currentlySubmittingComment and sessionID ~= nil
        if
                (
                        ui.button("Send", vec2(ui.availableSpaceX(), 0), canSend and 0 or ui.ButtonFlags.Disabled)
                        or submitted
                ) and canSend
        then
                currentlySubmittingComment = true
                rest(
                        "POST",
                        "comments",
                        { setupID = item.setupID, userName = stored.userName, data = comment:trim() },
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
        if ui.itemHovered() and sessionID == nil then ui.setTooltip(sessionError or "Connecting…") end
        discussingComments[item.setupID] = comment
end

local function searchFilterControls()
        ui.sameLine()
        cui.offsetCursorX(10)
        if authorUsernameFilter ~= "" then
                if
                        cui.menuButton(
                                string.format("by: %s ", authorUsernameFilter),
                                32,
                                ui.Alignment.Center,
                                ui.Alignment.Center
                        )
                then
                        authorUsernameFilter = ""
                        listOfSetups = nil
                        return
                end
                ui.addIcon(ui.Icons.Cancel, iconSize, vec2(0, 0.5), rgbm.colors.white)
        elseif searchFilter ~= "" then
                if
                        cui.menuButton(
                                "    Back",
                                vec2(40, 20) * cui.uiScale(),
                                ui.Alignment.Center,
                                ui.Alignment.Center
                        )
                then
                        searchFilter = ""
                        listOfSetups = nil
                        return
                end
                ui.addIcon(ui.Icons.ArrowLeft, iconSize, iconAlign, rgbm.colors.white)
        end
end

local function sortControls()
        cui.setCursorX(5)
        cui.setCursorY(5)

        -- local updated, _, enter = ui.inputText(
        --         "Name or author",
        --         searchFilter,
        --         bit.bor(ui.InputTextFlags.Placeholder, ui.InputTextFlags.CtrlEnterForNewLine)
        -- )
        -- if enter then
        --         searchFilter = updated
        --         listOfSetups = nil
        -- end

        ui.newLine()
end

local function userControls()
        ui.sameLine(0, 4)
        if ui.button("…") and v2 then
                ui.popup(function()
                        ui.text("Your name: " .. stored.userName)
                        if ui.selectable("Change name", false) then
                                ui.modalPrompt("Change name", "New name:", stored.userName, function(newName)
                                        if not newName or #newName:trim() == 0 then return end
                                        rest(
                                                "POST",
                                                "user",
                                                { userName = newName:trim() },
                                                function()
                                                        ui.toast(ui.Icons.Confirm, "Name changed")
                                                        stored.userName = newName:trim()
                                                        listOfSetups = nil
                                                end,
                                                function(err)
                                                        ui.toast(ui.Icons.Warning, "Couldn’t change name: " .. err)
                                                end
                                        )
                                end)
                        end
                        if ui.itemHovered() then
                                ui.setTooltip("Changing name would also change it for all published content")
                        end
                        ui.separator()
                        if ui.selectable("Your setups…") then
                                authorUsernameFilter = stored.userName
                                listOfSetups = nil
                        end
                end, { position = ui.windowPos() + ui.itemRectMin() + vec2(0, 20) })
        end
end

local selectedSetup = nil

function formatNumber(n)
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

local function drawSetupItem(i, v)
        local fontSize = style.main.font.small.size
        local fontSpace = style.main.font.small.space
        local setupItemWidth = ui.windowWidth() - 10 * cui.uiScale()
        local setupItemHeight = fontSpace * 4
        ui.setCursorX(0)
        ui.setCursorY((setupItemHeight + 5 * cui.uiScale()) * (i - 1))
        ui.pushID(v.setupID)

        local p = ui.getCursor()
        ui.dummy(vec2(setupItemWidth, setupItemHeight))
        local clicked = ui.itemClicked()
        local hovered = ui.itemHovered()
        local r1, r2 = ui.itemRect()
        local buttonColor = settings.Appearance.uiColorTextDim
        local fontColor = settings.Appearance.uiColorText
        local subFontColor = settings.Appearance.uiColorTextDim
        local borderThickness = 1 * cui.uiScale()

        if clicked then selectedSetup = v end
        local active = selectedSetup and v.setupID == selectedSetup.setupID

        if hovered and ui.mouseDoubleClicked(ui.MouseButton.Left) then
                selectedSetup = v

                currentlyApplying = true
                getSetupData(selectedSetup, true, function(err, data)
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
                borderThickness = 5 * cui.uiScale()
                buttonColor = settings.Appearance.uiColorAccent
        elseif hovered then
                borderThickness = 5 * cui.uiScale()
                buttonColor = settings.Appearance.uiColorSecondary
        end

        ui.drawRect(r1, r2, buttonColor, 6 * cui.uiScale(), ui.CornerFlags.All, borderThickness)

        ui.setCursor(r1)
        cui.offsetCursorY(fontSpace / 6)
        cui.setCursorX(15)
        cui.snapCursor()
        style:pushFontBold()
        ui.dwriteTextAligned(
                v.trackID .. " / " .. v.name:trim(),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(setupItemWidth, fontSpace),
                false,
                fontColor
        )
        ui.popDWriteFont()

        cui.offsetCursorY(fontSpace / 6)
        cui.setCursorX(15)
        local usernameButtonSize =
                vec2(ui.measureDWriteText(string.format("%s....", v.userName), fontSize).x, fontSpace)

        local usernameClicked = ui.invisibleButton("##username_button_" .. v.userName, usernameButtonSize)
        local r1, r2 = ui.itemRect()
        ui.drawRectFilled(
                r1,
                r2,
                v.userID == ownUserID and settings.Appearance.uiColorYellow
                        or settings.Appearance.uiColorBackgroundShade,
                6 * cui.uiScale()
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
                v.userID == ownUserID and settings.Appearance.uiColorTextDim or settings.Appearance.uiColorText
        )
        ui.sameLine()

        cui.offsetCursorX(10)
        cui.snapCursor()
        ui.dwriteTextAligned(
                timeAgo(v.createdDate),
                style.main.font.small.size,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX() - 10 * cui.uiScale(), fontSpace),
                false,
                subFontColor
        )
        ui.sameLine()
        ui.setCursorX(0)

        cui.offsetCursorX(-10)
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

        local actionBlockSize = vec2(ui.availableSpaceX() / 4 - 10 * cui.uiScale(), fontSpace)
        cui.setCursorX(15)

        likeButtons("likes", v, likedSetups, dislikedSetups, v.setupID, { carID = v.carID })

        ui.sameLine()
        cui.offsetCursorX(5)

        local hasComments = v.statComments > 0
        local commentsClicked = ui.invisibleButton("##setup_exchange_comments_" .. v.setupID, actionBlockSize)
        local commentsColor = rgbm.colors.gray * 0.7
        local r1, r2 = ui.itemRect()
        ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackgroundShade, 6 * cui.uiScale())

        if ui.itemHovered() then
                commentsColor = settings.Appearance.uiColorSecondary
        elseif hasComments then
                commentsColor = settings.Appearance.uiColorText
        end

        if commentsClicked then
                if discussingItem == v then
                        discussingItem = nil
                else
                        discussingItem = v
                        listOfComments = nil
                        listOfCommentsPrev = nil
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
                ui.drawRectFilled(r1, r2, settings.Appearance.uiColorBackgroundShade, 6 * cui.uiScale())

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
                        selectedSetup = v

                        currentlyApplying = true
                        getSetupData(selectedSetup, true, function(err, data)
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

        if discussingItem == v then commentsBlock() end

        ui.popID()
end

-- discussingItem = {
--         createdDate = 1654857628,
--         name = "FROM AL1qx",
--         userName = "STZ",
--         statLikes = 327,
--         statDislikes = 13,
--         carID = "lotus_exos_125_s1",
--         trackID = "monza",
--         statComments = 8,
--         setupID = 23,
--         statDownloads = 26788,
--         userID = "DEUHXI9dgCmo1GTVCWnAozlsU6SaObI+0NprxiUvyxU=",
-- }

local function setupsListWindow(setups)
        ui.setCursor(0)

        if discussingItem then
                drawSetupItem(1, discussingItem)
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
                                vec2(ui.windowWidth(), 28 * cui.uiScale()),
                                false,
                                settings.Appearance.uiColorTextDim
                        )

                        return
                end

                local fontSpace = style.main.font.small.space
                local setupItemHeight = fontSpace * 4 + 5 * cui.uiScale()

                local f = 1 + math.floor(ui.getScrollY() / setupItemHeight)
                local t = 2 + math.floor((ui.getScrollY() + ui.windowHeight()) / setupItemHeight)

                if t > #setups then loadMoreSetups() end
                for i = f, math.min(t, #setups) do
                        local v = setups[i]

                        if v then drawSetupItem(i, v) end
                end

                ui.setMaxCursorY(math.max(setupsTotalCount, #setups) * setupItemHeight)
        end)
end

local function shareSetupButton()
        local iconButtonHeight = 32 * cui.uiScale()
        local buttonWidth = ui.windowWidth() * 0.99
        local groupBegin = (ui.windowWidth() / 24)
        local fontSize = style.main.font.body.size

        cui.offsetCursorY(100)

        -- if ac.isSetupAvailableToEdit() and selectedSetup and selectedSetup.carID == mainCarID then
        --         ui.setCursorX(ui.windowWidth() * 0.005)
        --         if
        --                 cui.menuButton(
        --                         "Download Setup",
        --                         vec2(buttonWidth * 0.49, iconButtonHeight),
        --                         nil,
        --                         nil,
        --                         (selectedSetup and downloadedAsFiles[selectedSetup.setupID]) and ui.ButtonFlags.Active
        --                                 or not currentlyApplying and 0
        --                                 or ui.ButtonFlags.Disabled,
        --                         false,
        --                         false
        --                 )
        --         then
        --                 downloadSetupAsFile(selectedSetup)
        --         end

        -- else
        --         ui.setCursorX(ui.windowWidth() * 0.005)
        --         if
        --                 cui.menuButton(
        --                         "Download Setup",
        --                         vec2(buttonWidth, iconButtonHeight),
        --                         nil,
        --                         nil,
        --                         (selectedSetup and currentlyApplying) and 0 or ui.ButtonFlags.Disabled,
        --                         false,
        --                         false
        --                 )
        --         then
        --                 downloadSetupAsFile(selectedSetup)
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
        if ui.itemHovered() and sessionID == nil then ui.setTooltip(sessionError or "Connecting…") end
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
        local iconButtonHeight = 32 * cui.uiScale()
        local buttonWidth = ui.windowWidth() * 0.99
        local groupBegin = (ui.windowWidth() / 24)
        local fontSize = style.main.font.body.size
        local comboSize = vec2((ui.windowWidth() - 20 * cui.uiScale()) * 0.5, 32 * cui.uiScale())

        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackgroundShade, 6 * cui.uiScale())

        cui.offsetCursorX(10)
        cui.setCursorY(10)
        local textInputWidth = ui.windowWidth() * 0.25
        ui.drawRectFilled(
                ui.getCursor(),
                ui.getCursor() + comboSize,
                settings.Appearance.uiColorBackground * 0.25,
                6 * cui.uiScale()
        )
        ui.drawRect(
                ui.getCursor(),
                ui.getCursor() + comboSize,
                settings.Appearance.uiColorText * 0.75,
                6 * cui.uiScale()
        )

        newSearchFilter = cui.inputText("##controlsSearcher", comboSize, "", newSearchFilter, "Search setups...", "")

        if searchFilter ~= newSearchFilter then
                searchFilter = newSearchFilter
                listOfSetups = nil
        end

        ui.sameLine()
        ui.setCursorX(comboSize.x)
        ui.icon(ui.Icons.ZoomIn, 32 * cui.uiScale(), rgbm.colors.gray, 32 * cui.uiScale() * 0.5)

        ui.sameLine()
        ui.setCursorX(ui.windowWidth() * 0.5 + 10 * cui.uiScale())

        cui.combo(
                "##sort_setup_exchange",
                comboSize,
                setupsOrder[stored.setupsOrder][1],
                ui.Alignment.Start,
                true,
                vec2(comboSize.x, comboSize.y * (#setupsOrder + 2)),
                function()
                        cui.offsetCursorX(25)
                        cui.offsetCursorY(15)
                        local showTracksChanged = false
                        local showTracksValue = not stored.setupsFilterTrack
                        showTracksValue, showTracksChanged = drawCheckbox(
                                "##setup_exchange_show_current_track",
                                "Show All Tracks",
                                style.main.font.small.size,
                                showTracksValue
                        )

                        if showTracksChanged then
                                stored.setupsFilterTrack = not showTracksValue
                                listOfSetups = nil
                        end

                        cui.offsetCursorY(15)

                        for i, v in ipairs(setupsOrder) do
                                cui.setCursorX(15)
                                if
                                        cui.menuButton(
                                                v[1],
                                                vec2(ui.windowWidth() - 30 * cui.uiScale(), comboSize.y),
                                                ui.Alignment.Center
                                        )
                                then
                                        stored.setupsOrder = i
                                        listOfSetups = nil
                                end
                        end

                        cui.offsetCursorY(15)
                end
        )
end

local function windowGeneric(paddingDown)
        local setups = refreshSetups()
        if not setups then
                ui.drawLoadingSpinner(ui.windowSize() / 2 - 20, ui.windowSize() / 2 + 20)
                initialLoading()
                return
        end

        if type(setups) == "string" then
                failureBlock(setups)
                return
        end

        local filterSpaceSize = 5 * cui.uiScale()

        if not discussingItem then
                filterSpaceSize = 50 * cui.uiScale()
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
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackground, 6 * cui.uiScale())
        sortControls()
        -- searchFilterControls()
        -- userControls()
        -- commentsBlock()

        setupsListWindow(setups)
        cui.popWindow()

        -- cui.pushWindow("setup_exchange_io", 0, ui.windowHeight() * 0.75, ui.windowWidth(), ui.windowHeight() * 0.25)
        -- shareSetupButton()

        -- cui.popWindow()
end

local introHeight = 100

function setupExchange:draw() windowGeneric() end

return setupExchange
