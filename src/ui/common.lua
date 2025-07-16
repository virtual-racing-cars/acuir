local app = require("app")
local callback = require("callback")
local cardWidget = require("ui.widgets.card")
local chatWidget = require("ui.widgets.chat")
local csp = require("csp")
local cui = require("ui.cui")
local pages = require("ui.pages")
local pedalsWidget = require("ui.widgets.pedals")
local replayWidget = require("ui.widgets.replay")
local settings = require("settings")
local simutils = require("simutils")
local style = require("ui.cui.style")
local tracesWidget = require("ui.widgets.traces")

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
-- local acLogo = ac.getFolder(ac.FolderID.ScriptOrigin) .. "\\assets\\img\\vrc_logo.png"
local acLogoSize = ui.imageSize(acLogo) * cui.scale()

local topBarHeight = 200 * cui.scale()

local menuButtonSize = 56
local versionString = string.format("%s: %s, CSP: %s (%s)", app.name, app.version, csp.version, csp.versionCode)

function bottomBar(buttons)
        ui.drawRectFilled(
                vec2(0, ui.windowHeight() - 56 * cui.scale()),
                ui.windowSize(),
                settings.Appearance.uiColorPrimary / 3,
                6 * cui.scale()
        )

        if settings.UI.showVersions then
                ui.setCursorX(0)
                ui.setCursorY(10)
                ui.dwriteTextAligned(
                        versionString,
                        26 * cui.scale(),
                        ui.Alignment.Center,
                        ui.Alignment.End,
                        ui.availableSpace() - vec2(40, 10) * cui.scale(),
                        false,
                        rgbm(0.8, 0.8, 0.8, 0.2)
                )
        end

        ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.transparent)
        ui.setCursorX(0)
        ui.setCursorY(ui.windowHeight() - 56 * cui.scale())
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
        ui.setCursorX(topBarHeight * 0.75 - acLogoSize.x * 0.5)
        ui.setCursorY(topBarHeight * 0.5 - acLogoSize.y * 0.5)
        ui.image(acLogo, acLogoSize)

        cui.setCursorX(180)
        ui.setCursorY(topBarHeight * 0.5 - (100 * cui.scale()) * 0.5)

        if not path then return end
        local pathString = path == "" and "" or " / " .. path
        ui.dwriteTextAligned(
                " / Settings" .. pathString,
                50 * cui.scale(),
                ui.Alignment.Start,
                ui.Alignment.Center,
                vec2(600 * cui.scale(), 100 * cui.scale()),
                false
        )
end

function topBar(path)
        local driveButtonWidth = 550 * cui.scale()
        local driveButtonHeight = 70 * cui.scale()
        local buttonWidth = 120 * cui.scale()

        -- ui.drawSimpleLine(
        --         vec2(ui.windowWidth() * 0.5, 0),
        --         vec2(ui.windowWidth() * 0.5, ui.windowHeight()),
        --         rgbm.colors.aqua
        -- )

        ui.drawRectFilled(
                0,
                vec2(ui.windowWidth(), topBarHeight),
                settings.Appearance.uiColorBackground,
                12 * cui.scale()
        )

        cui.contentWindow(
                "top_bar_banner",
                vec2(0, topBarHeight),
                vec2(ui.windowWidth(), 50 * cui.scale()),
                ui.WindowFlags.None,
                function()
                        local width1 = 200 * cui.scale()
                        local width2 = 270 * cui.scale()
                        local height = 80 * cui.scale()
                        local center = ui.windowWidth() * 0.5

                        ui.drawQuadFilled(
                                vec2(center - width2, 0),
                                vec2(center - width1, height),
                                vec2(center + width1, height),
                                vec2(center + width2, 0),
                                settings.Appearance.uiColorBackgroundShade
                        )

                        -- ui.drawRectFilled(
                        --         vec2(0, 0),
                        --         ui.windowSize(),
                        --         settings.Appearance.uiColorBackground * 0.5,
                        --         12,
                        --         ui.CornerFlags.Bottom
                        -- )

                        ui.setCursorX(ui.windowWidth() * 0.5 - 320 * cui.scale())
                        ui.setCursorY(0)
                        cui.snapCursor()

                        ui.dwriteTextAligned(
                                simutils.raceSessionTypeString .. " " .. simutils.sessionTotalTimeString,
                                style.main.font.header.size,
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                vec2(300 * cui.scale(), ui.windowHeight())
                        )
                        ui.sameLine()
                        ui.setCursorX(ui.windowWidth() * 0.5 + 20 * cui.scale())
                        cui.snapCursor()

                        ui.dwriteTextAligned(
                                simutils.sessionTimeLeftString,
                                style.main.font.header.size,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                vec2(600 * cui.scale(), ui.windowHeight())
                        )

                        if callback.info then callback.info() end
                        if callback.vote then callback.vote() end
                end
        )

        topSubBar(path)

        ui.setCursorY(0)
        ui.setCursorX(topBarHeight * 1.5)
        if
                cui.iconTopBarButton(
                        "Session",
                        ui.Icons.Info,
                        buttonWidth,
                        topBarHeight,
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
        ui.sameLine()
        cui.offsetCursorX(5)

        if
                cui.iconTopBarButton(
                        "Laps",
                        ui.Icons.List,
                        buttonWidth,
                        topBarHeight,
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
        ui.sameLine()
        cui.offsetCursorX(5)

        if
                cui.iconTopBarButton(
                        "Telemetry",
                        ui.Icons.Barcode,
                        buttonWidth,
                        topBarHeight,
                        ui.ButtonFlags.None,
                        false,
                        nil,
                        pages.manager.currentPageName == "TelemetryPage"
                )
        then
                if pages.manager.currentPageName == "TelemetryPage" then
                        pages:goToMainMenu()
                else
                        pages:goToTelemetry()
                end
        end
        ui.sameLine()
        cui.offsetCursorX(5)

        if
                cui.iconTopBarButton(
                        "Garage",
                        ui.Icons.Wrench,
                        buttonWidth,
                        topBarHeight,
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
        ui.sameLine()

        ui.setCursorX(ui.windowWidth() * 0.5 - driveButtonWidth * 0.5)
        ui.setCursorY(topBarHeight * 0.5 - driveButtonHeight * 0.5)

        local readyToDriveState = simutils.readyToDriveState
        local readyToDrive, driveButtonText, reason, driveButtonColor =
                readyToDriveState[1], readyToDriveState[2], readyToDriveState[3], readyToDriveState[4]

        if
                cui.driveButton(
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

        ui.setCursorX(ui.windowWidth() - buttonWidth * 4 - 5 * cui.scale() * 3 - 20 * cui.scale())
        ui.setCursorY(0)

        if
                cui.iconTopBarButton(
                        "Store",
                        ui.Icons.Shopping,
                        buttonWidth,
                        topBarHeight,
                        ui.ButtonFlags.Disabled,
                        false,
                        nil,
                        pages.manager.currentPageName == "StorePage"
                )
        then
                if pages.manager.currentPageName == "SetupPage" then
                        pages:goToMainMenu()
                else
                        pages:goToSetup()
                end
        end
        ui.sameLine()
        cui.offsetCursorX(5)

        if
                cui.iconTopBarButton(
                        "About",
                        ui.Icons.Question,
                        buttonWidth,
                        topBarHeight,
                        ui.ButtonFlags.None,
                        false,
                        nil,
                        pages.manager.currentPageName == "AboutPage"
                )
        then
                if pages.manager.currentPageName == "AboutPage" then
                        pages:goToMainMenu()
                else
                        pages:goToAbout()
                end
        end
        ui.sameLine()
        cui.offsetCursorX(5)

        if cui.iconTopBarButton("Settings", ui.Icons.Settings, buttonWidth, topBarHeight, ui.ButtonFlags.None) then
                pages:goToSettings()
        end
        ui.sameLine()
        cui.offsetCursorX(5)

        if cui.iconTopBarButton("Quit", ui.Icons.Leave, buttonWidth, topBarHeight, ui.ButtonFlags.None) then
                cui.promptShutdownACDialog()
        end
end

function bottomWidgetBar()
        cui.pushContentWindow(
                "bottom_widget_bar_window",
                0,
                ui.windowHeight() - 240 * cui.scale(),
                ui.windowWidth(),
                240 * cui.scale(),
                nil,
                nil,
                true
        )

        local border = 3 * cui.scale()

        local widgetYPos = 0
        local widgetWidth = ui.windowWidth() / 3 - border * 2
        local widgetHeight = ui.windowHeight()

        cardWidget:draw(0, widgetYPos, widgetWidth * 0.5 - border * 2, widgetHeight)
        pedalsWidget:draw(widgetWidth * 0.5 + border, widgetYPos, widgetWidth * 0.5 - border, widgetHeight)
        tracesWidget:draw(ui.windowWidth() * 0.5 - widgetWidth * 0.5, widgetYPos, widgetWidth, widgetHeight)
        chatWidget:draw(ui.windowWidth() - widgetWidth, widgetYPos, widgetWidth, widgetHeight)

        cui.popContentWindow()
end

function settingsMenuCommon(path, bottomBarButtons)
        topSubBar("/Settings" .. path)
        bottomBar(bottomBarButtons)
end

function updateCommon()
        local imageSize = ui.imageSize(acLogo)
        local scale = imageSize.y / (topBarHeight * 0.78)
        acLogoSize = imageSize / scale
        topBarHeight = 130 * cui.scale()
end
