local settings = require("src.settings")

local setup = {
        current = "generic/default",
        loaded = {},
        loadedSorted = {},
        selected = { name = "", track = "", description = "", path = "", lastWriteTime = "" },
        input = { name = "", track = ac.getTrackID(), description = "", path = "", lastWriteTime = "" },
}

local setupsDir = ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0)

function setup:getFiles() end

function setup:load()
        for track, _ in pairs(setup.loaded) do
                for i in ipairs(setup.loaded[track]) do
                        setup.loaded[track][i] = nil
                end
                setup.loaded[track] = nil
        end

        for track, _ in pairs(setup.loadedSorted) do
                setup.loadedSorted[track] = nil
        end

        setup.loaded[ac.getTrackID()] = {}

        io.scanDir(setupsDir, function(dirName)
                if settings.General.hideOtherTrackSetups then
                        if dirName ~= ac.getTrackID() and dirName ~= "generic" then return end
                end

                if string.find(dirName, ".sp") or string.find(dirName, ".ini") or string.find(dirName, ".txt") then
                        return
                end

                if setup.loaded[dirName] == nil then setup.loaded[dirName] = {} end

                io.scanDir(setupsDir .. "\\" .. dirName, function(fileName, fileAttributes)
                        if string.find(fileName, "%.sp") or string.find(fileName, "%.txt") then return end

                        table.insert(setup.loaded[dirName], {
                                name = fileName,
                                track = dirName,
                                path = setupsDir .. "\\" .. dirName .. "\\" .. fileName,
                                lastWriteTime = fileAttributes.lastWriteTime,
                        })
                end)
        end)

        for _, setupList in pairs(setup.loaded) do
                table.sort(setupList, function(a, b) return a.lastWriteTime > b.lastWriteTime end)
        end

        -- Create a sorted list of track names
        for track in pairs(setup.loaded) do
                table.insert(setup.loadedSorted, track)
        end
        table.sort(setup.loadedSorted)
        table.removeItem(setup.loadedSorted, "generic")
        table.insert(setup.loadedSorted, 1, "generic")
        table.removeItem(setup.loadedSorted, ac.getTrackID())
        table.insert(setup.loadedSorted, 1, ac.getTrackID())
end

ac.onSetupsListRefresh(function() setup:load() end)

setup:load()

function setup:save(sm)
        ac.setActiveSetupName(setup.input.name, setup.input.track)
        sm:saveSetup(setup.input.path)

        setup.current = setup.input.track .. "/" .. setup.input.name
        setup.selected = table.clone(setup.input, true)

        setup:load()
end

function setup:delete()
        if not io.fileExists(setup.input.path) then return end

        io.deleteFile(setup.input.path)
        io.deleteFile(string.trim(setup.input.path, ".ini") .. ".sp")

        setup.input.name = ""
        setup.input.path = ""

        setup.selected = { name = "", track = "", path = "", lastWriteTime = "" }

        setup:load()
end

return setup
