local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()
local race = require("race")

local timetable = {}

local function drawTimeIndicator(width, height, color)
        if not color then color = rgbm(0, 0.75, 0, 1) end

        ui.drawRectFilled(
                vec2(ui.getCursorX() + width * 0.01, ui.getCursorY() + height * 0.85),
                vec2(ui.getCursorX() + width * 0.99, ui.getCursorY() + height),
                color
        )
end

local entryLayout = {
        {
                label = "",
                value = function(slot, car, width, height)
                        return race:getLeaderboardPosition(car.index),
                                (car.index == sim.focusedCar or car.index == 0) and rgbm.colors.black
                                        or rgbm.colors.white
                end,
                xShare = -1,
                align = ui.Alignment.Center,
        },
        {
                label = "Driver",
                value = function(slot, car, width, height) return ac.getDriverName(car.index) end,
                xShare = 0.31,
                align = ui.Alignment.Start,
        },
        {
                label = "",
                value = function(slot, car, width, height)
                        return (not car.isInPitlane and car.drsActive) and "[DRS]" or "",
                                car.drsActive and rgbm(0, 0.75, 0, 1) or rgbm.colors.white
                end,
                xShare = 0.05,
                align = ui.Alignment.End,
        },
        {
                label = "Last",
                value = function(slot, car, width, height)
                        if car.previousLapTimeMs == 0 then return ac.lapTimeToString("") end

                        if
                                car.isLastLapValid
                                and car.previousLapTimeMs > 0
                                and car.previousLapTimeMs <= race.fastestLap
                        then
                                drawTimeIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        elseif car.isLastLapValid and car.previousLapTimeMs <= car.bestLapTimeMs then
                                drawTimeIndicator(width, height)
                        end

                        return ac.lapTimeToString(car.previousLapTimeMs),
                                car.isLastLapValid and rgbm.colors.white or rgbm(0.75, 0.0, 0, 1)
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
        {
                label = "S1",
                value = function(slot, car, width, height)
                        local currentSplit = car.currentSplits[0]
                        if not car.currentSplits[0] then currentSplit = car.lastSplits[0] end

                        if not currentSplit then return ac.lapTimeToString("") end

                        if currentSplit > 0 and currentSplit <= race.fastestSplits[0] then
                                drawTimeIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        elseif currentSplit > 0 and currentSplit <= car.bestSplits[0] then
                                drawTimeIndicator(width, height)
                        end

                        return ac.lapTimeToString(currentSplit):trim("0:", -1)
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
        {
                label = "S2",
                value = function(slot, car, width, height)
                        local currentSplit = car.currentSplits[1]
                        if not car.currentSplits[0] then currentSplit = car.lastSplits[1] end

                        if not currentSplit then return ac.lapTimeToString("") end

                        if currentSplit > 0 and currentSplit <= race.fastestSplits[1] then
                                drawTimeIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        elseif currentSplit > 0 and currentSplit <= car.bestSplits[1] then
                                drawTimeIndicator(width, height)
                        end

                        return ac.lapTimeToString(currentSplit):trim("0:", -1)
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
        {
                label = "S3",
                value = function(slot, car, width, height)
                        local currentSplit = car.currentSplits[2]
                        if not car.currentSplits[0] then currentSplit = car.lastSplits[2] end

                        if not currentSplit then return ac.lapTimeToString("") end

                        if currentSplit > 0 and currentSplit <= race.fastestSplits[2] then
                                drawTimeIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        elseif currentSplit > 0 and currentSplit <= car.bestSplits[2] then
                                drawTimeIndicator(width, height)
                        end

                        return ac.lapTimeToString(currentSplit):trim("0:", -1)
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
        {
                label = "Best",
                value = function(slot, car, width, height)
                        if car.bestLapTimeMs > 0 and car.bestLapTimeMs <= race.fastestLap then
                                drawTimeIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        end

                        return ac.lapTimeToString(car.bestLapTimeMs)
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
        {
                label = "Gap",
                value = function(slot, car, width, height)
                        local gapToLeaderText = race.intervals[car.index]
                                        and string.format("%+.3f", race.intervals[car.index] / 1000)
                                or "-.---"
                        if race:getLeaderboardPosition(car.index) == 1 then gapToLeaderText = "Leader" end

                        return gapToLeaderText
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
        {
                label = "Int.",
                value = function(slot, car, width, height)
                        local intervalText = race.leaderboardGaps[car.index]
                                        and string.format("%+.3f", race.leaderboardGaps[car.index] / 1000)
                                or "-.---"
                        if race:getLeaderboardPosition(car.index) == 1 then intervalText = "Interval" end

                        return intervalText
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
}

local function timetableBanner(yPos, height)
        local width = ui.windowWidth()
        local fontSize = height * 0.5

        ui.drawRectFilled(vec2(0, yPos), vec2(width, yPos + height), rgbm(0.1, 0.1, 0.1, 0.95))

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

function timetableEntryButton(slot, index, yPos, height)
        local xPos = 0
        local width = ui.windowWidth()

        local car = slot.car

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        if ui.invisibleButton("##timetableEntryButton" .. car.index, vec2(width, height)) then
                if car.isConnected then ac.focusCar(car.index) end
        end

        local evenCar = index % 2 == 0

        ui.drawRectFilled(
                vec2(xPos, yPos),
                vec2(xPos + height, yPos + height),
                sim.focusedCar == car.index and settings.Appearance.uiThemeColor2
                        or (car.index == 0 and settings.Appearance.uiThemeColor3 or settings.Appearance.uiThemeColor1)
        )

        ui.drawRectFilled(
                vec2(xPos, yPos),
                vec2(xPos + width, yPos + height),
                evenCar and settings.Appearance.uiThemeColor1 * 0.15 or settings.Appearance.uiThemeColor1 * 0.5
        )

        ui.drawRectFilled(
                vec2(xPos, yPos),
                vec2(xPos + height, yPos + height),
                sim.focusedCar == car.index and settings.Appearance.uiThemeColor2
                        or (car.index == 0 and settings.Appearance.uiThemeColor3 or rgbm.colors.transparent)
        )

        if sim.isOnlineRace then
                local pingColor = rgbm.colors.green

                if car.ping > 300 then
                        pingColor = rgbm.colors.red
                elseif car.ping > 250 then
                        pingColor = rgbm.colors.orange
                elseif car.ping > 100 then
                        pingColor = rgbm.colors.yellow
                end

                ui.drawRectFilled(vec2(height * 0.1, yPos), vec2(0, yPos + height), rgbm.colors.black)

                ui.drawRectFilled(
                        vec2(height * 0.1, yPos + height * math.min(car.ping / 400, 0.9)),
                        vec2(0, yPos + height),
                        pingColor
                )
        end

        ui.setCursorX(height * 0.2)
        ui.setCursorY(yPos)

        for _, entry in ipairs(entryLayout) do
                local tempWidth = width - height - height * 0.2
                cui.snapCursor()
                local x, y = entry.xShare == -1 and height or tempWidth * entry.xShare, height
                local value, color = entry.value(slot, car, x, height)
                ui.dwriteTextAligned(value, height * 0.5, entry.align, ui.Alignment.Center, vec2(x, y), false, color)
                ui.sameLine()
        end

        if not car.isConnected then
                ui.drawRectFilled(vec2(xPos, yPos), vec2(xPos + width, yPos + height), rgbm(0.1, 0.1, 0.1, 0.6))
        end
end

function timetable:draw(xPos, yPos, width, height)
        cui.pushWindow("timetable_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiThemeColor1 * 0.25)
        ui.setCursor(0)

        local height = 50 * cui.uiScale()
        timetableBanner(0, height)

        cui.pushWindow("home_timetable_entrant_window", 0, height, ui.windowWidth(), ui.windowHeight() - height, true)
        local leaderboardIndex = 0
        for _, slot in ipairs(race.leaderboard) do
                if slot.car.isConnected then
                        leaderboardIndex = leaderboardIndex + 1
                        timetableEntryButton(slot, leaderboardIndex, (leaderboardIndex - 1) * height, height)
                end
        end
        cui.dummy(height, height)
        cui.popWindow(true)

        cui.popWindow()
end

return timetable
