local app = require("app")
local callback = require("callback")
local cardWidget = require("ui.widgets.card")
local chatWidget = require("ui.widgets.chat")
local csp = require("csp")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local pedalsWidget = require("ui.widgets.pedals")
local replayWidget = require("ui.widgets.replay")
local settings = require("settings")
local simutils = require("simutils")
local style = require("style")
local tracesWidget = require("ui.widgets.traces")
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

function topSubBar(path)
        ui.setCursorX(ui.windowWidth() / 65)
        ui.setCursorY(topBarHeight / 2 - acLogoSize.y / 2)
        ui.image(acLogo, acLogoSize)

        cui.setCursorX(180)
        ui.setCursorY(topBarHeight / 2 - (100 * cui.uiScale()) / 2)

        if not path then return end
        local pathString = path == "" and "" or " / " .. path
        ui.dwriteTextAligned(
                " / Settings" .. pathString,
                50 * cui.uiScale(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(600 * cui.uiScale(), 100 * cui.uiScale()),
                false
        )
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
        cui.setCursorX(210)
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
                        "Laps",
                        ui.Icons.List,
                        driveButtonHeight,
                        driveButtonHeight,
                        ui.ButtonFlags.None,
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

        if
                cui.iconButton(
                        "Telemetry",
                        ui.Icons.Barcode,
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

        ui.setCursorX(ui.windowWidth() / 2 - driveButtonWidth / 2)
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

        ui.setCursorX(ui.windowWidth() - (ui.windowWidth() / 65) - driveButtonHeight * 4.75)
        ui.offsetCursorY(-driveButtonHeight * 0.2)

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

        if cui.iconButton("Settings", ui.Icons.Settings, driveButtonHeight, driveButtonHeight, ui.ButtonFlags.None) then
                pages:goToSettings()
        end
        ui.offsetCursorX(driveButtonHeight * 0.75)

        if cui.iconButton("Quit", ui.Icons.Leave, driveButtonHeight, driveButtonHeight, ui.ButtonFlags.None) then
                cui:promptShutdownAC()
        end
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

        cardWidget:draw(border, widgetYPos, widgetWidth * 0.5 - border * 0.25, widgetHeight)
        pedalsWidget:draw(
                border + widgetWidth * 0.5 + border * 0.25,
                widgetYPos,
                widgetWidth * 0.5 - border * 0.25,
                widgetHeight
        )
        tracesWidget:draw(ui.windowWidth() * 0.5 - widgetWidth * 0.5, widgetYPos, widgetWidth, widgetHeight)
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
