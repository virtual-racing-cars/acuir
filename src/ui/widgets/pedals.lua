local cui = require("ui.cui")
local race = require("race")
local settings = require("settings")
local style = require("ui.cui.style")
local units = require("units")
local sim = ac.getSim()

local card = {}

local function progressBar(progress, xPos, yPos, width, color, thickness)
        ui.drawSimpleLine(vec2(xPos, yPos), vec2(xPos + width, yPos), rgbm(0.3, 0.3, 0.3, 1), thickness)
        ui.drawSimpleLine(vec2(xPos, yPos), vec2(xPos + width * progress, yPos), color, thickness)
end

function card:draw(xPos, yPos, width, height)
        local border = 20 * cui.scale()

        cui.pushWindow("pedals_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(
                vec2(0, 0),
                ui.windowSize(),
                settings.Appearance.uiColorBackground,
                6 * cui.scale(),
                ui.CornerFlags.All
        )
        local spectatedCar = ac.getCar(sim.focusedCar)

        cui.setCursorX(15)
        cui.setCursorY(50)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "SPEED",
                style.main.font.body.size,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 32 * cui.scale())
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "POSITION",
                style.main.font.body.size,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 32 * cui.scale())
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "LAST LAP",
                style.main.font.body.size,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 32 * cui.scale())
        )

        cui.setCursorX(15)
        cui.setCursorY(15)
        cui.snapCursor()
        ui.dwriteTextAligned(
                math.round(units:speed(spectatedCar.speedKmh)),
                32 * cui.scale(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 32 * cui.scale())
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                race:getLeaderboardPosition(spectatedCar.index),
                32 * cui.scale(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 32 * cui.scale())
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.lapTimeToString(spectatedCar.previousLapTimeMs),
                32 * cui.scale(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 32 * cui.scale())
        )
        ui.sameLine()

        cui.pushWindow("telem_card", 0, ui.windowHeight() * 0.45, ui.windowWidth(), ui.windowHeight() * 0.5, true)

        cui.setCursorX(0)
        cui.setCursorY(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "Gear\n" .. ac.getCarGearLabel(spectatedCar.index),
                40 * cui.scale(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(100 * cui.scale(), ui.windowHeight())
        )

        local barPosition = ui.windowHeight() / 20 * 4
        local barStart = 100 * cui.scale()
        local barWidth = ui.availableSpaceX() - barStart - 15 * cui.scale()

        local steer = math.round(math.clamp(spectatedCar.steer / spectatedCar.steerLock, -1, 1), 3)

        if math.isnan(spectatedCar.steer) then steer = 0 end

        progressBar(
                math.max(steer, 0),
                barStart + barWidth * 0.5,
                barPosition,
                barWidth * 0.5 * 0.93,
                rgbm(1, 0.5, 0, 1),
                border
        )
        progressBar(
                steer >= 1 and 1 or 0,
                barStart + barWidth * 0.975,
                barPosition,
                barWidth * 0.5 * 0.05,
                rgbm(1, 0.5, 0, 1),
                border
        )

        progressBar(
                -math.min(steer, 0),
                barStart + barWidth * 0.5,
                barPosition,
                -barWidth * 0.5 * 0.93,
                rgbm(1, 0.5, 0, 1),
                border
        )
        progressBar(steer <= -1 and 1 or 0, barStart, barPosition, barWidth * 0.5 * 0.05, rgbm(1, 0.5, 0, 1), border)

        barPosition = (ui.windowHeight() / 20) * 10

        local gas = math.round(spectatedCar.gas, 3)
        progressBar(gas, barStart, barPosition, barWidth * 0.965, rgbm(0, 0.8, 0, 1), border)
        progressBar(
                gas >= 1 and 1 or 0,
                barStart + barWidth * 0.975,
                barPosition,
                barWidth * 0.025,
                rgbm(0, 0.8, 0, 1),
                border
        )

        barPosition = (ui.windowHeight() / 20) * 16

        local brake = math.round(spectatedCar.brake, 3)

        progressBar(brake, barStart, barPosition, barWidth * 0.965, rgbm.colors.red, border)
        progressBar(
                brake >= 1 and 1 or 0,
                barStart + barWidth * 0.975,
                barPosition,
                barWidth * 0.025,
                rgbm.colors.red,
                border
        )

        cui.popWindow()
        cui.popWindow()
end

return card
