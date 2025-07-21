local app = require("app")
local callback = require("callback")
local ioext = require("shared.utils.ioext")
local signing = require("shared.utils.signing")

local updater = {
        list = {},
}

local function findupdaterRootDir(initialDir, targetDir)
        local foundDir = nil

        io.scanDir(initialDir, "*", function(fileName, fileAttributes, callbackData)
                local recurFolder = initialDir .. "\\" .. fileName
                ac.error(targetDir)
                if io.dirExists(recurFolder) then
                        if fileName == targetDir or fileName == targetDir .. "-beta" then
                                foundDir = recurFolder
                                return
                        else
                                foundDir = findupdaterRootDir(recurFolder, targetDir)

                                if foundDir then return end
                        end
                end
        end)

        return foundDir
end

local function deleteRemoteDir(remoteRootDir)
        io.scanDir(remoteRootDir, "*", function(fileName, fileAttributes, callbackData)
                local recurFolder = remoteRootDir .. "\\" .. fileName
                if io.dirExists(recurFolder) then
                        deleteRemoteDir(recurFolder)
                        io.deleteDir(recurFolder)
                elseif io.fileExists(recurFolder) then
                        io.deleteFile(recurFolder)
                end
        end)
        io.deleteDir(remoteRootDir)
end

function io.scanDirRecursive(baseDir, mask, callback, data, relPath)
        relPath = relPath or ""
        local currentDir = relPath == "" and baseDir or (baseDir .. "/" .. relPath)
        return io.scanDir(currentDir, mask or "*", function(name, attr)
                local newRelPath = relPath == "" and name or (relPath .. "/" .. name)
                local fullPath = baseDir .. "/" .. newRelPath
                if attr.isDirectory then
                        local result = io.scanDirRecursive(baseDir, mask, callback, data, newRelPath)
                        if result ~= nil then return result end
                else
                        local result = callback(newRelPath, attr, fullPath, data)
                        if result ~= nil then return result end
                end
        end, data)
end

local filesToUpdate = {}

local function removeBeforeSlash(str) return str:match("^.-/(.*)") or str end

function updater:installUpdate(id, name, reason, downloadURL, cleanInstall)
        if app.state.debug then return end

        filesToUpdate = {}
        local localAppDir = string.format("%s\\%s", ac.getFolder(ac.FolderID.ACAppsLua), id)

        web.loadRemoteAssets(downloadURL, function(err, remoteDir)
                if err then
                        ac.error(err)
                        return
                end

                ioext.scanDirRec(remoteDir, "*", function(relativeFilename, attrs)
                        local fileAbsolutePath = remoteDir .. "/" .. relativeFilename
                        if io.fileExists(fileAbsolutePath) then table.insert(filesToUpdate, relativeFilename) end
                end)

                table.insert(filesToUpdate, "manifest.ini")

                callback.update = function()
                        if #filesToUpdate == 0 then
                                ac.log("%s updated successfully" % id)
                                deleteRemoteDir(remoteDir)
                                callback.update = nil
                                return
                        end

                        local fileToUpdate = filesToUpdate[1]
                        local fileToUpdateNewPath = localAppDir .. "\\" .. removeBeforeSlash(fileToUpdate)

                        io.createFileDir(fileToUpdateNewPath)
                        io.copyFile(remoteDir .. "\\" .. fileToUpdate, fileToUpdateNewPath, false)

                        table.remove(filesToUpdate, 1)
                end
        end)
end

local endpoint = "https://api.github.com"

local retryRestCount = 0
function updater:rest(method, url, data, callback, errorHandler)
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
                        ["User-Agent"] = "MyLuaClient", -- required by GitHub API
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
                                if err == "Invalid session ID" then
                                        self:tryRecreateSession()

                                        if retryRestCount < 3 then
                                                setTimeout(
                                                        function() self:rest(method, url, data, callback, errorHandler) end,
                                                        0.5,
                                                        "retryRest"
                                                )
                                                retryRestCount = retryRestCount + 1
                                        end
                                else
                                        retryRestCount = 0
                                end

                                return errorHandler(err)
                        end

                        try(function() callback(JSON.parse(response.body), response.headers) end, errorHandler)
                end
        )
end

function updater:checkForUpdate()
        updater:rest("GET", "repos/virtual-racing-cars/acuir/tags", nil, function(tags)
                local latestBeta, latestRelease = nil, nil

                for _, tag in ipairs(tags) do
                        if not latestBeta and tag.name:find("-beta$") then
                                latestBeta = tag.name
                        elseif not latestRelease and tag.name:find("-release$") then
                                latestRelease = tag.name
                        end
                        if latestBeta and latestRelease then break end
                end

                if latestBeta then
                        local zipBeta = "https://github.com/virtual-racing-cars/acuir/archive/refs/tags/"
                                .. latestBeta
                                .. ".zip"

                        if string.versionCompare(latestBeta, app.version .. "-beta") > 0 then
                                updater:installUpdate("acuir", "ACUIR", "Update", zipBeta, true)
                        end
                else
                        ac.warn("No beta tag found")
                end

                if latestRelease then
                        local zipRelease = "https://github.com/virtual-racing-cars/acuir/archive/refs/tags/"
                                .. latestRelease
                                .. ".zip"
                else
                        ac.warn("No release tag found")
                end
        end, function(err) ac.warn("Failed to fetch tags: " .. err) end)
end

updater:checkForUpdate()

return updater
