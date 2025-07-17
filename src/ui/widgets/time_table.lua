local cui = require("ui.cui")
local race = require("race")
local settings = require("settings")
local style = require("ui.cui.style")
local sim = ac.getSim()

local timetable = { isShowingDisconnected = false }

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
                value = function(car, width, height)
                        return race:getLeaderboardPosition(car.index),
                                (car.index == sim.focusedCar or car.index == 0)
                                                and settings.Appearance.uiColorBackground
                                        or rgbm.colors.white
                end,
                xShare = -1,
                align = ui.Alignment.Center,
        },
        {
                label = "Driver",
                value = function(car, width, height) return ac.getDriverName(car.index) end,
                xShare = 0.31,
                align = ui.Alignment.Start,
        },
        {
                label = "",
                value = function(car, width, height)
                        return (not car.status.isInPitlane and car.status.drsActive) and "[DRS]" or "",
                                car.status.drsActive and rgbm(0, 0.75, 0, 1) or rgbm.colors.white
                end,
                xShare = 0.05,
                align = ui.Alignment.End,
        },
        {
                label = "Last",
                value = function(car, width, height)
                        if car.status.previousLapTimeMs == 0 then return ac.lapTimeToString("") end
                        local textColor = rgbm.colors.white

                        if
                                car.status.isLastLapValid
                                and car.status.previousLapTimeMs > 0
                                and car.status.previousLapTimeMs <= race.fastestLapTimeMs
                        then
                                drawTimeIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        elseif not car.status.isLastLapValid then
                                textColor = rgbm(0.75, 0, 0, 1)
                        elseif
                                car.status.isLastLapValid
                                and car.status.previousLapTimeMs <= car.status.bestLapTimeMs
                        then
                                drawTimeIndicator(width, height)
                                textColor = settings.Appearance.uiColorBackground
                        end

                        return ac.lapTimeToString(car.status.previousLapTimeMs), textColor
                end,
                xShare = 0.07,
                align = ui.Alignment.Center,
        },
        {
                label = "Delta",
                value = function(car, width, height)
                        local delta = car.previousLapDelta
                        local deltaPrefix = ""

                        if math.abs(delta) < 10 or car.status.isInPitlane then return "+0.000" end

                        if delta > 0 then
                                deltaPrefix = "+"
                                drawTimeIndicator(width, height, rgbm.colors.yellow)
                        elseif delta <= 0 then
                                drawTimeIndicator(width, height)
                        end

                        if delta < 0 then deltaPrefix = "-" end

                        return string.format("%s %.3f", deltaPrefix, math.abs(delta) / 1000),
                                settings.Appearance.uiColorBackground
                end,
                xShare = 0.07,
                align = ui.Alignment.Center,
        },
        {
                label = "S1",
                value = function(car, width, height)
                        local currentSplit = car.status.currentSplits[0]
                        if not car.status.currentSplits[0] then currentSplit = car.status.lastSplits[0] end

                        if not currentSplit then return ac.lapTimeToString("") end

                        if currentSplit > 0 and currentSplit <= race.fastestSplits[0] then
                                drawSplitIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        elseif
                                currentSplit > 0 and currentSplit <= car.status.bestSplits[0]
                                or car.status.bestSplits[0] == 0
                        then
                                drawSplitIndicator(width, height)
                        else
                                drawSplitIndicator(width, height, rgbm.colors.yellow)
                        end

                        return ac.lapTimeToString(currentSplit):trim("0:", -1)
                end,
                xShare = 0.07,
                align = ui.Alignment.Center,
        },
        {
                label = "S2",
                value = function(car, width, height)
                        local currentSplit = car.status.currentSplits[1]
                        if not car.status.currentSplits[0] then currentSplit = car.status.lastSplits[1] end

                        if not currentSplit then return ac.lapTimeToString("") end

                        if currentSplit > 0 and currentSplit <= race.fastestSplits[1] then
                                drawSplitIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        elseif
                                currentSplit > 0 and currentSplit <= car.status.bestSplits[1]
                                or car.status.bestSplits[1] == 0
                        then
                                drawSplitIndicator(width, height)
                        else
                                drawSplitIndicator(width, height, rgbm.colors.yellow)
                        end

                        return ac.lapTimeToString(currentSplit):trim("0:", -1)
                end,
                xShare = 0.07,
                align = ui.Alignment.Center,
        },
        {
                label = "S3",
                value = function(car, width, height)
                        local currentSplit = car.status.currentSplits[2]
                        if not car.status.currentSplits[0] then currentSplit = car.status.lastSplits[2] end

                        if not currentSplit then return ac.lapTimeToString("") end

                        if currentSplit > 0 and currentSplit <= race.fastestSplits[2] then
                                drawSplitIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        elseif
                                currentSplit > 0 and currentSplit <= car.status.bestSplits[2]
                                or car.status.bestSplits[2] == 0
                        then
                                drawSplitIndicator(width, height)
                        else
                                drawSplitIndicator(width, height, rgbm.colors.yellow)
                        end

                        return ac.lapTimeToString(currentSplit):trim("0:", -1)
                end,
                xShare = 0.07,
                align = ui.Alignment.Center,
        },
        {
                label = "Best",
                value = function(car, width, height)
                        local textColor = rgbm.colors.white

                        if car.bestLapTimeMs > 0 and car.bestLapTimeMs <= race.fastestLapTimeMs then
                                drawTimeIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        elseif
                                car.status.isLastLapValid
                                and car.status.previousLapTimeMs <= car.status.bestLapTimeMs
                        then
                                drawTimeIndicator(width, height)
                                textColor = settings.Appearance.uiColorBackground
                        end

                        return ac.lapTimeToString(car.bestLapTimeMs), textColor
                end,
                xShare = 0.07,
                align = ui.Alignment.Center,
        },
        {
                label = "Delta",
                value = function(car, width, height)
                        local delta = car.bestLapDelta
                        local deltaPrefix = ""

                        if math.abs(delta) < 10 or car.status.isInPitlane then return "+0.000" end

                        if delta > 0 then
                                deltaPrefix = "+"
                                drawTimeIndicator(width, height, rgbm.colors.yellow)
                        elseif delta <= 0 then
                                drawTimeIndicator(width, height)
                        end

                        if delta < 0 then deltaPrefix = "-" end

                        return string.format("%s %.3f", deltaPrefix, math.abs(delta) / 1000),
                                settings.Appearance.uiColorBackground
                end,
                xShare = 0.07,
                align = ui.Alignment.Center,
        },
        {
                label = "Gap",
                value = function(car, width, height)
                        if sim.raceSessionType == ac.SessionType.Race and car.lapsToLeader > 0 then
                                return "+%s L" % car.lapsToLeader
                        end

                        local gapToLeaderText = string.format("%+.3f", car.gapToLeader / 1000)
                        if race:getLeaderboardPosition(car.index) == 1 then gapToLeaderText = "Leader" end

                        return gapToLeaderText
                end,
                xShare = 0.07,
                align = ui.Alignment.Center,
        },
        {
                label = "Int.",
                value = function(car, width, height)
                        if sim.raceSessionType == ac.SessionType.Race and car.lapsToCarAheadLeaderboard > 0 then
                                return "+%s L" % car.lapsToCarAheadLeaderboard
                        end

                        local intervalText = string.format("%+.3f", car.gapToCarAheadLeaderboard / 1000)
                        if race:getLeaderboardPosition(car.index) == 1 then intervalText = "Interval" end

                        return intervalText
                end,
                xShare = 0.07,
                align = ui.Alignment.Center,
        },
}

local width

local function timetableBanner(yPos, height)
        local fontSize = height * 0.5

        if not width then width = ui.availableSpaceX() end

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

function timetableEntryButton(car, yPos, height)
        ui.setCursorX(0)
        local xPos = 0
        width = ui.availableSpaceX()

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        if ui.invisibleButton("##timetableEntryButton" .. car.index, vec2(width, height)) then
                if car.status.isConnected then ac.focusCar(car.index) end
        end

        local leaderboardPosition = car.leaderboardPosition
        local evenCar = leaderboardPosition % 2 == 0

        local numberBoxColor = rgbm.colors.transparent
        if sim.focusedCar == car.index then
                numberBoxColor = settings.Appearance.uiColorSecondary
        elseif car.index == 0 then
                numberBoxColor = settings.Appearance.uiColorAccent
        end
        ui.drawRectFilled(vec2(xPos, yPos), vec2(xPos + height, yPos + height), settings.Appearance.uiColorPrimary)
        ui.drawRectFilled(
                vec2(xPos, yPos),
                vec2(xPos + width, yPos + height),
                evenCar and settings.Appearance.uiColorPrimary * 0.15 or settings.Appearance.uiColorPrimary * 0.5
        )
        ui.drawRectFilled(vec2(xPos, yPos), vec2(xPos + height, yPos + height), numberBoxColor)

        local positionColor = rgbm.colors.transparent
        if sim.raceSessionType ~= ac.SessionType.Race then
                positionColor = rgbm.colors.transparent
        elseif leaderboardPosition == 1 and car.slot.hasCompletedLastLap then
                positionColor = rgbm(1, 0.78, 0.2, 1)
        elseif leaderboardPosition == 2 and car.slot.hasCompletedLastLap then
                positionColor = rgbm(0.6, 0.6, 0.7, 1)
        elseif leaderboardPosition == 3 and car.slot.hasCompletedLastLap then
                positionColor = rgbm(0.9, 0.4, 0, 1)
        end
        ui.drawRectFilledMultiColor(
                vec2(xPos + height, yPos),
                vec2(xPos + height + height * 0.75, yPos + height),
                positionColor,
                rgbm.colors.transparent,
                rgbm.colors.transparent,
                positionColor
        )

        if sim.isOnlineRace and car.status.isConnected then
                local pingColor = rgbm.colors.green

                if car.status.ping > 300 then
                        pingColor = rgbm.colors.red
                elseif car.status.ping > 250 then
                        pingColor = rgbm.colors.orange
                elseif car.status.ping > 100 then
                        pingColor = rgbm.colors.yellow
                end

                ui.drawRectFilled(
                        vec2(height * 0.1, yPos),
                        vec2(0, yPos + height),
                        settings.Appearance.uiColorBackground
                )

                ui.drawRectFilled(
                        vec2(height * 0.1, yPos + height * math.min(car.status.ping / 400, 0.9)),
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
                local value, color = entry.value(car, x, y)
                ui.dwriteTextAligned(
                        value,
                        style.main.font.body.size,
                        entry.align,
                        ui.Alignment.Center,
                        vec2(x, y),
                        false,
                        color
                )
                ui.sameLine()
        end

        if not car.status.isConnected then
                ui.drawRectFilled(vec2(xPos, yPos), vec2(xPos + width, yPos + height), rgbm(0.1, 0.1, 0.1, 0.6))
        end
end

function timetable:body()
        local height = style.main.font.body.size * 2
        timetableBanner(0, height)

        cui.pushWindow("home_timetable_entrant_window", 0, height, ui.windowWidth(), ui.windowHeight() - height, true)
        for leaderboardIndex, slot in ipairs(race.leaderboard) do
                if slot.car.isConnected or timetable.isShowingDisconnected then
                        timetableEntryButton(race.cars[slot.car.index], (leaderboardIndex - 1) * height, height)
                end
        end
        cui.dummy(height, height)
        cui.popWindow(true)
end

function timetable:drawFooter()
        if not sim.isOnlineRace then return end

        timetable.isShowingDisconnected = cui.checkbox(
                "##isTimetableShowingDisconnected",
                "Show Disconnected",
                ui.windowHeight() * 0.65,
                timetable.isShowingDisconnected
        )
end

return timetable
