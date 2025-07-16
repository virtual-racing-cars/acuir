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
                        if fileName == targetDir or fileName == targetDir .. "-beta" then
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

function mod:installUpdate(id, name, reason, downloadURL, cleanInstall)
        local localAppDir = string.format("%s\\%s", ac.getFolder(ac.FolderID.ACAppsLua), id)

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
                        io.scanDirRecursive(remoteAppDir, nil, function(fileName, fileAttributes, callbackData)
                                -- ac.log(fileName)

                                if
                                        fileName ~= "manifest.ini"
                                        and fileName ~= "src/updater.lua"
                                        and fileName ~= "acuir.lua"
                                then
                                        io.createFileDir(localAppDir .. "\\" .. fileName)

                                        io.copyFile(
                                                remoteAppDir .. "\\" .. fileName,
                                                localAppDir .. "\\" .. fileName,
                                                false
                                        )
                                end
                        end, function() end)

                        -- io.move(remoteAppDir .. "\\" .. "manifest.ini", localAppDir .. "\\" .. "manifest.ini", true)

                        ac.log("%s ACUIR updated successfully" % id)
                        deleteRemoteDir(remoteDir)
                end)
        end)
end

mod:installUpdate(
        "acuir",
        "ACUIR",
        "Update",
        "https://github.com/virtual-racing-cars/adv_setup/archive/refs/tags/beta.zip",
        true
)

return mod
