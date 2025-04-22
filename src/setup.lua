local setup = {
        current = "generic/default",
        loaded = {},

        selected = { name = "", track = "", description = "", path = "", lastWriteTime = "" },
        input = { name = "", track = ac.getTrackID(), description = "", path = "", lastWriteTime = "" },
}

function setup:getFiles() end

function setup:load()
        for track, _ in pairs(loadedSetups) do
                for i in ipairs(loadedSetups[track]) do
                        loadedSetups[track][i] = nil
                end
                loadedSetups[track] = nil
        end

        trackSortedSetups = {}

        loadedSetups[ac.getTrackID()] = {}

        io.scanDir(setupsDir, function(dirName)
                if settings.General.hideOtherTrackSetups then
                        if dirName ~= ac.getTrackID() and dirName ~= "generic" then return end
                end

                if string.find(dirName, ".sp") or string.find(dirName, ".ini") or string.find(dirName, ".txt") then
                        return
                end

                if loadedSetups[dirName] == nil then loadedSetups[dirName] = {} end

                io.scanDir(setupsDir .. "\\" .. dirName, function(fileName, fileAttributes)
                        if string.find(fileName, ".sp") or string.find(fileName, ".txt") then return end

                        table.insert(loadedSetups[dirName], {
                                name = fileName,
                                track = dirName,
                                path = setupsDir .. "\\" .. dirName .. "\\" .. fileName,
                                lastWriteTime = fileAttributes.lastWriteTime,
                        })
                end)
        end)

        for track, setupList in pairs(loadedSetups) do
                table.sort(setupList, function(a, b) return a.lastWriteTime > b.lastWriteTime end)
        end

        -- Create a sorted list of track names
        for track in pairs(loadedSetups) do
                table.insert(trackSortedSetups, track)
        end
        table.sort(trackSortedSetups)
        table.removeItem(trackSortedSetups, "generic")
        table.insert(trackSortedSetups, 1, "generic")
        table.removeItem(trackSortedSetups, ac.getTrackID())
        table.insert(trackSortedSetups, 1, ac.getTrackID())
end

function setup:save()
        ac.setActiveSetupName(saveSetup.name, saveSetup.track)
        sm:saveSetup(saveSetup.path)

        currentSetup = saveSetup.track .. "/" .. saveSetup.name
        selectedSetup = table.clone(saveSetup, true)

        loadSetups()
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
