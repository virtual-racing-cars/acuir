local cui = require("ui.cui")

if not string.urlEncode then
        string.urlEncode = function(str)
                str = string.gsub(str, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
                str = string.gsub(str, " ", "+")
                return str
        end
end

local setupExchangeAPI = {
        searchFilter = "",
        authorUsernameFilter = "",
        listOfSetups = nil,
        listOfComments = nil,
        listOfSetupsPrev = nil,
        listOfCommentsPrev = nil,
        downloadedSetups = {},
        setupTooltips = {},
        likedSetups = {},
        downloadedAsFiles = {},
        removingIDs = {},
        dislikedSetups = {},
        discussingItem = nil,
        discussingComments = {},
        likedComments = {},
        dislikedComments = {},
        listOfSetupsContinuation = nil,
        setupsTotalCount = 0,
        listOfCommentsContinuation = nil,
        commentsTotalCount = 0,
        scrollCommentsDown = false,
        ownUserID = nil,
        selectedSetup = nil,
        currentlyApplying = false,
        currentlySubmittingComment = false,
        initializing = false,
        session = { userKey = nil, id = nil, error = nil, cooldown = 0 },
        stored = ac.storage({
                introduced = false,
                userName = "",
                setupsFilterTrack = true,
                setupsOrder = 1,
        }),
        setupsOrder = {
                {
                        "Hot",
                        "(statDislikes*200-statLikes*20-statDownloads-statComments*2)*1e6/sqrt(max(60.0,@now-createdDate)/60)",
                },
                { "Popular", "-statDownloads" },
                { "Liked", "statDislikes-statLikes*2" },
                { "Newest", "-createdDate" },
                { "Title", "name" },
        },
}

local endpoint = "http://se.acstuff.club"
local mainCarID = ac.getCarID(0)

local temporaryName = ac.getFolder(ac.FolderID.AppDataLocal) .. "/Temp/ac-se-shared.ini"
local temporaryBackupName = ac.getFolder(ac.FolderID.AppDataLocal) .. "/Temp/ac-se-backup.ini"

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

local limit = 40

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

if #setupExchangeAPI.stored.userName == 0 then setupExchangeAPI.stored.userName = ac.getDriverName(0) or "User" end

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

---@param callback fun(err: string?, sessionData: {sessionID: string, userID: string, likes: string, dislikes: string}?, userKey: string?)
function setupExchangeAPI:createSession(callback)
        ac.uniqueMachineKeyAsync(function(err, data)
                if err then
                        callback(err)
                        return
                end

                local userID = ac.checksumSHA256("LB83XurHhTPhpmTc" .. data)

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

                                        if type(parsed) ~= "table" or not parsed.key then
                                                callback("Server is not working correctly")
                                                return
                                        end

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
                                                                                local parsed = JSON.parse(response.body)
                                                                                if
                                                                                        type(parsed) == "table"
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
                                end
                        end
                )
        end)
end

---@type string? string?, string?, number
function setupExchangeAPI:tryRecreateSession()
        if os.preciseClock() < self.session.cooldown then return end
        self.session.cooldown = os.preciseClock() + 2
        self:createSession(function(err, session, newUserKey)
                if newUserKey then
                        self.session.userKey = newUserKey
                elseif err then
                        self.session.error, self.session.id = tostring(err), nil
                        ac.error("Failed to create a session: " .. tostring(err))
                else
                        self.session.error, self.session.id, self.ownUserID = nil, session.sessionID, session.userID
                        ac.log("New session: " .. session.sessionID .. ", user ID: " .. self.ownUserID)
                        table.clear(self.likedSetups)
                        table.clear(self.dislikedSetups)
                        for i, v in ipairs(session.likes:split(";", nil, false, true)) do
                                self.likedSetups[i] = tonumber(v, 36)
                        end
                        for i, v in ipairs(session.dislikes:split(";", nil, false, true)) do
                                self.dislikedSetups[i] = tonumber(v, 36)
                        end
                end
        end)
end

setupExchangeAPI:tryRecreateSession()

function setupExchangeAPI:rest(method, url, data, callback, errorHandler)
        if not self.session.id and not self.session.userKey and (method ~= "GET" or url ~= "setups") then
                setTimeout(function() self:rest(method, url, data, callback, errorHandler) end, 0.5)
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
                        [self.session.userKey and "X-User-Key" or "X-Session-ID"] = self.session.userKey
                                or self.session.id
                                or "0",
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
                                if err == "Invalid session ID" then self:tryRecreateSession() end
                                return errorHandler(err)
                        end

                        try(function() callback(JSON.parse(response.body), response.headers) end, errorHandler)
                end
        )
end

function setupExchangeAPI:initialLoading()
        if self.initializing then return end
        self.initializing = true
        self:rest("GET", "user", {
                carID = mainCarID,
                carName = ac.getCarName(0),
                trackID = ac.getTrackID(),
                trackName = ac.getTrackName(),
        }, function(response)
                self.ownUserID = response.userID or error("UserID is missing")
                ac.log("My user ID: " .. self.ownUserID)
        end, function(err) ac.warn("Failed to get own user ID: " .. err) end)
        self:rest("GET", "likes", { carID = mainCarID }, function(data)
                for _, v in ipairs(data) do
                        table.insert(v.direction == 1 and self.likedSetups or self.dislikedSetups, v.setupID)
                end
        end)
end

function setupExchangeAPI:shareSetup(name)
        ac.saveCurrentSetup(temporaryName)
        self:rest("POST", "setups", {
                carID = mainCarID,
                trackID = ac.getTrackID(),
                name = name,
                userName = setupExchangeAPI.stored.userName,
                data = io.load(temporaryName),
        }, function(response)
                ui.toast(ui.Icons.Settings, "Setup shared", function() self:removeSetup(response.setupID) end)
                self.listOfSetups = nil
        end, function(err) ui.toast(ui.Icons.Warning, "Failed to share setup: " .. err) end)
end

function setupExchangeAPI:removeSetup(id, withUndo)
        if self.removingIDs[id] then return end
        self.removingIDs[id] = true
        self:rest("DELETE", "setups/" .. id, nil, function()
                ui.toast(ui.Icons.Delete, "Shared setup removed", withUndo and function()
                        self:rest(
                                "POST",
                                "setups-restore/" .. id,
                                nil,
                                function() self.listOfSetups = nil end,
                                function(err) ui.toast(ui.Icons.Warning, "Failed to restore setup: " .. err) end
                        )
                end or nil)
                self.listOfSetups = nil
                self.removingIDs[id] = nil
        end, function(err)
                ui.toast(ui.Icons.Warning, "Failed to remove setup: " .. err)
                self.removingIDs[id] = nil
        end)
end

function setupExchangeAPI:refreshGenList(uniqueKey, url, params, callback, continuationState)
        self:rest(
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
                                                self:refreshGenList(uniqueKey, url, params, nil, continuationState)
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

function setupExchangeAPI:getSetupData(setupInfo, incrementDownloads, callback)
        local cached = self.downloadedSetups[setupInfo.setupID]
        if cached and (cached.data or cached.err) then
                if incrementDownloads and not cached.incremented then
                        cached.incremented = true
                        setupInfo.statDownloads = setupInfo.statDownloads + 1
                        self:rest("POST", "setup-download-counts/" .. setupInfo.setupID)
                end
                callback(cached.err, cached.data)
        elseif cached then
                table.insert(cached, callback)
        else
                self.downloadedSetups[setupInfo.setupID] = { callback }
                self:rest("GET", "setups/" .. setupInfo.setupID, nil, function(response)
                        if incrementDownloads then
                                setupInfo.statDownloads = setupInfo.statDownloads + 1
                                self:rest("POST", "setup-download-counts/" .. setupInfo.setupID)
                        end
                        local list = self.downloadedSetups[setupInfo.setupID]
                        self.downloadedSetups[setupInfo.setupID] =
                                { data = response.data, incremented = incrementDownloads }
                        for _, v in ipairs(list) do
                                v(nil, response.data)
                        end
                end, function(err)
                        local list = self.downloadedSetups[setupInfo.setupID]
                        self.downloadedSetups[setupInfo.setupID] = { err = err, incremented = true }
                        for _, v in ipairs(list) do
                                v(err, nil)
                        end
                end)
        end
end

function setupExchangeAPI:refreshSetups()
        if not self.listOfSetups then
                local key = math.random()
                self.listOfSetups, self.listOfSetupsContinuation = key, nil
                self:refreshGenList("setupID", "setups", {
                        carID = self.authorUsernameFilter == "" and mainCarID or nil,
                        trackID = self.authorUsernameFilter == ""
                                        and setupExchangeAPI.stored.setupsFilterTrack
                                        and ac.getTrackID()
                                or nil,
                        userName = self.authorUsernameFilter ~= "" and self.authorUsernameFilter or nil,
                        search = self.authorUsernameFilter == "" and self.searchFilter ~= "" and self.searchFilter
                                or nil,
                        orderBy = self.setupsOrder[setupExchangeAPI.stored.setupsOrder][2],
                }, function(ret, continuation, totalCount)
                        if self.listOfSetups == key then
                                self.listOfSetups = ret
                                self.listOfSetupsPrev = ret
                                self.listOfSetupsContinuation = continuation and { ret, continuation }
                                self.setupsTotalCount = totalCount or 0
                        end
                end)
        end
        return (type(self.listOfSetups) == "table" or type(self.listOfSetups) == "string") and self.listOfSetups
                or self.listOfSetupsPrev
end

function setupExchangeAPI:loadMoreSetups()
        if
                type(self.listOfSetups) == "table"
                and self.listOfSetupsContinuation
                and self.listOfSetupsContinuation[1] == self.listOfSetups
        then
                self.listOfSetupsContinuation[2]()
        end
end

function setupExchangeAPI:applySetup(setup)
        local applied = false

        self.selectedSetup = setup
        self.currentlyApplying = true
        self:getSetupData(self.selectedSetup, true, function(err, data)
                self.currentlyApplying = false
                if err then
                        cui.menuBanner("Failed to load setup", nil, rgbm.colors.red)
                else
                        ac.saveCurrentSetup(temporaryBackupName)

                        io.save(temporaryName, data)
                        ac.loadSetup(temporaryName)

                        cui.menuBanner("Setup applied", nil, rgbm.colors.green)

                        applied = true
                end
        end)

        return applied
end

function setupExchangeAPI:refreshComments()
        if not self.listOfComments then
                local key = math.random()
                self.listOfComments = key
                self:refreshGenList(
                        "commentID",
                        "comments",
                        { setupID = self.discussingItem.setupID },
                        function(ret, continuation, totalCount)
                                if self.listOfComments == key then
                                        self.listOfComments = ret
                                        self.listOfCommentsPrev = ret
                                        self.scrollCommentsDown = true
                                        self.listOfCommentsContinuation = continuation and { ret, continuation }
                                        self.commentsTotalCount = totalCount or 0
                                end
                        end
                )
                table.clear(self.likedComments)
                table.clear(self.dislikedComments)
                self:rest("GET", "comment-likes", { setupID = self.discussingItem.setupID }, function(data)
                        for _, v in ipairs(data) do
                                table.insert(
                                        v.direction == 1 and self.likedComments or self.dislikedComments,
                                        v.commentID
                                )
                        end
                end)
        end
        return (type(self.listOfComments) == "table" or type(self.listOfComments) == "string") and self.listOfComments
                or self.listOfCommentsPrev
end

function setupExchangeAPI:loadMoreComments()
        if
                type(self.listOfComments) == "table"
                and self.listOfCommentsContinuation
                and self.listOfCommentsContinuation[1] == self.listOfComments
        then
                self.listOfCommentsContinuation[2]()
        end
end

function setupExchangeAPI:removeComment(id, withUndo)
        self:rest(
                "DELETE",
                "comments/" .. id,
                nil,
                function() self.listOfComments = nil end,
                function(err) ui.toast(ui.Icons.Warning, "Failed to remove comment: " .. err) end
        )
end

return setupExchangeAPI
