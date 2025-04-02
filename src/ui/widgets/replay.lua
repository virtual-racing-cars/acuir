local cui = require("ui.cui")
local replay = require("replay")
local settings = require("settings")
local sim = ac.getSim()

local replayWidget = {}

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
                        ac.tryToToggleReplay(true, 5)
                        replay:jumpToStart()
                end,
        },

        {
                label = ui.Icons.Next,
                enabled = true,
                scale = 0.75,
                condition = function() end,
                func = function() ac.tryToToggleReplay(true, 5) end,
        },
        {
                label = ui.Icons.FastForward,
                enabled = true,
                scale = 1,
                condition = function() return replay.rate * replay.direction > -5 and replay.rewindAvailable end,
                func = function()
                        if not sim.isReplayActive then replay.frame = sim.replayCurrentFrame end

                        replay:setPlayback(-1, replay.rate + 0.5)
                        ac.tryToToggleReplay(true, 5)
                end,
        },
        {
                label = ui.Icons.Play,
                enabled = true,
                scale = 1,
                condition = function() return replay.forwardAvailable end,
                func = function()
                        if not sim.isReplayActive then replay.frame = sim.replayCurrentFrame end

                        replay:setPause(replay.rate > 0)

                        ac.tryToToggleReplay(true, 5)
                end,
        },
        {
                label = ui.Icons.FastForward,
                enabled = true,
                scale = 1,
                condition = function() return replay.rate * replay.direction < 5 and replay.forwardAvailable end,
                func = function()
                        if not sim.isReplayActive then replay.frame = sim.replayCurrentFrame end

                        replay:setPlayback(1, replay.rate + 0.5)

                        ac.tryToToggleReplay(true, 5)
                end,
        },
        {
                label = ui.Icons.Next,
                enabled = true,
                scale = 0.75,
                func = function() ac.tryToToggleReplay(true, 5) end,
        },
        {
                label = ui.Icons.Finish,
                enabled = true,
                scale = 0.75,
                func = function()
                        ac.tryToToggleReplay(true, 5)
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

function replayWidget:draw(xPos, yPos, width, height)
        cui.pushWindow("replay_widget_window", xPos, yPos, width, height, false)
        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColor1)

        cui.setCursorX(0)

        local replayButtonSize = ui.windowWidth() / 11

        cui.setCursorY(25)
        ui.dummy(replayButtonSize)
        ui.sameLine()
        for i, button in ipairs(replayButtons) do
                local flipped = i > 1 and i < #replayButtons * 0.5
                local flags = button.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                local icon = button.label

                if button.condition then
                        if not button.condition() then flags = ui.ButtonFlags.Disabled end
                end

                if i == 5 and replay.rate > 0 then icon = ui.Icons.Pause end

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
        cui.setCursorY(115)
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
        cui.setCursorY(155)
        cui.snapCursor()
        ui.dwriteTextAligned(
                ac.getCar(sim.focusedCar).lapCount + 1,
                30 * cui.scaleY(),
                ui.Alignment.Center,
                ui.Alignment.Center,
                vec2(ui.windowWidth() / 3, 36)
        )
        ui.sameLine()

        local playbackRate = replay.rate == 0 and "Paused" or string.format("%.1fx", replay.rate * replay.direction)
        local playback = sim.isReplayActive and playbackRate or "Live"

        cui.snapCursor()
        ui.dwriteTextAligned(
                playback,
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
        elseif cameraMode == ac.CameraMode.Start then
                cameraModeString = "Orbit Start"
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

return replayWidget
