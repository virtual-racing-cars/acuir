local page = {}

local callback = require("callback")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")
local simutils = require("simutils")
local style = require("ui.style")
local sim = ac.getSim()
local car = ac.getCar(0)

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
                func = function() ac.tryToToggleReplay(true) end,
        },

        {
                label = "Settings",
                enabled = true,
                condition = function() end,
                func = function() pages:goToSettings() end,
        },

        {
                label = "Go To Garage",
                enabled = true,
                condition = function() end,
                func = function()
                        ac.tryToPause(false)

                        if not car.isInPit then ac.tryToTeleportToPits() end
                        callback.sim = function()
                                pages:goToSetup()
                                ac.tryToOpenRaceMenu(nil)
                                ac.tryToOpenRaceMenu("setup")

                                if sim.isInMainMenu then return true end
                        end
                end,
        },
        {
                label = "Back To Pitlane",
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
                func = function() cui:promptShutdownACDialog() end,
        },
}

function page.draw(dt)
        local childWindowWith = (500 * cui.scale())
        local childWindowHeight = (750 * cui.scale())
        local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse

        if callback.dialog then
                mainWindowFlags = mainWindowFlags
                        + ui.WindowFlags.NoInputs
                        + ui.WindowFlags.NoMouseInputs
                        + ui.WindowFlags.NoFocusOnAppearing
        end

        cui.contentWindow(
                "pause_window",
                vec2((ui.windowWidth() - childWindowWith) / 2, (ui.windowHeight() - childWindowHeight) / 2),
                vec2(childWindowWith, childWindowHeight),
                mainWindowFlags,
                function()
                        ui.setCursor(0)
                        cui.offsetCursorY(30)

                        ui.drawRectFilled(
                                vec2(0, 0),
                                ui.windowSize(),
                                settings.Appearance.uiColorPrimary / 1.5,
                                12 * cui.scale()
                        )

                        acLogoSize = vec2(ui.windowHeight() * 0.2, ui.windowHeight() * 0.2)
                        ui.setCursorX(ui.windowWidth() / 2 - acLogoSize.x / 2)
                        ui.image(acLogo, acLogoSize)
                        cui.offsetCursorY(30)

                        local menuButtonSize = vec2(ui.availableSpaceX() - 40 * cui.scale(), 60 * cui.scale())

                        ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColorPrimary)
                        for i in ipairs(pauseButtons) do
                                cui.setCursorX(20)
                                local menuButton = pauseButtons[i]
                                local enabled = menuButton.enabled
                                local hidden = false

                                if menuButton.condition() then hidden = true end

                                if
                                        not hidden
                                        and cui.menuButton(
                                                menuButton.label,
                                                menuButtonSize,
                                                ui.Alignment.Center,
                                                ui.Alignment.Center,
                                                enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                                        )
                                then
                                        menuButton.func()
                                end
                                cui.offsetCursorY(10)
                        end

                        ui.popStyleColor(1)
                end
        )

        return "finalize"
end

return page
