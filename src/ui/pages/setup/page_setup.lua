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

local carStatusActive = true
local setupExchangeActive = false
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

        cui.pushContentWindow("help_window", 0, 0, ui.windowWidth() / 5, ui.windowHeight(), function()
                ui.setCursor(0)
                if cui.windowTabButton("Help", 36, ui.ButtonFlags.None, false) then
                end
        end)

        cui.setCursorY(10)
        cui.setCursorX(15)
        ui.pushTextWrapPosition(ui.windowWidth() - 15 * cui.uiScale())
        cui.snapCursor()
        ui.dwriteText(sm.activeHelpString, 18 * cui.uiScale())

        ui.popTextWrapPosition()

        cui.popContentWindow()
end

local function dataLoggingWindow()
        cui.pushContentWindow(
                "data_logging_window",
                (ui.windowWidth() / 5) * 4,
                0,
                ui.windowWidth() / 5,
                ui.windowHeight() * 0.16 - 7.5 * cui.uiScale(),
                function()
                        ui.setCursor(0)
                        if cui.windowTabButton("CSP Data Logger", 36, ui.ButtonFlags.None, false) then
                        end
                        ui.setCursor(0)

                        if not dataLogger:loggerActive() then return end

                        cui.offsetCursorX(-40)
                        ui.dwriteTextAligned(
                                dataLogger:loggerTime(),
                                18 * cui.uiScale(),
                                ui.Alignment.End,
                                ui.Alignment.Center,
                                ui.windowSize(),
                                rgbm.colors.white
                        )

                        ui.drawCircleFilled(
                                vec2(ui.windowWidth() - 20 * cui.uiScale(), ui.windowHeight() * 0.5),
                                10 * cui.uiScale(),
                                rgbm.colors.red
                        )
                end
        )

        ui.setCursorX(ui.windowHeight() * 0.3)
        ui.setCursorY(0)
        if
                cui.iconButton(
                        dataLogger:loggerActive() and "Stop & Save" or "Start",
                        dataLogger:loggerActive() and ui.Icons.Save or ui.Icons.Target,
                        ui.windowHeight(),
                        ui.windowHeight() * 0.7,
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
        ui.setCursorY(0)
        if
                cui.iconButton(
                        "Cancel",
                        ui.Icons.Cancel,
                        ui.windowHeight(),
                        ui.windowHeight() * 0.7,
                        dataLogger:loggerActive() and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
                )
        then
                dataLogger:loggerDrop()
        end

        ui.setCursorX(ui.windowWidth() - ui.windowHeight() * 1.3)
        ui.setCursorY(0)
        if cui.iconButton("Logs", ui.Icons.Folder, ui.windowHeight(), ui.windowHeight() * 0.7, 0) then
                local logDirectory = dataLogger:getMotecDirectory(0)
                if not io.dirExists(logDirectory) then io.createDir(logDirectory) end
                os.openInExplorer(logDirectory)
        end

        cui.popContentWindow()
end

local function carStatusWindow()
        cui.pushContentWindow(
                "car_status_window",
                (ui.windowWidth() / 5) * 4,
                ui.windowHeight() * 0.16 + 7.5 * cui.uiScale(),
                ui.windowWidth() / 5,
                ui.windowHeight() * 0.84 - 7.5 * cui.uiScale(),
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

local function setupIoWindow()
        ui.setCursor(0)

        cui.pushContentWindow(
                "setup_left_window",
                0,
                0,
                ui.windowWidth() / 5,
                ui.windowHeight() * 0.5 - 7.5 * cui.uiScale(),
                function()
                        ui.setCursor(0)
                        if cui.windowTabButton("Car Setup", 36, ui.ButtonFlags.None, false) then
                        end
                end,
                function()
                        if cui.menuButton("Reset All", ui.windowSize(), nil, nil) then
                                ac.resetSetupToDefault()
                                cui.menuBanner("Setup reset to default", nil, rgbm.colors.orange)
                        end
                end
        )

        cui.pushWindow("setup_tab_bar_window", 0, 0, ui.windowWidth(), ui.windowHeight(), true)
        app.state.setupTab = setupTabBar(sm.setupTabs)
        cui.popWindow(false)

        cui.popContentWindow()

        cui.pushContentWindow(
                "setup_io_main_window",
                0,
                ui.windowHeight() * 0.5 + 7.5 * cui.uiScale(),
                ui.windowWidth() / 5,
                ui.windowHeight() * 0.5 - 7.5 * cui.uiScale(),
                function()
                        ui.setCursor(0)
                        if cui.windowTabButton("Local Setups", 36, ui.ButtonFlags.None, not setupExchangeActive) then
                                setupExchangeActive = false
                        end
                        ui.sameLine()

                        if cui.windowTabButton("Setup Exchange", 36, ui.ButtonFlags.None, setupExchangeActive) then
                                setupExchangeActive = true
                        end
                        ui.sameLine()
                end,
                nil,
                true
        )

        if setupExchangeActive then
                sm._apps["Setup Exchange"].script[sm._apps["Setup Exchange"].setupWindow]()
        else
                drawSetupIO(sm)
        end

        cui.popContentWindow()
end

function page:draw()
        setupItemWindow()
        carStatusWindow()
        dataLoggingWindow()
        setupIoWindow()
        helpWindow()

        return app.state.setupTab > 1 and "" or "apps"
end

return page
