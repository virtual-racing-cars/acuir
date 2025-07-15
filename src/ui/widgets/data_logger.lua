local cui = require("ui.cui")
local dataLogger = require("data_logger")
local race = require("race")
local settings = require("settings")
local style = require("ui.cui.style")
local units = require("units")

local car = ac.getCar(0)

local dataLoggerWidget = {}

function dataLoggerWidget:body()
        if not car.extendedPhysics then
                ui.setCursor(0)
                ui.dwriteTextAligned(
                        "Requires a Car with Extended Physics",
                        style.main.font.body.size,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        ui.windowSize(),
                        false,
                        settings.Appearance.uiColorTextDim
                )
                return
        end

        local buttonSize = ui.windowHeight() * 0.8

        ui.setCursorX(ui.windowHeight() * 0.3)
        ui.setCursorY(ui.windowHeight() * 0.15)
        if
                cui.iconButton(
                        dataLogger:loggerActive() and "Stop & Save" or "Start",
                        dataLogger:loggerActive() and ui.Icons.Save or ui.Icons.Target,
                        buttonSize,
                        buttonSize,
                        0
                )
        then
                if dataLogger:loggerActive() then
                        dataLogger:loggerEnd()
                else
                        dataLogger:loggerStart()
                end
        end

        ui.setCursorX(ui.windowWidth() * 0.5 - ui.windowHeight() * 0.5)
        ui.setCursorY(ui.windowHeight() * 0.15)
        if
                cui.iconButton(
                        "Cancel",
                        ui.Icons.Cancel,
                        buttonSize,
                        buttonSize,
                        dataLogger:loggerActive() and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                )
        then
                dataLogger:loggerDrop()
        end

        ui.setCursorX(ui.windowWidth() - ui.windowHeight() * 1.3)
        ui.setCursorY(ui.windowHeight() * 0.15)
        if cui.iconButton("Logs", ui.Icons.Folder, buttonSize, buttonSize, 0) then
                local logDirectory = dataLogger:getMotecDirectory(0)
                if not io.dirExists(logDirectory) then io.createDir(logDirectory) end
                os.openInExplorer(logDirectory)
        end
end

function dataLoggerWidget:drawFooter()
        settings.DataLogger.autoStartLogging = drawCheckbox(
                "##dataLoggerAutoStart",
                "Auto-Start",
                style.main.font.body.size,
                settings.DataLogger.autoStartLogging
        )
end

return dataLoggerWidget
