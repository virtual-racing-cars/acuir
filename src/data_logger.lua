local motec = require("shared\\sim\\motec")
local toggleLogButton = ac.ControlButton("__APP_CSP_DATA_LOGGER_TOGGLE")
local vec2Temp1 = vec2()

local dataLogger =
        { settings = ac.storage({ autoLog = false, dropShortLogTime = 30, fadeApp = false, fadeStatus = false }) }
local dataCollector = motec.TelemetryCollector(0)

function dataLogger:getMotecDirectory(carIndex)
        return string.format(
                "%s/telemetry/%s/%s",
                ac.getFolder(ac.FolderID.ACDocuments),
                ac.getTrackID(),
                ac.getCarID(carIndex)
        )
end

function dataLogger:getMotecFilename(carIndex)
        local prefix = string.format(
                "%s/%s_&_%s_&_%s_&_stint_",
                dataLogger:getMotecDirectory(carIndex),
                ac.getTrackID(),
                ac.getCarID(carIndex),
                ac.getDriverName(carIndex)
        )

        local filename
        for i = 1, 1e6 do
                filename = prefix .. i .. ".ld"
                if not io.exists(filename) then break end
        end
        io.createFileDir(filename)
        return filename
end

function dataLogger:loggerActive() return dataCollector:active() end

function dataLogger:loggerTime() return math.round(dataCollector:time(), 3) end

function dataLogger:loggerDrop()
        dataCollector:drop()
        ui.toast(ui.Icons.CarFront, "Stopped recording Motec data, recorded data dropped")
        ac.log("Stopped recording Motec data, recorded data dropped")
end

function dataLogger:loggerStart()
        if dataLogger:loggerActive() then return end
        dataCollector:begin()
        ui.toast(ui.Icons.CarFront, "Started recording Motec data")
                :button(ui.Icons.Cancel, "Cancel", function() dataLogger:loggerDrop() end)
        ac.log("Started recording Motec data")
end

function dataLogger:loggerEnd()
        if
                dataLogger.settings.dropShortLogTime > 0
                and dataLogger:loggerTime() < dataLogger.settings.dropShortLogTime
        then
                dataCollector:drop()
                ui.toast(ui.Icons.CarFront, "Insufficient Motec log time, recorded data dropped")
                ac.log("Insufficient Motec log time, recorded data dropped")
                return
        end

        local logFilename = dataLogger:getMotecFilename(0)
        dataCollector:finishAsync(logFilename, function(err, savedChannels)
                if err then
                        ac.error("Logger saving error: %s" % err)
                else
                        ui.toast(ui.Icons.Save, "Motec log saved")
                                :button(
                                        ui.Icons.File,
                                        "View in Explorer",
                                        function() os.showInExplorer(logFilename) end
                                )
                        ac.log("Log filed saved - " .. logFilename)
                end
        end)
end

toggleLogButton:onPressed(function()
        if dataLogger:loggerActive() then
                dataLogger:loggerEnd()
        else
                dataLogger:loggerStart()
        end
end)

if dataLogger.settings.autoLog then
        ac.log("Auto-Log Active")
        dataLogger:loggerStart()
end

function script.windowSettings(dt)
        ui.text("Toggle Logging:")
        ui.sameLine()
        toggleLogButton:control(vec2Temp1:set(161, 0))

        if ui.checkbox("Auto-Log", dataLogger.settings.autoLog) then
                dataLogger.settings.autoLog = not dataLogger.settings.autoLog
        end
        if ui.itemHovered() then ui.setTooltip("Automatically begin logging after launching AC.") end

        ui.setNextItemWidth(ui.availableSpaceX())
        local value, changed = ui.slider(
                "##settings.dropShortLogTimeSlider",
                dataLogger.settings.dropShortLogTime,
                0,
                60,
                dataLogger.settings.dropShortLogTime > 0 and "Minimum log time: %.0f s" or "Minimum log time: None",
                1
        )
        if changed then dataLogger.settings.dropShortLogTime = value end
        if ui.itemHovered() then
                ui.setTooltip(
                        string.format(
                                "Logs won't save if they are below this time threshold.",
                                dataLogger.settings.dropShortLogTime
                        )
                )
        end

        ui.newLine()
        if ui.checkbox("Show All UI", not dataLogger.settings.fadeApp) then
                dataLogger.settings.fadeApp = not dataLogger.settings.fadeApp
        end
        if ui.itemHovered() then ui.setTooltip("Force app UI to remain visible.") end

        if ui.checkbox("Show Status UI", not dataLogger.settings.fadeStatus) then
                dataLogger.settings.fadeStatus = not dataLogger.settings.fadeStatus
        end
        if ui.itemHovered() then
                ui.setTooltip("Forces status and time to remain\nvisible if 'Show All UI' is disabled.")
        end
        ui.dummy(2)
end

function script.windowMain(dt)
        if not dataLogger.settings.fadeApp then ac.forceFadingIn() end

        local isLoggerActive = dataLogger:loggerActive()
        local isWindowFaded = ac.windowFading() >= 0.5

        if dataLogger.settings.fadeStatus and isWindowFaded then return end

        ui.setCursorY(36)
        ui.beginGroup(125)
        ui.dwriteText(
                string.format("Status: %s", isLoggerActive and "Active" or "Inactive"),
                16,
                isLoggerActive and rgbm.colors.lime or rgbm.colors.red
        )
        ui.dwriteText(string.format("Time: %s", dataLogger:loggerTime()), 16, rgbm.colors.white)
        ui.endGroup()

        if isWindowFaded then return end

        ui.sameLine()
        ui.beginGroup(200)
        if isLoggerActive then
                if ui.button("Stop & Save", vec2Temp1:set(108, 24), ui.ButtonFlags.None) then dataLogger:loggerEnd() end
                ui.sameLine()
                if ui.iconButton(ui.Icons.Trash, vec2Temp1:set(24, 24)) then dataLogger:loggerDrop() end
                if ui.itemHovered() then ui.setTooltip("Stops logging and drops anything already collected") end
        else
                if ui.button("Start", vec2Temp1:set(140, 24), ui.ButtonFlags.None) then dataLogger:loggerStart() end
        end

        if ui.button("Open Log Folder", vec2Temp1:set(140, 24), ui.ButtonFlags.None) then
                local logDirectory = getMotecDirectory(0)
                os.openInExplorer(logDirectory)
        end
        ui.endGroup()

        ui.newLine(-10)
        ui.dwriteText("Logging will continue, even if this window is closed.", 10, rgbm.colors.white)

        ui.dummy(3)
end

ac.onSessionStart(function(sessionIndex, restarted)
        if not dataLogger:loggerActive() then return end
        ac.log("New session or restart, restarting logger")
        dataLogger:loggerEnd()
        dataLogger:loggerStart()
end)

ac.onRelease(function(item)
        if dataLogger:loggerActive() then
                ac.log("AC shutting down, saving log")
                dataLogger:loggerEnd()
        end
end)

return dataLogger
