local sim = ac.getSim()

local page = {}

require("src.classes.PlayerListButton")
local cui = require("ui.cui")
local race = require("race")
local replay = require("replay")
local settings = require("settings")

require("src.ui.main.map")

local replayButtons = {
        {
                label = ui.Icons.Camera,
                enabled = false,
                scale = 0.5,
                func = function() end,
        },
        {
                label = ui.Icons.Start,
                enabled = true,
                scale = -0.75,
                func = function()
                        ac.tryToToggleReplay(true, 0)
                        replay:jumpToStart()
                end,
        },

        {
                label = ui.Icons.Next,
                enabled = true,
                scale = 0.75,
                condition = function() end,
                func = function() ac.tryToToggleReplay(true, 0) end,
        },
        {
                label = ui.Icons.FastForward,
                enabled = true,
                scale = 1,
                func = function()
                        if not sim.isReplayActive then replay.frame = sim.replayCurrentFrame end

                        if not replay.isPlaying then
                                replay.isPlaying = true
                                replay.rate = 1
                        end

                        replay:setPlayback(-1, replay.rate + 0.5)
                        ac.tryToToggleReplay(true, 0)
                end,
        },
        {
                label = ui.Icons.Play,
                enabled = true,
                scale = 1,
                func = function()
                        if not sim.isReplayActive then replay.frame = sim.replayCurrentFrame end

                        replay:setPlayback(1, 1)
                        replay.isPlaying = not replay.isPlaying

                        ac.tryToToggleReplay(true, 0)
                end,
        },
        {
                label = ui.Icons.FastForward,
                enabled = true,
                scale = 1,
                func = function()
                        if not sim.isReplayActive then replay.frame = sim.replayCurrentFrame end

                        if not replay.isPlaying then
                                replay.isPlaying = true
                                replay.rate = 1
                        end

                        replay:setPlayback(1, replay.rate + 0.5)

                        ac.tryToToggleReplay(true, 0)
                end,
        },
        {
                label = ui.Icons.Next,
                enabled = true,
                scale = 0.75,
                func = function() ac.tryToToggleReplay(true, 0) end,
        },
        {
                label = ui.Icons.Finish,
                enabled = true,
                scale = 0.75,
                func = function()
                        ac.tryToToggleReplay(true, 0)
                        replay:jumpToEnd()
                end,
        },
        {
                label = ui.Icons.Resume,
                enabled = true,
                scale = 0.5,
                condition = function() return sim.isReplayActive end,
                func = function()
                        ac.tryToToggleReplay(false, 0)
                        ac.tryToOpenRaceMenu()
                end,
        },
}

function promptShutdownAC()
        local mouseMoved = false

        cui.modalDialog(function()
                ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
                local textBoxHeight = ui.windowHeight() / 4

                ui.setCursor(0)
                ui.dwriteTextAligned("Quit Session", textBoxHeight / 2, nil, nil, vec2(ui.windowWidth(), textBoxHeight))
                local titleTextWidth = ui.measureDWriteText(" Quit Session ", textBoxHeight / 2).x

                ui.setCursorX(0)
                ui.dwriteTextAligned(
                        "Abandon the current session and return to Content Manager?",
                        textBoxHeight / 4,
                        nil,
                        nil,
                        vec2(ui.windowWidth(), textBoxHeight)
                )

                local buttonWidth = ui.windowWidth() / 3
                ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.scaleY())
                if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
                        ui.popStyleVar(1)

                        return true
                end
                ui.sameLine()

                if not mouseMoved then
                        ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
                        mouseMoved = true
                end

                ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.scaleY())
                if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
                        ac.shutdownAssettoCorsa()
                        ui.popStyleVar(1)

                        return true
                end

                ui.popStyleVar(1)
        end)
end

local border = 15

function page.update() end

local function spectate()
        cui.pushWindow(
                "spectate_bar",
                0,
                ui.windowHeight() - 240 * cui.scaleY(),
                ui.windowWidth() * 0.35,
                240 * cui.scaleY(),
                false
        )
        ui.drawRectFilled(
                vec2(border, border),
                vec2(ui.windowWidth() - border * 0.5, ui.windowHeight() - border),
                settings.Appearance.uiColor1
        )

        local spectatedCar = ac.getCar(sim.focusedCar)

        local skin = string.format(
                "%s\\%s\\skins\\%s\\livery.png",
                ac.getFolder(ac.FolderID.ContentCars),
                ac.getCarID(spectatedCar.index),
                ac.getCarSkinID(spectatedCar.index)
        )
        local skinImageSize = vec2(100, 100) * cui.scaleY()

        cui.pushWindow("player_card", 0, 0, ui.windowWidth() * 0.4, ui.windowHeight(), false)

        ui.setCursorX(ui.windowWidth() / 2 - (skinImageSize.x / 2))
        ui.setCursorY(ui.windowHeight() / 2 - skinImageSize.y * 0.8)

        ui.image(skin, skinImageSize)

        ui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() / 2 + skinImageSize.y * 0.5)

        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.getDriverName(spectatedCar.index),
                24 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth(), 48 * cui.scaleY())
        )

        ui.setCursorX(ui.windowWidth() * 0.05)
        ui.setCursorY(ui.windowHeight() / 2 + skinImageSize.y * 0.55)
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
        ui.setCursorY(ui.windowHeight() / 2 + skinImageSize.y * 0.55)
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

        cui.setCursorX(0)
        cui.setCursorY(60)
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

        cui.setCursorX(0)
        cui.setCursorY(25)
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

        ui.drawSimpleLine(vec2(100, barPosition), vec2(100 + ui.windowWidth(), barPosition), rgbm.colors.gray, border)
        ui.drawSimpleLine(
                vec2(100 + (ui.windowWidth() - 100) * 0.5, barPosition),
                vec2(100 + (ui.windowWidth() - 100) * 0.5 + (ui.windowWidth() - 100) * 0.5 * steer, barPosition),
                rgbm.colors.orange,
                border
        )

        barPosition = (ui.windowHeight() / 20) * 7

        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100), barPosition),
                rgbm.colors.gray,
                border
        )

        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100) * spectatedCar.gas, barPosition),
                rgbm.colors.green,
                border
        )

        barPosition = (ui.windowHeight() / 20) * 12

        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100), barPosition),
                rgbm.colors.gray,
                border
        )
        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100) * spectatedCar.brake, barPosition),
                rgbm.colors.red,
                border
        )

        barPosition = (ui.windowHeight() / 20) * 17

        ui.drawSimpleLine(vec2(100, barPosition), vec2(100 + ui.windowWidth(), barPosition), rgbm.colors.gray, border)
        ui.drawSimpleLine(
                vec2(100, barPosition),
                vec2(100 + (ui.windowWidth() - 100) * (1 - spectatedCar.clutch), barPosition),
                rgbm.colors.blue,
                border
        )

        cui.popWindow()

        cui.popWindow()
end

local function replayWidget()
        cui.pushWindow(
                "bottom_replay_bar",
                ui.windowWidth() * 0.5 - ui.windowWidth() * 0.15,
                ui.windowHeight() - 240 * cui.scaleY(),
                ui.windowWidth() * 0.3,
                240 * cui.scaleY(),
                true
        )
        ui.drawRectFilled(
                vec2(border * cui.scaleY(), border),
                vec2(ui.windowWidth() - border * 0.5, ui.windowHeight() - border),
                settings.Appearance.uiColor1
        )

        cui.setCursorX(0)

        local replayButtonSize = ui.windowWidth() / 11

        cui.setCursorY(40)
        ui.dummy(replayButtonSize)
        ui.sameLine()
        for i, button in ipairs(replayButtons) do
                local flipped = i > 1 and i < #replayButtons * 0.5
                local flags = button.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                local icon = button.label

                if button.condition then
                        if not button.condition() then flags = ui.ButtonFlags.Disabled end
                end

                if i == 5 and replay.isPlaying then icon = ui.Icons.Pause end

                if
                        cui.iconButton(
                                "##Test" .. button.label .. (flipped and "-1" or ""),
                                icon,
                                replayButtonSize,
                                replayButtonSize,
                                flags,
                                flipped,
                                button.scale
                        )
                then
                        button.func()
                end
                ui.sameLine()
        end
        ui.dummy(replayButtonSize)
        ui.sameLine()

        cui.iconButton("##Test", ui.Icons.Pause, replayButtonSize, replayButtonSize, ui.ButtonFlags.None)
        ui.sameLine()

        cui.setCursorX(0)
        cui.setCursorY(140)
        cui.snapCursor()
        ui.dwriteTextAligned(
                "LAP",
                18 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "PLAYBACK",
                18 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                "CAMERA",
                18 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )

        cui.setCursorX(0)
        cui.setCursorY(180)
        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.getCar(sim.focusedCar).lapCount + 1,
                30 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        cui.snapCursor()
        ui.dwriteTextAligned(
                sim.isReplayActive and string.format("%.1fx", replay.rate * replay.direction) or "Live",
                30 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        local cameraMode = sim.cameraMode
        local cameraModeString = ""

        if cameraMode == ac.CameraMode.Cockpit then
                cameraModeString = "Cockpit"
        elseif cameraMode == ac.CameraMode.Drivable then
                for k, v in pairs(ac.DrivableCamera) do
                        if v == sim.driveableCameraMode then cameraModeString = cameraModeString .. k end
                end
        elseif cameraMode == ac.CameraMode.Car then
                cameraModeString = "Car " .. sim.carCameraIndex
        elseif cameraMode == ac.CameraMode.Track then
                cameraModeString = "Track " .. sim.trackCamerasSet
        elseif cameraMode == ac.CameraMode.Free then
                cameraModeString = "Free"
        elseif cameraMode == ac.CameraMode.Helicopter then
                cameraModeString = "Heli"
        elseif cameraMode == ac.CameraMode.OnBoardFree then
                cameraModeString = "Orbit"
        end

        cui.snapCursor()
        ui.dwriteTextAligned(
                cameraModeString,
                30 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        cui.popWindow()
end

local function chat()
        cui.pushWindow(
                "bottom_chat_bar",
                ui.windowWidth() * 0.5 + ui.windowWidth() * 0.15,
                ui.windowHeight() - 240 * cui.scaleY(),
                ui.windowWidth() * 0.35,
                240 * cui.scaleY(),
                true
        )
        ui.drawRectFilled(
                vec2(border * 0.5, border),
                vec2(ui.windowWidth() - border * 0.5, ui.windowHeight() - border),
                settings.Appearance.uiColor1
        )

        cui.setCursorX(border * 0.5)
        ui.setCursorY(ui.windowHeight() - 65 * cui.scaleY())
        cui.inputText(
                "##SetupName",
                "Chat:",
                " Hello there",
                ui.InputTextFlags.None,
                vec2(ui.windowWidth() - border, 50 * cui.scaleY())
        )

        cui.popWindow()
end

function page.draw()
        border = 15 * cui.scaleY()

        cui.pushWindowFitted("main_menu_page_window")

        topBar()

        cui.pushWindow(
                "home_leaderboard_window",
                0,
                216 * cui.scaleY(),
                ui.windowWidth() * 0.5,
                ui.windowHeight() - 500 * cui.scaleY(),
                true
        )

        local height = 50 * cui.scaleY()
        playerListBanner(0, 0, ui.windowWidth(), height)

        cui.pushWindow("home_leaderboard_entrant_window", 0, height, ui.windowWidth(), ui.windowHeight() - height, true)
        for i, car in ac.iterateCars.leaderboard() do
                playerListButton(car, 0, (i - 1) * height, ui.windowWidth(), height)
        end
        cui.popWindow(true)
        cui.popWindow()

        cui.pushWindow(
                "home_bottom_bar",
                0,
                ui.windowHeight() - 240 * cui.scaleY(),
                ui.windowWidth(),
                240 * cui.scaleY(),
                true
        )
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0.1, 0.1, 0.1, 0.95))

        spectate()
        replayWidget()
        chat()

        cui.popWindow()
        cui.popWindow()

        return ""
end

return page
