local cui = require("ui.cui")
local settings = require("settings")
local sim = ac.getSim()

local card = {}

function card:draw(xPos, yPos, width, height)
        local border = 15 * cui.scaleY()

        cui.pushWindow("card_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColor1)

        local spectatedCar = ac.getCar(sim.focusedCar)

        local skin = string.format(
                "%s\\%s\\skins\\%s\\livery.png",
                ac.getFolder(ac.FolderID.ContentCars),
                ac.getCarID(spectatedCar.index),
                ac.getCarSkinID(spectatedCar.index)
        )
        local skinImageSize = vec2(110, 110) * cui.scaleY()

        cui.pushWindow("player_card", 0, 0, ui.windowWidth() * 0.4, ui.windowHeight(), false)

        ui.setCursorX(ui.windowWidth() / 2 - (skinImageSize.x / 2))
        ui.setCursorY(ui.windowHeight() / 2 - skinImageSize.y * 0.8)

        ui.image(skin, skinImageSize)

        ui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() / 2 + skinImageSize.y * 0.35)

        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.getDriverName(spectatedCar.index),
                24 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), 48 * cui.scaleY())
        )

        ui.setCursorX(ui.windowWidth() * 0.05)
        ui.setCursorY(ui.windowHeight() / 2 + skinImageSize.y * 0.4)
        if
                cui.iconButton(
                        "##prevCar",
                        ui.Icons.Skip,
                        36 * cui.scaleY(),
                        36 * cui.scaleY(),
                        ui.ButtonFlags.None,
                        true,
                        1
                )
        then
                local newSpectatedIndex = spectatedCar.index == 0 and sim.carsCount - 1 or spectatedCar.index - 1
                ac.focusCar(newSpectatedIndex)
        end

        ui.setCursorX(ui.windowWidth() - ui.windowWidth() * 0.05 - 36 * cui.scaleY())
        ui.setCursorY(ui.windowHeight() / 2 + skinImageSize.y * 0.4)
        if
                cui.iconButton(
                        "##nextCar",
                        ui.Icons.Skip,
                        36 * cui.scaleY(),
                        36 * cui.scaleY(),
                        ui.ButtonFlags.None,
                        false,
                        1
                )
        then
                local newSpectatedIndex = spectatedCar.index == sim.carsCount - 1 and 0 or spectatedCar.index + 1
                ac.focusCar(newSpectatedIndex)
        end

        cui.popWindow()

        cui.pushWindow(
                "telem_card2",
                ui.windowWidth() * 0.42,
                0,
                ui.windowWidth() * 0.55,
                ui.windowHeight() * 0.5,
                false
        )

        cui.setCursorX(15)
        cui.setCursorY(50)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "SPEED",
                18 * cui.scaleY(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "POSITION",
                18 * cui.scaleY(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "LAST LAP",
                18 * cui.scaleY(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )

        cui.setCursorX(15)
        cui.setCursorY(15)
        cui.snapCursor()
        ui.dwriteTextAligned(
                math.round(spectatedCar.speedKmh),
                36 * cui.scaleY(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                spectatedCar.lapCount,
                36 * cui.scaleY(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.lapTimeToString(spectatedCar.bestLapTimeMs),
                36 * cui.scaleY(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        cui.popWindow()

        cui.pushWindow(
                "telem_card",
                ui.windowWidth() * 0.42,
                ui.windowHeight() * 0.45,
                ui.windowWidth() * 0.55,
                ui.windowHeight() * 0.5,
                true
        )
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight() - border), settings.Appearance.uiColor1)

        cui.setCursorX(0)
        cui.setCursorY(-5)
        ui.dwriteTextAligned(
                "Gear\n" .. ac.getCarGearLabel(spectatedCar.index),
                40 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(80, ui.windowHeight())
        )

        local barPosition = ui.windowHeight() / 20 * 2

        local steer = spectatedCar.steer / spectatedCar.steerLock

        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + ui.windowWidth(), barPosition),
                rgbm(0.3, 0.3, 0.3, 1),
                border
        )
        ui.drawSimpleLine(
                vec2(100 + (ui.windowWidth() - 100) * 0.5, barPosition),
                vec2(100 + (ui.windowWidth() - 100) * 0.5 + (ui.windowWidth() - 100) * 0.5 * steer, barPosition),
                rgbm(1, 0.5, 0, 1),
                border
        )

        barPosition = (ui.windowHeight() / 20) * 7

        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100), barPosition),
                rgbm(0.3, 0.3, 0.3, 1),
                border
        )

        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100) * spectatedCar.gas, barPosition),
                rgbm(0, 0.8, 0, 1),
                border
        )

        barPosition = (ui.windowHeight() / 20) * 12

        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100), barPosition),
                rgbm(0.3, 0.3, 0.3, 1),
                border
        )
        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100) * spectatedCar.brake, barPosition),
                rgbm(1, 0.3, 0.3, 1),
                border
        )

        barPosition = (ui.windowHeight() / 20) * 17

        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + ui.windowWidth(), barPosition),
                rgbm(0.3, 0.3, 0.3, 1),
                border
        )
        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100) * (1 - spectatedCar.clutch), barPosition),
                rgbm(0.1, 0.4, 1, 1),
                border
        )

        cui.popWindow()

        cui.popWindow()
end

return card
