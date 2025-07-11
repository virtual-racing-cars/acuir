local page = {}

require("ui.pages.setup.setup_window")
require("ui.pages.setup.car_status_window")
require("ui.pages.setup.last_outing_window")
require("ui.pages.setup.setup_io")
require("classes.SetupManager")
local app = require("app")
local cui = require("ui.cui")
local dataLogger = require("data_logger")
local settings = require("settings")
local setupExchange = require("setup_exchange")
local style = require("src.ui.style")
local car = ac.getCar(0)

local carStatusActive = true
local setupExchangeActive = true
local setupAppsActive = false

local vec2Temp1 = vec2()

sm = SetupManager()

local function setupItemWindow()
        cui.pushWindow("car_setup_items_window", ui.windowWidth() * 0.25, 0, ui.windowWidth() * 0.5, ui.windowHeight())

        if setupAppsActive then
        else
                car_setup(sm)
        end

        cui.popWindow()
end

local function helpWindow()
        if sm.activeHelpString == "" then return end

        cui.pushContentWindow("help_window", 0, 0, ui.windowWidth() * 0.22, ui.windowHeight(), function()
                ui.setCursor(0)
                if cui.windowTabButton("Help", 36, ui.ButtonFlags.None, false) then
                end
        end)

        cui.setCursorY(10)
        cui.setCursorX(15)
        ui.pushTextWrapPosition(ui.windowWidth() - 15 * cui.scale())
        cui.snapCursor()
        ui.dwriteText(sm.activeHelpString, style.main.font.body.size)

        ui.popTextWrapPosition()

        cui.popContentWindow()
end

local function dataLoggingWindow()
        cui.pushContentWindow(
                "data_logging_window",
                ui.windowWidth() * 0.78,
                0,
                ui.windowWidth() * 0.22,
                ui.windowHeight() * 0.16 - 7.5 * cui.scale(),
                function()
                        ui.setCursor(0)
                        if cui.windowTabButton("CSP Data Logger", 36, ui.ButtonFlags.None, false) then
                        end
                        ui.sameLine()

                        if not dataLogger:loggerActive() then return end

                        cui.offsetCursorY(8)
                        local tempCursor = ui.getCursor()
                        ui.icon(
                                ui.Icons.LoadingSpinner,
                                vec2(ui.windowHeight() * 0.5, ui.windowHeight() * 0.5),
                                settings.Appearance.uiColorSecondary
                        )
                        ui.setCursor(tempCursor)
                        ui.icon(
                                ui.Icons.Target,
                                vec2(ui.windowHeight() * 0.5, ui.windowHeight() * 0.5),
                                settings.Appearance.uiColorSecondary,
                                ui.windowHeight() * 0.25
                        )
                        ui.sameLine()
                        cui.offsetCursorY(-8)

                        cui.offsetCursorX(8)
                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                dataLogger:loggerTime(),
                                style.main.font.body.size,
                                ui.Alignment.Start,
                                ui.Alignment.Center,
                                ui.windowSize(),
                                rgbm.colors.white
                        )
                end,
                function()
                        settings.DataLogger.autoStartLogging = drawCheckbox(
                                "##dataLoggerAutoStart",
                                "Auto-Start",
                                style.main.font.body.size,
                                settings.DataLogger.autoStartLogging
                        )
                end
        )

        if not car.extendedPhysics then
                ui.setCursor(0)
                ui.dwriteTextAligned(
                        "Requires a Car with Extended Physics",
                        style.main.font.body.size,
                        ui.Alignment.Center,
                        ui.Alignment.Center,
                        ui.windowSize(),
                        false,
                        settings.Appearance.uiColorTextDim
                )
                cui.popContentWindow()
                return
        end

        local buttonSize = ui.windowHeight() * 0.8

        ui.setCursorX(ui.windowHeight() * 0.3)
        ui.setCursorY(ui.windowHeight() * 0.15)
        if
                cui.iconButton(
                        dataLogger:loggerActive() and "Stop & Save" or "Start",
                        dataLogger:loggerActive() and ui.Icons.Save or ui.Icons.Target,
                        buttonSize,
                        buttonSize,
                        0
                )
        then
                if dataLogger:loggerActive() then
                        dataLogger:loggerEnd()
                else
                        dataLogger:loggerStart()
                end
        end

        ui.setCursorX(ui.windowWidth() * 0.5 - ui.windowHeight() * 0.5)
        ui.setCursorY(ui.windowHeight() * 0.15)
        if
                cui.iconButton(
                        "Cancel",
                        ui.Icons.Cancel,
                        buttonSize,
                        buttonSize,
                        dataLogger:loggerActive() and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                )
        then
                dataLogger:loggerDrop()
        end

        ui.setCursorX(ui.windowWidth() - ui.windowHeight() * 1.3)
        ui.setCursorY(ui.windowHeight() * 0.15)
        if cui.iconButton("Logs", ui.Icons.Folder, buttonSize, buttonSize, 0) then
                local logDirectory = dataLogger:getMotecDirectory(0)
                if not io.dirExists(logDirectory) then io.createDir(logDirectory) end
                os.openInExplorer(logDirectory)
        end

        cui.popContentWindow()
end

local function carStatusWindow()
        cui.pushContentWindow(
                "car_status_window",
                ui.windowWidth() * 0.78,
                ui.windowHeight() * 0.16 + 7.5 * cui.scale(),
                ui.windowWidth() * 0.22,
                ui.windowHeight() * 0.84 - 7.5 * cui.scale(),
                function()
                        ui.setCursor(0)
                        if cui.windowTabButton("Car Status", 36, ui.ButtonFlags.None, carStatusActive) then
                        end

                        ui.sameLine()

                        if cui.windowTabButton("Last Outing", 36, ui.ButtonFlags.Disabled, not carStatusActive) then
                        end
                end
        )

        if carStatusActive then
                CarStatusWindow()
        else
                LastOutingWindow()
        end

        cui.popContentWindow()
end

local carSetupTab = 1
local saveSetupTab = 1

local function setupExchangeFooter()
        if cui.menuButton("Reset All", ui.windowSize(), nil, nil) then
                ac.resetSetupToDefault()
                cui.menuBanner("Setup reset to default", nil, rgbm.colors.orange)
        end
end

local WidgetWindow = require("src.classes.WidgetWindow")

local carSetupWindow = WidgetWindow("car_setup")

carSetupWindow:addWidget("Car Setup", function()
        cui.pushWindow("setup_tab_bar_window", 0, 0, ui.windowWidth(), ui.windowHeight(), true)
        app.state.setupTab = setupTabBar(sm.setupTabs)
        cui.popWindow(false)
end)

carSetupWindow:addWidget("Local Setups", function() drawSetupIO(sm) end)

carSetupWindow:addWidget("Setup Exchange", function() setupExchange:draw() end)

local function setupIoWindow()
        ui.setCursor(0)

        carSetupWindow:draw()

        cui.pushContentWindow(
                "setup_save_window",
                0,
                ui.windowHeight() * 0.75 + 7.5 * cui.scale(),
                ui.windowWidth() * 0.22,
                ui.windowHeight() * 0.25 - 7.5 * cui.scale(),
                function()
                        ui.setCursor(0)
                        if
                                cui.windowTabButton(
                                        "Save Setup",
                                        ui.windowHeight(),
                                        ui.ButtonFlags.None,
                                        saveSetupTab == 1
                                )
                        then
                                saveSetupTab = 1
                        end
                        ui.sameLine()

                        -- if
                        --         cui.windowTabButton(
                        --                 "Setup Changelog",
                        --                 ui.windowHeight(),
                        --                 ui.ButtonFlags.None,
                        --                 saveSetupTab == 2
                        --         )
                        -- then
                        --         saveSetupTab = 2
                        -- end
                end,
                nil
        )

        drawSetupControls(sm)

        cui.popContentWindow()
end

function page:draw()
        setupItemWindow()
        carStatusWindow()
        dataLoggingWindow()

        if sm.activeHelpString == "" then
                setupIoWindow()
        else
                helpWindow()
        end

        return app.state.setupTab > 1 and "finalize" or "apps"
end

return page
