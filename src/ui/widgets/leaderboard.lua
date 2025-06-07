local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()
local race = require("race")

local function drawTimeIndicator(width, height, color)
        if not color then color = rgbm(0, 0.75, 0, 1) end

        ui.drawRectFilled(
                vec2(ui.getCursorX() + width * 0.01, ui.getCursorY() + height * 0.05),
                vec2(ui.getCursorX() + width * 0.99, ui.getCursorY() + height * 0.95),
                color
        )
end

local entryLayout = {
        {
                label = "",
                value = function(car, width, height)
                        return car.leaderboardPosition,
                                (car.index == sim.focusedCar or car.index == 0) and rgbm.colors.black
                                        or rgbm.colors.white
                end,
                xShare = -1,
                align = ui.Alignment.Center,
        },
        {
                label = "Driver",
                value = function(car, width, height) return ac.getDriverName(car.index) end,
                xShare = 0.3,
                align = ui.Alignment.Start,
        },
        {
                label = "Car",
                value = function(car, width, height)
                        return ac.INIConfig
                                .carData(car.index, "car.ini")
                                :get("INFO", "SHORT_NAME", ac.getCarName(car.index))
                end,
                xShare = 0.25,
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
                label = "Best",
                value = function(car, width, height)
                        if car.bestLapTimeMs > 0 and car.bestLapTimeMs <= race.fastestLapTimeMs then
                                drawTimeIndicator(width, height, rgbm(0.5, 0.2, 1, 1))
                        end

                        return ac.lapTimeToString(car.bestLapTimeMs)
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
        {
                label = "Gap",
                value = function(car, width, height)
                        local gapToLeaderText
                        if race:getLeaderboardPosition(car.index) == 1 then
                                gapToLeaderText = "Leader"
                        elseif sim.raceSessionType == ac.SessionType.Race and car.lapsToLeader > 0 then
                                gapToLeaderText = "+%s L" % car.lapsToLeader
                        else
                                gapToLeaderText = string.format("%+.2f", car.gapToLeader / 1000)
                        end

                        return gapToLeaderText
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
        {
                label = "Int.",
                value = function(car, width, height)
                        local intervalText
                        if race:getLeaderboardPosition(car.index) == 1 then
                                intervalText = "Interval"
                        elseif sim.raceSessionType == ac.SessionType.Race and car.lapsToCarAheadLeaderboard > 0 then
                                intervalText = "+%s L" % car.lapsToCarAheadLeaderboard
                        else
                                intervalText = string.format("%+.2f", car.gapToCarAheadLeaderboard / 1000)
                        end

                        return intervalText
                end,
                xShare = 0.09,
                align = ui.Alignment.Center,
        },
        {
                label = "Lap",
                value = function(car, width, height) return string.format("%02d", car.status.sessionLapCount + 1) end,
                xShare = 0.065,
                align = ui.Alignment.Center,
        },
        {
                label = "Tyre",
                value = function(car, width, height)
                        local statusText = ac.getTyresName(car.index, car.compoundIndex)
                        local altStatus = false

                        if car.status.isRetired then
                                statusText = "DNF"
                                altStatus = true
                        elseif car.status.isInPit or car.status.isInPitlane then
                                statusText = "PIT"
                                altStatus = true
                        else
                                statusText = ac.getTyresName(car.index, car.status.compoundIndex)
                        end

                        if altStatus then
                                ui.drawRectFilled(
                                        vec2(ui.getCursorX(), ui.getCursorY()),
                                        vec2(ui.getCursorX() + width, ui.getCursorY() + height),
                                        settings.Appearance.uiThemeColor3
                                )
                        end

                        return statusText, altStatus and rgbm.colors.black or rgbm.colors.white
                end,
                xShare = 0.06,
                align = ui.Alignment.Center,
        },
}

local leaderboard = {}

local function leaderboardBanner(yPos, height)
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

function leaderboardEntryButton(car, yPos, height)
        local xPos = 0
        local width = ui.windowWidth()

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        if ui.invisibleButton("##leaderboardEntryButton" .. car.index, vec2(width, height)) then
                if car.status.isConnected then ac.focusCar(car.index) end
        end

        local leaderboardPosition = car.leaderboardPosition
        local evenCar = leaderboardPosition % 2 == 0

        local numberBoxColor = rgbm.colors.transparent
        if sim.focusedCar == car.index then
                numberBoxColor = settings.Appearance.uiThemeColor2
        elseif car.index == 0 then
                numberBoxColor = settings.Appearance.uiThemeColor3
        end
        ui.drawRectFilled(vec2(xPos, yPos), vec2(xPos + height, yPos + height), settings.Appearance.uiThemeColor1)
        ui.drawRectFilled(
                vec2(xPos, yPos),
                vec2(xPos + width, yPos + height),
                evenCar and settings.Appearance.uiThemeColor1 * 0.15 or settings.Appearance.uiThemeColor1 * 0.5
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

                ui.drawRectFilled(vec2(height * 0.1, yPos), vec2(0, yPos + height), rgbm.colors.black)

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
                ui.dwriteTextAligned(value, height * 0.5, entry.align, ui.Alignment.Center, vec2(x, y), false, color)
                ui.sameLine()
        end

        if not car.status.isConnected then
                ui.drawRectFilled(vec2(xPos, yPos), vec2(xPos + width, yPos + height), rgbm(0.1, 0.1, 0.1, 0.6))
        end
end

local isLeaderboardShowingDisconnected = false

function leaderboard:draw(xPos, yPos, width, height)
        cui.pushWindow("leaderboard_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiThemeColor1 * 0.25)
        ui.setCursor(0)

        local height = ui.windowHeight() / 22
        leaderboardBanner(0, height)

        cui.pushWindow(
                "home_leaderboard_entrant_window",
                0,
                height,
                ui.windowWidth(),
                ui.windowHeight() - height * 2,
                true
        )
        for leaderboardIndex, slot in ipairs(race.leaderboard) do
                if slot.car.isConnected or isLeaderboardShowingDisconnected then
                        leaderboardEntryButton(race.cars[slot.car.index], (leaderboardIndex - 1) * height, height)
                end
        end
        cui.dummy(height, height)
        cui.popWindow(true)

        ui.drawRectFilled(
                vec2(0, ui.windowHeight() - height),
                vec2(width, ui.windowHeight()),
                rgbm(0.1, 0.1, 0.1, 0.95)
        )

        ui.setCursorX(0)

        if
                cui.menuButton(
                        isLeaderboardShowingDisconnected and "Hide Disconnected" or "Show Disconnected",
                        vec2(ui.windowWidth() * 0.2, height),
                        0,
                        0,
                        ui.ButtonFlags.None
                )
        then
                isLeaderboardShowingDisconnected = not isLeaderboardShowingDisconnected
        end

        cui.popWindow()
end

return leaderboard
