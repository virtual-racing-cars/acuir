local app = require("app")
local settings = require("src.settings")
local sim = ac.getSim()

local setup = {
        current = "generic/default",
        loaded = {},
        trackList = {},
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

        for track, _ in pairs(setup.trackList) do
                setup.trackList[track] = nil
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
                table.insert(setup.trackList, track)
        end

        table.sort(setup.trackList)
        table.removeItem(setup.trackList, "generic")
        table.insert(setup.trackList, 1, "generic")
        table.removeItem(setup.trackList, ac.getTrackID())
        table.insert(setup.trackList, 1, ac.getTrackID())

        for i = #setup.trackList, 3, -1 do
                local track = setup.trackList[i]
                if setup.loaded[track] and #setup.loaded[track] == 0 then table.removeItem(setup.trackList, track) end
        end
end

ac.onSetupsListRefresh(function() setup:load() end)

setup:load()

setTimeout(function()
        if settings.General.autoLoadLastSetup and app.state.appOpen then
                local lastSetupFile = string.format(
                        "%s\\%s\\_%s_last.ini",
                        ac.getFolder(ac.FolderID.UserSetups),
                        ac.getCarID(0),
                        ac.getTrackID()
                )

                if not io.fileExists(lastSetupFile) then return end

                sm:LoadStuff(lastSetupFile)

                setup.current = ac.getTrackID() .. "/last"
        end
end, 1, "autoLoadLastSetup")

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

local isInMainMenuLast = sim.isInMainMenu

function setup:step()
        if isInMainMenuLast ~= sim.isInMainMenu then
                if isInMainMenuLast then sm:saveSetup(string.format("_%s_last.ini", ac.getTrackID())) end

                isInMainMenuLast = sim.isInMainMenu
        end
end

return setup
