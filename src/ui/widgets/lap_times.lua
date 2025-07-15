local cui = require("ui.cui")
local laps = require("laps")
local race = require("race")
local settings = require("settings")
local simutils = require("simutils")

local function drawTimeIndicator(width, height, color)
        if not color then color = rgbm(0, 0.75, 0, 1) end

        ui.drawRectFilled(
                vec2(ui.getCursorX() + width * 0.01, ui.getCursorY() + height * 0.05),
                vec2(ui.getCursorX() + width * 0.99, ui.getCursorY() + height * 0.95),
                color
        )
end

local function drawSplitIndicator(width, height, color)
        if not color then color = rgbm(0, 0.75, 0, 1) end

        ui.drawRectFilled(
                vec2(ui.getCursorX() + width * 0.01, ui.getCursorY() + height * 0.85),
                vec2(ui.getCursorX() + width * 0.99, ui.getCursorY() + height * 0.95),
                color
        )
end

local entryLayout = {
        {
                label = "",
                value = function(car, lap, width, height) return lap.number end,
                xShare = -1,
                align = ui.Alignment.Center,
        },
        {
                label = "Driver",
                value = function(car, lap, width, height) return ac.getDriverName(car.index) end,
                xShare = 0.4,
                align = ui.Alignment.Start,
        },

        {
                label = "Tyres",
                value = function(car, lap, width, height) return lap.tyres end,
                xShare = 0.1,
                align = ui.Alignment.Center,
        },

        {
                label = "Lap Time",
                value = function(car, lap, width, height)
                        local textColor = rgbm.colors.white

                        if car.status.bestLapTimeMs and lap.time <= car.status.bestLapTimeMs then
                                drawTimeIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        end

                        return ac.lapTimeToString(lap.time), textColor
                end,
                xShare = 0.1,
                align = ui.Alignment.Center,
        },

        {
                label = "S1",
                value = function(car, lap, width, height)
                        local currentSplit = lap.splits[0]

                        if car.status.bestSplits[0] and currentSplit <= car.status.bestSplits[0] then
                                drawSplitIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        end

                        return ac.lapTimeToString(currentSplit):trim("0:", -1)
                end,
                xShare = 0.1,
                align = ui.Alignment.Center,
        },
        {
                label = "S2",
                value = function(car, lap, width, height)
                        local currentSplit = lap.splits[1]

                        if car.status.bestSplits[1] and currentSplit <= car.status.bestSplits[1] then
                                drawSplitIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        end

                        return ac.lapTimeToString(currentSplit):trim("0:", -1)
                end,
                xShare = 0.1,
                align = ui.Alignment.Center,
        },
        {
                label = "S3",
                value = function(car, lap, width, height)
                        local currentSplit = lap.splits[2]

                        if car.status.bestSplits[2] and currentSplit <= car.status.bestSplits[2] then
                                drawSplitIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        end

                        return ac.lapTimeToString(currentSplit):trim("0:", -1)
                end,
                xShare = 0.1,
                align = ui.Alignment.Center,
        },

        {
                label = "Delta",
                value = function(car, lap, width, height)
                        local delta = lap.delta
                        local deltaPrefix = ""

                        if lap.number == 1 or not delta then return "-.---" end

                        if delta > 0 then
                                deltaPrefix = "+"
                        elseif delta < 0 then
                                deltaPrefix = "-"
                        end

                        return string.format("%s%.3f", deltaPrefix, math.abs(delta) / 1000)
                end,
                xShare = 0.1,
                align = ui.Alignment.Center,
        },
}

local statsLayout = {
        {
                label = "Laps",
                value = function(sessionLaps)
                        if not sessionLaps then return 0 end

                        return #sessionLaps
                end,
                xShare = 0.2,
                align = ui.Alignment.Center,
        },

        {
                label = "Best Time",
                value = function(sessionLaps)
                        if not sessionLaps then return "-:--:--" end

                        local bestTime = math.huge

                        for _, lap in ipairs(sessionLaps) do
                                if lap.time then
                                        if lap.time < bestTime then bestTime = lap.time end
                                end
                        end

                        return ac.lapTimeToString(bestTime)
                end,
                xShare = 0.2,
                align = ui.Alignment.Center,
        },
        {
                label = "Avg. Time",
                value = function(sessionLaps)
                        if not sessionLaps then return "-:--:--" end

                        local totalTime = 0

                        for _, lap in ipairs(sessionLaps) do
                                if lap.time then totalTime = totalTime + lap.time end
                        end

                        return ac.lapTimeToString(totalTime / #sessionLaps)
                end,
                xShare = 0.2,
                align = ui.Alignment.Center,
        },
        {
                label = "Avg. Delta",
                value = function(sessionLaps)
                        if not sessionLaps then return "-.---" end

                        local deltaTotal = 0
                        local deltaPrefix = ""

                        for i, lap in ipairs(sessionLaps) do
                                if lap.delta and i > 1 then deltaTotal = deltaTotal + lap.delta end
                        end

                        if deltaTotal > 0 then
                                deltaPrefix = "+"
                        elseif deltaTotal < 0 then
                                deltaPrefix = "-"
                        end

                        if deltaTotal == 0 then return "-.---" end

                        return string.format("%s%.3f", deltaPrefix, math.abs(deltaTotal / (#sessionLaps - 1)) / 1000)
                end,
                xShare = 0.2,
                align = ui.Alignment.Center,
        },
}

local lapTimes = {
        sessionLaps = nil,
}

local function lapTimeBanner(yPos, height)
        local width = ui.windowWidth()
        local fontSize = height * 0.5

        ui.setCursorX(height * 0.2)
        ui.setCursorY(yPos)

        for _, entry in ipairs(entryLayout) do
                local tempWidth = width - height - (height * 0.2)
                cui.snapCursor()
                local x, y = entry.xShare == -1 and height or tempWidth * entry.xShare, height
                ui.dwriteTextAligned(entry.label, fontSize, entry.align, ui.Alignment.Center, vec2(x, y))
                ui.sameLine()
        end
end

local function noEntryBanner(yPos, height)
        local width = ui.windowWidth()
        local fontSize = height * 0.5

        ui.drawRectFilled(vec2(0, 0), vec2(0 + width, height), settings.Appearance.uiColorPrimary * 0.5)

        ui.setCursorX(height * 1.2)
        ui.setCursorY(0)

        cui.snapCursor()
        ui.dwriteTextAligned(
                "No entries",
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), height)
        )
end

function lapTimeEntryButton(car, lap, yPos, height)
        local xPos = 0
        local width = ui.windowWidth()

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        if ui.invisibleButton("##lapTimeEntryButton" .. car.index, vec2(width, height)) then
                if car.status.isConnected then ac.focusCar(car.index) end
        end

        local lapNumber = lap.number
        local evenCar = lapNumber % 2 == 0

        ui.drawRectFilled(vec2(xPos, yPos), vec2(xPos + height, yPos + height), settings.Appearance.uiColorPrimary)
        ui.drawRectFilled(
                vec2(xPos, yPos),
                vec2(xPos + width, yPos + height),
                evenCar and settings.Appearance.uiColorPrimary * 0.15 or settings.Appearance.uiColorPrimary * 0.5
        )

        ui.setCursorX(height * 0.2)
        ui.setCursorY(yPos)

        for _, entry in ipairs(entryLayout) do
                local tempWidth = width - height - height * 0.2
                cui.snapCursor()
                local x, y = entry.xShare == -1 and height or tempWidth * entry.xShare, height
                local value, color = entry.value(car, lap, x, height)
                ui.dwriteTextAligned(value, height * 0.5, entry.align, ui.Alignment.Center, vec2(x, y), false, color)
                ui.sameLine()
        end
end

function lapTimes:body()
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorPrimary * 0.25)
        ui.setCursor(0)

        local height = ui.windowHeight() / 22
        lapTimeBanner(0, height)

        cui.pushWindow(
                "home_lapTimes_entrant_window",
                0,
                height,
                ui.windowWidth(),
                ui.windowHeight() - height * 2,
                true
        )

        lapTimes.sessionLaps = laps[session]

        if lapTimes.sessionLaps and #lapTimes.sessionLaps > 0 then
                for lapIndex, lap in ipairs(lapTimes.sessionLaps) do
                        lapTimeEntryButton(race.cars[0], lap, (lapIndex - 1) * height, height)
                end
        else
                noEntryBanner(yPos, height)
        end

        cui.dummy(height, height)
        cui.popWindow(true)
end

function lapTimes:drawFooter()
        local height = ui.windowHeight()

        for _, entry in ipairs(statsLayout) do
                cui.snapCursor()
                local x, y = entry.xShare == -1 and height or ui.windowWidth() * entry.xShare, height
                local value, color = entry.value(lapTimes.sessionLaps)
                ui.dwriteTextAligned(
                        string.format("%s: %s", entry.label, value),
                        height * 0.65,
                        entry.align,
                        ui.Alignment.Center,
                        vec2(x, y),
                        false,
                        color
                )
                ui.sameLine()
        end

        if
                cui.menuButton(
                        "Export to CSV",
                        vec2(ui.windowWidth() * 0.2, height),
                        0,
                        0,
                        (lapTimes.sessionLaps and #lapTimes.sessionLaps > 0) and ui.ButtonFlags.None
                                or ui.ButtonFlags.Disabled
                )
        then
                local outputFilePath = string.format(
                        "%s\\out\\%s_%s_%s_%s.csv",
                        ac.getFolder(ac.FolderID.ACDocuments),
                        simutils.raceSessionTypeString,
                        ac.getCarID(0),
                        ac.getTrackFullID("_"),
                        os.date("%Y-%m-%d_%H%M%S")
                )
                local outputFile = io.open(outputFilePath, "w+")

                if outputFile then
                        outputFile:write("LAP,VALIDITY,TYRES,LAPTIME,SPLIT1,SPLIT2,SPLIT3,DELTA\n")
                        for _, lap in ipairs(lapTimes.sessionLaps) do
                                outputFile:write(
                                        string.format(
                                                "%s,%s,%s,%s,%s,%s,%s,%s\n",
                                                lap.number,
                                                lap.valid,
                                                lap.tyres,
                                                lap.time,
                                                lap.splits[0],
                                                lap.splits[1],
                                                lap.splits[2],
                                                lap.delta or ""
                                        )
                                )
                        end
                        outputFile:close()
                end
        end
end

return lapTimes
