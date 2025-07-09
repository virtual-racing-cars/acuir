local cui = require("ui.cui")
local race = require("race")
local settings = require("settings")
local style = require("src.ui.style")
local sim = ac.getSim()

local card = {}

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

local function getDriverTags(carIndex) return ac.DriverTags(ac.getDriverName(carIndex)) end

local comboActive = false

function card:draw(xPos, yPos, width, height)
        local border = 10 * cui.scale()

        cui.pushWindow("card_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorBackground, 12, ui.CornerFlags.Left)

        local spectatedCar = ac.getCar(sim.focusedCar)

        cui.pushWindow(
                "player_card",
                border,
                border,
                (ui.windowWidth() - border * 2),
                ui.windowHeight() - border * 2,
                false
        )

        local fontSize = style.main.font.body.size

        local driverName = ac.getDriverName(sim.focusedCar)
        driverName = isempty(driverName) and "Driver %s" % sim.focusedCar or driverName

        ui.setCursor(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                driverName,
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), fontSize * 1.2)
        )

        cui.setCursorX(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.getCarName(spectatedCar.index),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.End,
                vec2(ui.windowWidth(), fontSize * 1.5)
        )

        cui.offsetCursorY(20)
        cui.offsetCursorX(46)
        local size = vec2(ui.availableSpaceX() - 92 * cui.scale(), style.main.font.body.size * 2)
        cui.combo(
                "##comboCurrentCamera",
                size,
                string.format("Camera: %s", cameraModeString[sim.cameraMode]()),
                ui.Alignment.Center,
                false,
                vec2(ui.availableSpaceX() - 92 * cui.scale(), size.y * 8),
                function()
                        for k, v in pairs(cameraModeString) do
                                ui.setCursorX(0)
                                local ty = ui.getCursorY()
                                if cui.menuButton(v(), size) then ac.setCurrentCamera(k) end
                                ac.log(ui.getCursorY() - ty, size.y)
                        end
                end
        )

        local skin = string.format(
                "%s\\%s\\skins\\%s\\livery.png",
                ac.getFolder(ac.FolderID.ContentCars),
                ac.getCarID(spectatedCar.index),
                ac.getCarSkinID(spectatedCar.index)
        )
        local skinImageSize = fontSize * 3

        ui.setCursorX(ui.windowWidth() - skinImageSize)
        ui.setCursorY(0)
        ui.drawImageRounded(skin, ui.getCursor(), ui.getCursor() + vec2(skinImageSize, skinImageSize), 6 * cui.scale())

        local managePlayerButtonSize = 42 * cui:uiScale()
        ui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() - managePlayerButtonSize * 1.75)

        if not sim.isOnlineRace or spectatedCar.index == 0 then
                cui.popWindow()
                cui.popWindow()
                return
        end

        local driverTags = getDriverTags(spectatedCar.index)

        if
                cui.iconButton(
                        "Add",
                        ui.Icons.Befriend,
                        managePlayerButtonSize,
                        managePlayerButtonSize,
                        ui.ButtonFlags.None,
                        false,
                        1
                )
        then
                driverTags.friend = not driverTags.friend
        end

        cui.dummy(30, 3)
        ui.sameLine()

        if
                cui.iconButton(
                        "Tag",
                        ui.Icons.Tag,
                        managePlayerButtonSize,
                        managePlayerButtonSize,
                        ui.ButtonFlags.None,
                        false,
                        1
                )
        then
        end

        cui.dummy(30, 3)
        ui.sameLine()

        if
                cui.iconButton(
                        "Mute",
                        ui.Icons.Ban,
                        managePlayerButtonSize,
                        managePlayerButtonSize,
                        ui.ButtonFlags.None,
                        false,
                        1
                )
        then
                driverTags.mute = not driverTags.mute
        end

        cui.dummy(30, 3)
        ui.sameLine()

        if
                cui.iconButton(
                        "Kick",
                        ui.Icons.Kick,
                        managePlayerButtonSize,
                        managePlayerButtonSize,
                        ui.ButtonFlags.None,
                        false,
                        1
                )
        then
                ac.castVote("kick", true, spectatedCar.index)
        end
        ui.sameLine()

        local pingColor = rgbm.colors.green

        if spectatedCar.ping > 300 then
                pingColor = rgbm.colors.red
        elseif spectatedCar.ping > 250 then
                pingColor = rgbm.colors.orange
        elseif spectatedCar.ping > 100 then
                pingColor = rgbm.colors.yellow
        end

        cui.offsetCursorY(-20)
        cui.offsetCursorX(0)
        cui.snapCursor()
        ui.dwriteTextAligned(
                string.format("Ping %s ms", spectatedCar.ping),
                22 * cui.scale(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(120 * cui.scale(), managePlayerButtonSize),
                false,
                pingColor
        )

        cui.popWindow()

        cui.popWindow()
end

return card
