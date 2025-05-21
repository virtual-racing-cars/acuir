local app = require("app")
local callback = require("callback")
local cardWidget = require("ui.widgets.card")
local chatWidget = require("ui.widgets.chat")
local csp = require("csp")
local cui = require("ui.cui")
local pages = require("ui.pages")
local replayWidget = require("ui.widgets.replay")
local settings = require("settings")
local simutils = require("simutils")
local style = require("style")
local sim = ac.getSim()

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo) * cui.uiScale()

local topBarHeight = 200 * cui.uiScale()

local menuButtonSize = 56
local versionString = string.format("%s: %s, CSP: %s (%s)", app.name, app.version, csp.version, csp.versionCode)

function bottomBar(buttons)
        ui.drawRectFilled(
                vec2(0, ui.windowHeight() - 56 * cui.uiScale()),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiThemeColor1 / 3
        )

        if settings.General.showVersions then
                ui.setCursorX(0)
                ui.setCursorY(10)
                ui.dwriteTextAligned(
                        versionString,
                        26 * cui.uiScale(),
                        ui.Alignment.Center,
                        ui.Alignment.End,
                        ui.availableSpace() - vec2(40, 10) * cui.uiScale(),
                        false,
                        rgbm(0.8, 0.8, 0.8, 0.2)
                )
        end

        ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.transparent)
        ui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() - 56 * cui.uiScale())
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

local weatherTypeString = {
        [0] = "Light Thunderstorm",
        "Thunderstorm",
        "Heavy Thunderstorm",
        "Light Drizzle",
        "Drizzle",
        "Heavy Drizzle",
        "LightRain",
        "Rain",
        "Heavy Rain",
        "LightSnow",
        "Snow",
        "Heavy Snow",
        "Light Sleet",
        "Sleet",
        "Heavy Sleet",
        "Clear",
        "Few Clouds",
        "Scattered Clouds",
        "Broken Clouds",
        "Overcast Clouds",
        "Fog",
        "Mist",
        "Smoke",
        "Haze",
        "Sand",
        "Dust",
        "Squalls",
        "Tornado",
        "Hurricane",
        "Cold",
        "Hot",
        "Windy",
        "Hail",
}

local sessionInfoTable = {

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
        {
                label = function() return "Weather" end,
                row1 = function() return string.format("%s", weatherTypeString[sim.weatherType]) end,
                row2 = function() return string.format("%s", "") end,
        },
}

local function sessionInfo()
        local startX = (ui.windowWidth() / 5) * 4 + 15 * cui.uiScale()
        local startY = 12 * cui.uiScale()
        local sizeX = 160 * cui.uiScale()
        local sizeY = 28 * cui.uiScale()

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

                ui.offsetCursorX(-50 * cui.uiScale())

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
        ui.setCursorY(topBarHeight / 2 - (100 * cui.uiScale()) / 2)

        -- ui.dwriteTextAligned(
        --         path,
        --         50 * cui.uiScale(),
        --         ui.Alignment.Start,
        --         ui.Alignment.Center,
        --         vec2(600 * cui.uiScale(), 100 * cui.uiScale()),
        --         false,
        --         rgbm(1, 1, 1, 1)
        -- )
end

function topBar(path)
        local driveButtonWidth = 500 * cui.uiScale()
        local driveButtonHeight = 70 * cui.uiScale()

        -- ui.drawSimpleLine(
        --         vec2(ui.windowWidth() * 0.5, 0),
        --         vec2(ui.windowWidth() * 0.5, ui.windowHeight()),
        --         rgbm.colors.aqua
        -- )

        ui.drawRectFilled(0, vec2(ui.windowWidth(), topBarHeight), rgbm(0.1, 0.1, 0.1, 0.95))

        cui.contentWindow(
                "top_bar_banner",
                vec2(0, topBarHeight),
                vec2(ui.windowWidth(), 50 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.drawRectFilled(
                                vec2(0, 0),
                                vec2(ui.windowWidth(), ui.windowHeight()),
                                rgbm(0.1, 0.1, 0.1, 0.75)
                        )

                        ui.setCursorX(ui.windowWidth() * 0.5 - 320 * cui.uiScale())
                        ui.setCursorY(0)
                        cui.snapCursor()

                        ui.dwriteTextAligned(
                                simutils.raceSessionTypeString .. " " .. simutils.sessionTotalTimeString,
                                28 * cui.uiScale(),
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                vec2(300 * cui.uiScale(), ui.windowHeight())
                        )
                        ui.sameLine()
                        ui.setCursorX(ui.windowWidth() * 0.5 + 20 * cui.uiScale())
                        cui.snapCursor()

                        ui.dwriteTextAligned(
                                simutils.sessionTimeLeftString,
                                28 * cui.uiScale(),
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(600 * cui.uiScale(), ui.windowHeight())
                        )

                        if callback.info then callback.info() end
                        if callback.vote then callback.vote() end
                end
        )

        topSubBar(path)

        ui.setCursorY(topBarHeight / 2 - driveButtonHeight / 2)
        ui.setCursorX(ui.windowWidth() / 2 - driveButtonWidth / 2)
        ui.offsetCursorX(-driveButtonHeight * 7)
        ui.offsetCursorY(-driveButtonHeight * 0.2)
        if
                cui.iconButton(
                        "Session",
                        ui.Icons.Info,
                        driveButtonHeight,
                        driveButtonHeight,
                        ui.ButtonFlags.None,
                        false,
                        nil,
                        pages.manager.currentPageName == "SessionPage"
                )
        then
                if pages.manager.currentPageName == "SessionPage" then
                        pages:goToMainMenu()
                else
                        pages:goToSession()
                end
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
                if pages.manager.currentPageName == "SetupPage" then
                        pages:goToMainMenu()
                else
                        pages:goToSetup()
                end
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if
                cui.iconButton(
                        "Laps",
                        ui.Icons.List,
                        driveButtonHeight,
                        driveButtonHeight,
                        ui.ButtonFlags.Disabled,
                        false,
                        nil,
                        pages.manager.currentPageName == "LapTimesPage"
                )
        then
                if pages.manager.currentPageName == "LapTimesPage" then
                        pages:goToMainMenu()
                else
                        pages:goToLapTimes()
                end
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if cui.iconButton("Settings", ui.Icons.Settings, driveButtonHeight, driveButtonHeight, ui.ButtonFlags.None) then
                pages:goToSettings()
        end

        ui.offsetCursorX(driveButtonHeight * 0.75)
        ui.offsetCursorY(driveButtonHeight * 0.2)

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
        ui.offsetCursorY(-driveButtonHeight * 0.2)

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
                        simutils.sessionSkippable and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
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

function bottomWidgetBar()
        cui.pushWindow(
                "bottom_widget_bar_window",
                0,
                ui.windowHeight() - 240 * cui.uiScale(),
                ui.windowWidth(),
                240 * cui.uiScale(),
                true
        )
        ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0.1, 0.1, 0.1, 0.95))

        local border = 15 * cui.uiScale()

        local widgetYPos = ui.windowHeight() - 240 * cui.uiScale() + border
        local widgetWidth = ui.windowWidth() / 3 - border
        local widgetHeight = 240 * cui.uiScale() - border * 2

        cardWidget:draw(border, widgetYPos, widgetWidth, widgetHeight)
        replayWidget:draw(ui.windowWidth() * 0.5 - widgetWidth * 0.5, widgetYPos, widgetWidth, widgetHeight)
        chatWidget:draw(
                ui.windowWidth() * 0.5 + widgetWidth * 0.5 + border * 0.5,
                widgetYPos,
                widgetWidth,
                widgetHeight
        )

        cui.popWindow()
end

function settingsMenuCommon(path, bottomBarButtons)
        topSubBar("/Settings" .. path)
        bottomBar(bottomBarButtons)
end

function updateCommon()
        acLogoSize = ui.imageSize(acLogo) * 0.85 * cui.uiScale()
        topBarHeight = 130 * cui.uiScale()
end
