local page = {}

local cui = require("ui.cui")
local pages = require("ui.pages")
local replay = require("replay")
local settings = require("settings")
local simutils = require("simutils")
local sim = ac.getSim()

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo)

local pauseButtons = {
        {
                label = "Resume",
                enabled = true,
                condition = function() end,
                func = function() ac.tryToPause(false) end,
        },
        {
                label = "Replay",
                enabled = true,
                condition = function() end,
                func = function()
                        replay.speed = -1
                        ac.tryToToggleReplay(true)
                end,
        },

        {
                label = "Settings",
                enabled = true,
                condition = function() end,
                func = function() pages:goToSettings() end,
        },
        {
                label = "View Settings",
                enabled = false,
                condition = function() end,
                func = function() end,
        },
        {
                label = "Go To Vehicle Setup",
                enabled = true,
                condition = function() end,
                func = function()
                        ac.tryToPause(false)
                        ac.tryToTeleportToPits()
                        teleportPitsCallback = function()
                                pages:goToSetup()
                                ac.tryToOpenRaceMenu()
                                ac.tryToOpenRaceMenu("setup")

                                if sim.isInMainMenu then return true end
                        end
                end,
        },
        {
                label = "Go To Pitlane",
                enabled = true,
                condition = function() end,
                func = function()
                        ac.tryToPause(false)
                        ac.tryToTeleportToPits()
                end,
        },
        {
                label = "Restart Session",
                enabled = true,
                condition = function() return not simutils.sessionRestartable end,
                func = function()
                        ac.tryToPause(false)
                        ac.tryToRestartSession()
                end,
        },
        {
                label = "Quit",
                enabled = true,
                condition = function() end,
                func = function() promptShutdownAC() end,
        },
}

function page.draw(dt)
        local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse

        if cui.modalDialogCallback then
                mainWindowFlags = mainWindowFlags
                        + ui.WindowFlags.NoInputs
                        + ui.WindowFlags.NoMouseInputs
                        + ui.WindowFlags.NoFocusOnAppearing
        end

        cui.contentWindow("results_home_window", vec2(0, 0), ui.windowSize(), mainWindowFlags, function()
                ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColor1 / 4)

                acLogoSize = ui.imageSize(acLogo) * 2 * cui.scaleY()
                ui.setCursorX(ui.windowWidth() / 2 - acLogoSize.x / 2)
                ui.image(acLogo, acLogoSize)
                ui.newLine()

                ui.setCursorX(ui.windowWidth() / 20)

                cui.snapCursor()
                ui.dwriteTextAligned(
                        "Results",
                        70 * cui.scaleY(),
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(300, 160),
                        false,
                        rgbm.colors.white
                )

                cui.pushWindow(
                        "home_leaderboard_window",
                        ui.windowWidth() / 20,
                        500 * cui.scaleY(),
                        1000 * cui.scaleX(),
                        ui.windowHeight() - 459 * cui.scaleY(),
                        true
                )
                local height = 50 * cui.scaleY()
                playerListBanner(0, 0, ui.windowWidth(), height * 0.9)

                cui.pushWindow(
                        "home_leaderboard_entrant_window",
                        0,
                        height,
                        ui.windowWidth(),
                        ui.windowHeight() - height,
                        true
                )
                for i, car in ac.iterateCars.leaderboard() do
                        playerListButton(car, 0, (i - 1) * height, ui.windowWidth(), height)
                end
                cui.popWindow(true)
                cui.popWindow()

                ui.setCursorX(ui.windowWidth() / 2)
                cui.setCursorY(1300)
                local driveButtonHeight = 70 * cui.scaleY()

                if
                        cui.iconButton(
                                "Restart",
                                ui.Icons.Reset,
                                driveButtonHeight,
                                driveButtonHeight,
                                simutils.sessionRestartable and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                        )
                then
                        ac.tryToRestartSession()
                end
                ui.offsetCursorX(driveButtonHeight * 0.75)

                if
                        cui.iconButton(
                                "Replay",
                                ui.Icons.Film,
                                driveButtonHeight,
                                driveButtonHeight,
                                ui.ButtonFlags.None
                        )
                then
                        ac.tryToToggleReplay(true, 30)
                end
                ui.offsetCursorX(driveButtonHeight * 0.75)

                if
                        cui.iconButton(
                                "Quit",
                                ui.Icons.Leave,
                                driveButtonHeight,
                                driveButtonHeight,
                                ui.ButtonFlags.None
                        )
                then
                        promptShutdownAC()
                end
        end)

        return ""
end

return page
