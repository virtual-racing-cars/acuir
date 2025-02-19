local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()

function playerListBanner(xPos, yPos, width, height)
        width = width - width / 50

        ui.beginGroup(width)

        local fontSize = math.floor(24 * cui.scaleY())
        fontSize = (fontSize % 2 == 0) and fontSize + 1 or fontSize

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        if ui.invisibleButton("##playerlistbuttonbanner", vec2(width, height)) then
                -- ac.focusCar(car.index)
        end

        ui.drawRectFilled(vec2(xPos, yPos), vec2(xPos + width, yPos + height), rgbm.colors.black)

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        ui.dwriteTextAligned("Pos", fontSize, ui.Alignment.Center, ui.Alignment.Center, vec2(width / 15, height))

        ui.setCursorX(xPos + math.floor(width / 12))
        ui.setCursorY(yPos)
        cui.snapCursor()
        ui.dwriteTextAligned("Driver", fontSize, ui.Alignment.Center, ui.Alignment.Center, vec2(width / 3, height))

        ui.sameLine()

        local infoWidth = width / 6

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
                "Tyre",
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
                vec2(infoWidth / 2, height),
                false,
                rgbm.colors.white
        )

        ui.endGroup()
end

function playerListButton(car, xPos, yPos, width, height)
        width = width - width / 50

        ui.beginGroup(width)

        local fontSize = height / 2

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
                vec2(xPos + width / 15, yPos + height),
                sim.focusedCar == car.index and settings.Appearance.uiColor2
                        or (car.index == 0 and settings.Appearance.uiColor3 or settings.Appearance.uiColor1)
        )

        ui.setCursorX(xPos)
        ui.setCursorY(yPos)
        cui.snapCursor()
        ui.dwriteTextAligned(
                car.racePosition,
                fontSize,
                ui.Alignment.End,
                ui.Alignment.Center,
                vec2(width / 20, height),
                false,
                car.index == 0 and rgbm.colors.black or nil
        )

        ui.setCursorX(xPos + width / 12)
        ui.setCursorY(yPos)
        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.getDriverName(car.index),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(width / 3, height)
        )

        ui.sameLine()

        local infoWidth = width / 6

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
                ac.getTyresName(car.index, car.compoundIndex),
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
                        vec2(ui.getCursorX() + infoWidth / 2, yPos + height),
                        settings.Appearance.uiColor3
                )

                cui.snapCursor()
                ui.dwriteTextAligned(
                        "P",
                        fontSize,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(infoWidth / 2, height),
                        false,
                        rgbm.colors.black
                )
        else
                cui.snapCursor()
                ui.dwriteTextAligned(
                        "L" .. car.lapCount + 1,
                        fontSize,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        vec2(infoWidth / 2, height),
                        false,
                        rgbm.colors.white
                )
        end

        ui.drawLine(vec2(xPos, yPos), vec2(xPos + width, yPos), rgbm.colors.black)
        ui.drawLine(vec2(xPos, yPos + height), vec2(xPos + width, yPos + height), rgbm.colors.black)

        ui.endGroup()
end
