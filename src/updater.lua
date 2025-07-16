local ioext = require("shared.utils.ioext")
local signing = require("shared.utils.signing")

local mod = {
        list = {},
}

local function findModRootDir(initialDir, targetDir)
        local foundDir = nil

        io.scanDir(initialDir, "*", function(fileName, fileAttributes, callbackData)
                local recurFolder = initialDir .. "\\" .. fileName
                if io.dirExists(recurFolder) then
                        if fileName == targetDir then
                                foundDir = recurFolder
                                return
                        else
                                foundDir = findModRootDir(recurFolder, targetDir)

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

local function getFilesList(directory)
        local filesList = {}

        ioext.scanDirRec(directory, "*", function(relativeFilename, attrs)
                local fileAbsolutePath = directory .. "/" .. relativeFilename
                if io.fileExists(fileAbsolutePath) then table.insert(filesList, relativeFilename) end
        end)

        return filesList
end

function mod:installUpdate(id, name, reason, downloadURL, cleanInstall)
        local localAppDir = string.format("%s\\%s", ac.getFolder(ac.FolderID.ACAppsLua), id)

        if not cleanInstall and io.dirExists(localAppDir) then
                table.insert(self.list, id)
                ac.log("%s already installed" % name)
                return
        end

        web.loadRemoteAssets(downloadURL, function(err, remoteDir)
                if err then
                        ac.error(err)
                        return
                end

                local remoteAppDir = findModRootDir(remoteDir, id)

                if not remoteAppDir then
                        ac.warn("%s app failed to download" % id)
                        return
                end

                signing.verify(getFilesList(remoteAppDir), function(downloadedFingerprint)
                        if localAppDir then ac.uninstallApp(id) end
                        io.move(remoteAppDir, localAppDir)

                        signing.verify(getFilesList(localAppDir), function(installedFingerprint)
                                if downloadedFingerprint == installedFingerprint then
                                        ac.log("%s app installed" % name)
                                        deleteRemoteDir(remoteDir)
                                        ac.noticeNewApp(id)
                                else
                                        ac.warn("%s app failed to install properly" % id)
                                end
                        end)
                end)
        end)
end

-- mod:installMod(
--         "telemetrick",
--         "Telemetrick",
--         "Testing",
--         "https://github.com/WilliamGawlik/toolbox/releases/download/v0.0.1/telemetrick.zip",
--         false
-- )

return mod
