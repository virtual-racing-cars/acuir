local cui = require("ui.cui")
local race = require("race")
local settings = require("settings")
local style = require("ui.cui.style")
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

local function nextCamera(car)
        if sim.cameraMode == ac.CameraMode.Car and sim.carCameraIndex < car.carCamerasCount - 1 then
                ac.setCurrentCarCamera(sim.carCameraIndex + 1)

                return
        elseif sim.cameraMode == ac.CameraMode.Track and sim.trackCamerasSet < sim.trackCamerasSetsCount - 1 then
                ac.setCurrentTrackCamera(sim.trackCamerasSet + 1)

                return
        elseif sim.cameraMode == ac.CameraMode.Drivable and sim.driveableCameraMode < 4 then
                ac.setCurrentDrivableCamera(sim.driveableCameraMode + 1)
                return
        end

        local nextMainCamera = sim.cameraMode < 9 and sim.cameraMode + 1 or 0
        if nextMainCamera > 6 and nextMainCamera < 9 then nextMainCamera = 9 end

        if nextMainCamera == ac.CameraMode.Car then
                ac.setCurrentCarCamera(0)
        elseif nextMainCamera == ac.CameraMode.Track then
                ac.setCurrentTrackCamera(0)
        elseif nextMainCamera == ac.CameraMode.Drivable then
                ac.setCurrentDrivableCamera(0)
        end

        ac.setCurrentCamera(nextMainCamera)
end

local function previousCamera(car)
        if sim.cameraMode == ac.CameraMode.Car and sim.carCameraIndex > 0 then
                ac.setCurrentCarCamera(sim.carCameraIndex - 1)

                return
        elseif sim.cameraMode == ac.CameraMode.Track and sim.trackCamerasSet > 0 then
                ac.setCurrentTrackCamera(sim.trackCamerasSet - 1)

                return
        elseif sim.cameraMode == ac.CameraMode.Drivable and sim.driveableCameraMode > 0 then
                ac.setCurrentDrivableCamera(sim.driveableCameraMode - 1)
                return
        end

        local previousMainCamera = sim.cameraMode > 0 and sim.cameraMode - 1 or 9
        if previousMainCamera > 6 and previousMainCamera < 9 then previousMainCamera = 6 end

        if previousMainCamera == ac.CameraMode.Car then ac.setCurrentCarCamera(car.carCamerasCount - 1) end

        if previousMainCamera == ac.CameraMode.Car then
                ac.setCurrentCarCamera(car.carCamerasCount - 1)
        elseif previousMainCamera == ac.CameraMode.Track then
                ac.setCurrentTrackCamera(sim.trackCamerasSetsCount - 1)
        elseif previousMainCamera == ac.CameraMode.Drivable then
                ac.setCurrentDrivableCamera(4)
        end

        ac.setCurrentCamera(previousMainCamera)
end

local function getDriverTags(carIndex) return ac.DriverTags(ac.getDriverName(carIndex)) end

local comboActive = false

function card:draw(xPos, yPos, width, height)
        local fontSize = style.main.font.body.size
        local fontSpace = style.main.font.body.space

        cui.pushWindow("card_widget_window", xPos, yPos, width, height, false)
        local border = style.main.margins.innerSize
        local buttonHeight = style.main.font.body.size * 2
        local comboSize = vec2(ui.availableSpaceX() - 25 * cui.scale() - buttonHeight * 2, buttonHeight)

        ui.drawRectFilled(
                0,
                ui.windowSize(),
                settings.Appearance.uiColorBackground,
                6 * cui.scale(),
                ui.CornerFlags.All
        )

        local spectatedCar = ac.getCar(sim.focusedCar)

        cui.pushWindow(
                "player_card",
                border,
                border,
                (ui.windowWidth() - border * 2),
                ui.windowHeight() - border * 2,
                false
        )

        ui.setCursor(0)

        local p = ui.getCursor()
        ui.drawImageRounded(
                string.format(
                        "%s\\%s\\skins\\%s\\livery.png",
                        ac.getFolder(ac.FolderID.ContentCars),
                        ac.getCarID(spectatedCar.index),
                        ac.getCarSkinID(spectatedCar.index)
                ),
                p,
                p + vec2(fontSpace, fontSpace) * 2,
                6 * cui.scale()
        )

        local driverName = ac.getDriverName(sim.focusedCar)
        driverName = isempty(driverName) and "Driver %s" % sim.focusedCar or driverName

        ui.setCursor(0)
        ui.setCursorX(fontSpace * 2 + 10 * cui.scale())
        cui.snapCursor()
        ui.dwriteTextAligned(
                driverName,
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), fontSpace)
        )

        ui.setCursorX(fontSpace * 2 + 10 * cui.scale())
        ui.dwriteTextAligned(
                ac.getCarName(spectatedCar.index),
                fontSize,
                ui.Alignment.Start,
                ui.Alignment.End,
                vec2(ui.windowWidth(), fontSpace)
        )

        cui.setCursorX(0)
        cui.offsetCursorY(15)
        if
                cui.iconButton(
                        "##previous_driver",
                        ui.Icons.Play,
                        buttonHeight,
                        buttonHeight,
                        ui.ButtonFlags.None,
                        true,
                        0.5
                )
        then
                previousCamera(spectatedCar)
        end
        ui.sameLine()
        cui.offsetCursorX(5)

        cui.combo(
                "##comboCurrentCamera",
                comboSize,
                string.format("Camera: %s", cameraModeString[sim.cameraMode]()),
                ui.Alignment.Center,
                false,
                vec2(comboSize.x, comboSize.y * 8),
                function()
                        cui.offsetCursorY(5)
                        for k, v in pairs(cameraModeString) do
                                ui.setCursorX(0)
                                if cui.selectable(v(), ui.Alignment.Center) then ac.setCurrentCamera(k) end
                                cui.offsetCursorY(5)
                        end
                end
        )

        ui.sameLine()
        cui.offsetCursorX(5)

        if
                cui.iconButton(
                        "##next_camera",
                        ui.Icons.Play,
                        buttonHeight,
                        buttonHeight,
                        ui.ButtonFlags.None,
                        false,
                        0.5
                )
        then
                nextCamera(spectatedCar)
        end

        local managePlayerButtonWidth = buttonHeight
        local managePlayerButtonHeight = managePlayerButtonWidth * 2
        ui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() - managePlayerButtonHeight)

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
                        managePlayerButtonWidth,
                        managePlayerButtonHeight,
                        ui.ButtonFlags.None,
                        false,
                        1
                )
        then
                driverTags.friend = not driverTags.friend
        end

        ui.sameLine()
        cui.offsetCursorX(30)

        if
                cui.iconButton(
                        "Tag",
                        ui.Icons.Tag,
                        managePlayerButtonWidth,
                        managePlayerButtonHeight,
                        ui.ButtonFlags.None,
                        false,
                        1
                )
        then
        end
        ui.sameLine()
        cui.offsetCursorX(30)

        if
                cui.iconButton(
                        "Mute",
                        ui.Icons.Ban,
                        managePlayerButtonWidth,
                        managePlayerButtonHeight,
                        ui.ButtonFlags.None,
                        false,
                        1
                )
        then
                driverTags.mute = not driverTags.mute
        end
        ui.sameLine()
        cui.offsetCursorX(30)

        if
                cui.iconButton(
                        "Kick",
                        ui.Icons.Kick,
                        managePlayerButtonWidth,
                        managePlayerButtonHeight,
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

        cui.offsetCursorX(30)
        ui.dwriteTextAligned(
                string.format("Ping\n%s ms", spectatedCar.ping),
                style.main.font.body.size,
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(managePlayerButtonWidth * 2, managePlayerButtonHeight),
                false,
                pingColor
        )

        cui.popWindow()
        cui.popWindow()
end

return card
