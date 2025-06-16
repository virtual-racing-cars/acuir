local page = {}

require("ui.pages.setup.setup_window")
require("ui.pages.setup.car_status_window")
require("ui.pages.setup.last_outing_window")
require("ui.pages.setup.setup_io")
require("classes.SetupManager")
local app = require("app")
local cui = require("ui.cui")
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

local function carStatusWindow()
        cui.pushContentWindow(
                "car_status_window",
                (ui.windowWidth() / 4) * 3,
                0,
                ui.windowWidth() / 4,
                ui.windowHeight(),
                function()
                        ui.setCursor(0)
                        if
                                cui.menuButton(
                                        "Car Status",
                                        40,
                                        0,
                                        0,
                                        0,
                                        carStatusActive,
                                        false,
                                        ui.CornerFlags.TopLeft
                                )
                        then
                        end

                        ui.sameLine()

                        if
                                cui.menuButton(
                                        "Last Outing",
                                        40,
                                        0,
                                        0,
                                        ui.ButtonFlags.Disabled,
                                        not carStatusActive,
                                        false,
                                        ui.CornerFlags.TopRight
                                )
                        then
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
                ui.windowWidth() / 4,
                ui.windowHeight() * 0.5 - 7.5 * cui.uiScale(),
                function()
                        ui.setCursor(0)
                        if cui.menuButton("Car Setup", 40, 0, 0, 0, not setupAppsActive, false, ui.CornerFlags.Top) then
                        end
                end
        )

        app.state.setupTab = setupTabBar(sm.setupTabs)
        cui.popContentWindow()

        cui.pushContentWindow(
                "setup_io_main_window",
                0,
                ui.windowHeight() * 0.5 + 7.5 * cui.uiScale(),
                ui.windowWidth() / 4,
                ui.windowHeight() * 0.5 - 7.5 * cui.uiScale(),
                function()
                        ui.setCursor(0)
                        if
                                cui.menuButton(
                                        "Local Setups",
                                        40,
                                        0,
                                        0,
                                        0,
                                        not setupExchangeActive,
                                        false,
                                        ui.CornerFlags.TopLeft
                                )
                        then
                                setupExchangeActive = false
                        end

                        ui.sameLine()

                        if
                                cui.menuButton(
                                        "Setup Exchange",
                                        40,
                                        0,
                                        0,
                                        0,
                                        setupExchangeActive,
                                        false,
                                        ui.CornerFlags.TopRight
                                )
                        then
                                setupExchangeActive = true
                        end
                end,
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
        setupIoWindow()

        return app.state.setupTab > 1 and "" or "apps"
end

return page
