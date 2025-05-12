local app = require("app")
local callback = require("callback")
local csp = require("csp")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")
local simutils = require("simutils")
local style = require("style")
local sim = ac.getSim()

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo) * cui.scaleY()

local topBarHeight = 200 * cui.scaleY()

local menuButtonSize = 56
local versionString = string.format("%s: %s, CSP: %s (%s)", app.name, app.version, csp.version, csp.versionCode)

function bottomBar(buttons)
        ui.drawRectFilled(
                vec2(0, ui.windowHeight() - 56 * cui.scaleY()),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiColor1 / 3
        )

        if settings.General.showVersions then
                ui.setCursorX(0)
                ui.setCursorY(10)
                ui.dwriteTextAligned(
                        versionString,
                        26 * cui.scaleY(),
                        ui.Alignment.Center,
                        ui.Alignment.End,
                        ui.availableSpace() - vec2(40, 10) * cui.scaleY(),
                        false,
                        rgbm(0.8, 0.8, 0.8, 0.2)
                )
        end

        ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.transparent)
        ui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() - 56 * cui.scaleY())
        for i in ipairs(buttons) do
                local menuButton = buttons[i]

                if
                        cui.menuButton(
                                menuButton.label,
                                menuButtonSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                menuButton.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                        )
                then
                        menuButton.func()
                end

                ui.sameLine()
                ui.offsetCursor(-1)
        end

        ui.popStyleColor(1)
end

local sessionInfoTable = {
        {
                label = function() return "Sim Time" end,
                row1 = function() return simutils.simDateString end,
                row2 = function() return simutils.simTimeString end,
        },
        {
                label = function() return "Track" end,
                row1 = function() return string.format("%.1f° C", sim.roadTemperature) end,
                row2 = function() return string.format("%s - %.1f %%", simutils.trackGripString, sim.roadGrip * 100) end,
        },
        {
                label = function() return "Air" end,
                row1 = function() return string.format("%.1f° C", sim.ambientTemperature) end,
                row2 = function() return string.format("Humidity - %.0f %%", ac.getAirHumidity(vec3(0, 0, 0)) * 100) end,
        },
        {
                label = function() return "Wind" end,
                row1 = function() return string.format("%.1f kmh", sim.windSpeedKmh) end,
                row2 = function()
                        return string.format("%s - %.1f°", simutils.windDirectionString, sim.windDirectionDeg + 180)
                end,
        },
}

local function sessionInfo()
        local startX = (ui.windowWidth() / 4) * 3 + 120 * cui.scaleY()
        local startY = 12 * cui.scaleY()
        local sizeX = 170 * cui.scaleX()
        local sizeY = 28 * cui.scaleY()

        local fontSize = math.floor(sizeY * 0.7)
        fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

        ui.setCursor(vec2(startX, startY))
        for i in ipairs(sessionInfoTable) do
                ui.beginGroup()

                style:pushFontBold()
                cui.snapCursor()
                ui.dwriteTextAligned(
                        string.upper(sessionInfoTable[i].label()) .. ":",
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(sizeX, sizeY)
                )
                ui.popDWriteFont()
                ui.sameLine()

                ui.offsetCursorX(-50 * cui.scaleY())

                cui.snapCursor()
                ui.dwriteTextAligned(
                        sessionInfoTable[i].row1(),
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(sizeX, sizeY)
                )
                ui.sameLine()

                cui.snapCursor()
                ui.dwriteTextAligned(
                        sessionInfoTable[i].row2(),
                        fontSize,
                        ui.Alignment.Start,
                        ui.Alignment.Center,
                        vec2(sizeX, sizeY)
                )

                ui.endGroup()
                ui.setCursorX(startX)
        end
end

function topSubBar(path)
        ui.setCursorX(ui.windowWidth() / 65)
        ui.setCursorY(topBarHeight / 2 - acLogoSize.y / 2)
        ui.image(acLogo, acLogoSize)

        cui.setCursorX(180)
        ui.setCursorY(topBarHeight / 2 - (100 * cui.scaleY()) / 2)

        -- ui.dwriteTextAligned(
        --         path,
        --         50 * cui.scaleY(),
        --         ui.Alignment.Start,
        --         ui.Alignment.Center,
        --         vec2(600 * cui.scaleX(), 100 * cui.scaleY()),
        --         false,
        --         rgbm(1, 1, 1, 1)
        -- )
end

function topBar(path)
        local driveButtonWidth = 500 * cui.scaleY()
        local driveButtonHeight = 70 * cui.scaleY()

        -- ui.drawSimpleLine(
        --         vec2(ui.windowWidth() * 0.5, 0),
        --         vec2(ui.windowWidth() * 0.5, ui.windowHeight()),
        --         rgbm.colors.aqua
        -- )

        ui.drawRectFilled(0, vec2(ui.windowWidth(), topBarHeight), rgbm(0.1, 0.1, 0.1, 0.95))

        cui.contentWindow(
                "top_bar_banner",
                vec2(0, topBarHeight),
                vec2(ui.windowWidth(), 50 * cui.scaleY()),
                ui.WindowFlags.None,
                function()
                        ui.drawRectFilledMultiColor(
                                vec2(0, 0),
                                vec2(ui.windowWidth() * 0.5, ui.windowHeight()),
                                rgbm(0.1, 0.1, 0.1, 0),
                                rgbm(0.1, 0.1, 0.1, 0.95),
                                rgbm(0.1, 0.1, 0.1, 0.95),
                                rgbm(0.1, 0.1, 0.1, 0)
                        )

                        ui.drawRectFilledMultiColor(
                                vec2(ui.windowWidth() * 0.5, 0),
                                vec2(ui.windowWidth(), ui.windowHeight()),
                                rgbm(0.1, 0.1, 0.1, 0.95),
                                rgbm(0.1, 0.1, 0.1, 0),
                                rgbm(0.1, 0.1, 0.1, 0),
                                rgbm(0.1, 0.1, 0.1, 0.95)
                        )

                        ui.setCursorX(ui.windowWidth() * 0.5 - 320)
                        ui.setCursorY(0)
                        cui.snapCursor()

                        ui.dwriteTextAligned(
                                simutils.raceSessionTypeString .. " " .. simutils.sessionTotalTimeString,
                                28,
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                vec2(300 * cui.scaleY(), ui.windowHeight())
                        )
                        ui.sameLine()
                        ui.setCursorX(ui.windowWidth() * 0.5 + 20)
                        cui.snapCursor()

                        ui.dwriteTextAligned(
                                simutils.sessionTimeLeftString,
                                28,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(300 * cui.scaleY(), ui.windowHeight())
                        )

                        if callback.info then callback.info() end
                        if callback.vote then callback.vote() end
                end
        )

        topSubBar(path)

        ui.setCursorY(topBarHeight / 2 - driveButtonHeight / 2)
        ui.setCursorX(ui.windowWidth() / 2 - driveButtonWidth / 2)
        ui.offsetCursorX(-driveButtonHeight * 8.75)
        if
                cui.iconButton(
                        "Session",
                        ui.Icons.Info,
                        driveButtonHeight,
                        driveButtonHeight,
                        ui.ButtonFlags.Disabled,
                        false,
                        nil,
                        pages.manager.currentPageName == "MainMenu"
                )
        then
                pages:goToMainMenu()
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if
                cui.iconButton(
                        "Leaderboard",
                        ui.Icons.Leaderboard,
                        driveButtonHeight,
                        driveButtonHeight,
                        ui.ButtonFlags.None,
                        false,
                        nil,
                        pages.manager.currentPageName == "MainMenu"
                )
        then
                pages:goToMainMenu()
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if
                cui.iconButton(
                        "Garage",
                        ui.Icons.Wrench,
                        driveButtonHeight,
                        driveButtonHeight,
                        ui.ButtonFlags.None,
                        false,
                        nil,
                        pages.manager.currentPageName == "SetupPage"
                )
        then
                pages:goToSetup()
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if cui.iconButton("Laps", ui.Icons.List, driveButtonHeight, driveButtonHeight, ui.ButtonFlags.Disabled) then
                ac.tryToRestartSession()
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if cui.iconButton("Settings", ui.Icons.Settings, driveButtonHeight, driveButtonHeight, ui.ButtonFlags.None) then
                pages:goToSettings()
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        local readyToDriveState = simutils.readyToDriveState
        local readyToDrive, driveButtonText, reason, driveButtonColor =
                readyToDriveState[1], readyToDriveState[2], readyToDriveState[3], readyToDriveState[4]

        if
                cui.specialButton(
                        string.upper(driveButtonText),
                        vec2(driveButtonWidth, driveButtonHeight),
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        driveButtonColor,
                        not readyToDrive,
                        reason
                )
        then
                ac.tryToStart()
        end
        ui.sameLine()
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if
                cui.iconButton(
                        sim.isOnlineRace and "Vote Restart" or "Restart",
                        ui.Icons.Reset,
                        driveButtonHeight,
                        driveButtonHeight,
                        ui.ButtonFlags.None
                )
        then
                if sim.isOnlineRace then
                        ac.castVote("restart", true)
                else
                        ac.tryToRestartSession()
                end
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if
                cui.iconButton(
                        sim.isOnlineRace and "Vote Skip" or "Skip",
                        ui.Icons.Skip,
                        driveButtonHeight,
                        driveButtonHeight,
                        ui.ButtonFlags.None
                )
        then
                if sim.isOnlineRace then
                        ac.castVote("skip", true)
                else
                        ac.tryToSkipSession()
                end
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if cui.iconButton("Quit", ui.Icons.Leave, driveButtonHeight, driveButtonHeight, ui.ButtonFlags.None) then
                cui:promptShutdownAC()
        end

        sessionInfo()
end

function settingsMenuCommon(path, bottomBarButtons)
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiColor1 / 1.1)

        topSubBar("/Settings" .. path)
        bottomBar(bottomBarButtons)
end

function updateCommon()
        acLogoSize = ui.imageSize(acLogo) * 0.85 * cui.scaleY()
        topBarHeight = 130 * cui.scaleY()
end
