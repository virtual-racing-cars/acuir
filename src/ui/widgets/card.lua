local camera = require("camera")
local cui = require("ui.cui")
local race = require("race")
local settings = require("settings")
local units = require("units")
local sim = ac.getSim()

local card = {}

local spectatedCarInfo = {
        {
                label = "Driver",
                value = function(car)
                        local driverName = ac.getDriverName(car.index)
                        driverName = isempty(driverName) and "Driver %s" % car.index or driverName
                        return driverName
                end,
        },
        {
                label = "Car",
                value = function(car) return ac.getCarName(car.index) end,
        },
        {
                label = "Pos",
                value = function(car) return car.racePosition end,
        },
        {
                label = "Laps",
                value = function(car) return car.lapCount end,
        },
        {
                label = "Best Lap",
                value = function(car) return ac.lapTimeToString(car.bestLapTimeMs) end,
        },
        {
                label = "Last Lap",
                value = function(car) return ac.lapTimeToString(car.previousLapTimeMs) end,
        },
        {
                label = "Ping",
                value = function(car) return string.format("%s ms", car.ping) end,
        },
}

local cameraModeString = {
        [ac.CameraMode.Cockpit] = function() return "Cockpit" end,
        [ac.CameraMode.Drivable] = function()
                for k, v in pairs(ac.DrivableCamera) do
                        if v == sim.driveableCameraMode then return "Car " .. k end
                end
        end,
        [ac.CameraMode.Car] = function() return "Car %s" % sim.carCameraIndex end,
        [ac.CameraMode.Track] = function() return "Track %s" % sim.trackCamerasSet end,
        [ac.CameraMode.Free] = function() return "Free" end,
        [ac.CameraMode.Helicopter] = function() return "Heli" end,
        [ac.CameraMode.OnBoardFree] = function() return "Orbit" end,
        [ac.CameraMode.Start] = function() return "Start" end,
}

function card:draw(xPos, yPos, width, height)
        local border = 10 * cui.uiScale()

        cui.pushWindow("card_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth() * 0.5, ui.windowHeight()), settings.Appearance.uiColor1)

        local spectatedCar = ac.getCar(sim.focusedCar)

        cui.pushWindow(
                "player_card",
                border,
                border,
                (ui.windowWidth() - border * 2) * 0.5,
                ui.windowHeight() - border * 2,
                false
        )

        local fontSize = 20 * cui.uiScale()

        ui.setCursor(0)
        for _, info in ipairs(spectatedCarInfo) do
                cui.snapCursor()
                ui.dwriteText(string.format("%s: %s", info.label, info.value(spectatedCar)), fontSize)
                if info.sameLine then
                        ui.sameLine()
                        ui.setCursorX(ui.windowWidth() * 0.5)
                else
                        ui.setCursorX(0)
                end
        end

        local skin = string.format(
                "%s\\%s\\skins\\%s\\livery.png",
                ac.getFolder(ac.FolderID.ContentCars),
                ac.getCarID(spectatedCar.index),
                ac.getCarSkinID(spectatedCar.index)
        )
        local skinImageSize = 100 * cui.uiScale()

        ui.setCursorX(ui.windowWidth() - skinImageSize - border)
        ui.setCursorY(ui.windowHeight() - skinImageSize)
        ui.image(skin, vec2(skinImageSize, skinImageSize))

        cui:setCenterCursorAround(200, fontSize, ui.windowWidth() - skinImageSize * 0.5 - border, fontSize * 0.5)
        ui.dwriteTextAligned("Camera", fontSize, ui.Alignment.Center, ui.Alignment.Center, vec2(200, fontSize))

        cui:setCenterCursorAround(200, fontSize, ui.windowWidth() - skinImageSize * 0.5 - border, fontSize * 2)
        ui.dwriteTextAligned(
                cameraModeString[sim.cameraMode](),
                fontSize,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(200, fontSize)
        )

        cui.popWindow()

        cui.popWindow()
end

return card
