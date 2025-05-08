local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()
local race = require("race")
local simutils = require("simutils")

function playerListBanner(xPos, yPos, width, height)
        width = width - width / 50

        local fontSize = math.floor(24 * cui.scaleY())
        fontSize = (fontSize % 2 == 0) and fontSize + 1 or fontSize

        ui.beginGroup(width)
        ui.drawRectFilled(vec2(0, yPos), vec2(width, yPos + height), settings.Appearance.uiColor1)

        ui.setCursorX(0)
        ui.setCursorY(yPos)
        ui.dwriteTextAligned("Pos", fontSize, ui.Alignment.Center, ui.Alignment.Center, vec2(height, height))
        ui.sameLine(height)

        cui.snapCursor()
        ui.dwriteTextAligned(
                "Driver",
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX() * 0.35, height)
        )
        ui.sameLine()

        ui.dwriteTextAligned(
                "Car",
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX() * 0.3, height)
        )
        ui.sameLine()

        local infoWidth = (width - ui.getCursorX()) / 6

        cui.snapCursor()
        ui.dwriteTextAligned(
                "Last",
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "Best",
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "Gap",
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "Int.",
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "Lap",
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "Tyre",
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )

        ui.endGroup()
end

function playerListButton(car, xPos, yPos, width, height)
        width = width - width / 50

        ui.beginGroup(width)

        local fontSize = height * 0.5

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        if ui.invisibleButton("##playerlistbutton" .. car.index, vec2(width, height)) then
                if car.isConnected then ac.focusCar(car.index) end
        end

        local evenCar = car.racePosition % 2 == 0
        ui.drawRectFilled(
                vec2(xPos, yPos),
                vec2(xPos + width, yPos + height),
                evenCar and settings.Appearance.uiColor1 / 4 or settings.Appearance.uiColor1 / 2
        )

        ui.drawRectFilled(
                vec2(xPos, yPos),
                vec2(xPos + height, yPos + height),
                sim.focusedCar == car.index and settings.Appearance.uiColor2
                        or (car.index == 0 and settings.Appearance.uiColor3 or settings.Appearance.uiColor1)
        )

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        cui.snapCursor()
        ui.dwriteTextAligned(
                car.racePosition,
                fontSize * 1.3,
                ui.Alignment.End,
                ui.Alignment.Center,
                vec2(height * 0.8, height),
                false,
                car.index == 0 and rgbm.colors.black or nil
        )
        ui.sameLine(height)

        ui.setCursorY(yPos)
        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.getDriverName(car.index),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX() * 0.35, height)
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.INIConfig.carData(car.index, "car.ini"):get("INFO", "SHORT_NAME", ac.getCarName(car.index)),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.availableSpaceX() * 0.3, height)
        )
        ui.sameLine()

        local infoWidth = (width - ui.getCursorX()) / 6

        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.lapTimeToString(car.previousLapTimeMs),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.lapTimeToString(car.bestLapTimeMs),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        if not car.isConnected then
                ui.drawRectFilled(vec2(xPos, yPos), vec2(xPos + width, yPos + height), rgbm(0.1, 0.1, 0.1, 0.6))

                ui.drawLine(vec2(xPos, yPos), vec2(xPos + width, yPos), rgbm.colors.black)
                ui.drawLine(vec2(xPos, yPos + height), vec2(xPos + width, yPos + height), rgbm.colors.black)

                ui.endGroup()

                return
        end

        cui.snapCursor()
        ui.dwriteTextAligned(
                string.format("%.3f", race.leaderboardGaps[car.index] / 1000),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                string.format("%.3f", race.intervals[car.index] / 1000),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                string.format("%02d", car.lapCount + 1),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(infoWidth, height),
                false,
                rgbm.colors.white
        )
        ui.sameLine()

        if car.isInPitlane or car.isRetired then
                ui.drawRectFilled(
                        vec2(ui.getCursorX(), yPos),
                        vec2(ui.getCursorX() + infoWidth, yPos + height),
                        settings.Appearance.uiColor3
                )

                cui.snapCursor()
                ui.dwriteTextAligned(
                        car.isRetired and "DNF" or "PIT",
                        fontSize,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(infoWidth, height),
                        false,
                        rgbm.colors.black
                )
        else
                cui.snapCursor()
                ui.dwriteTextAligned(
                        ac.getTyresName(car.index, car.compoundIndex),
                        fontSize,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(infoWidth, height),
                        false,
                        rgbm.colors.white
                )
        end

        ui.drawLine(vec2(xPos, yPos), vec2(xPos + width, yPos), rgbm.colors.black)
        ui.drawLine(vec2(xPos, yPos + height), vec2(xPos + width, yPos + height), rgbm.colors.black)

        ui.endGroup()
end
