local page = {}

require("ui.pages.setup.setup_window")
require("ui.pages.setup.car_status_window")
require("ui.pages.setup.last_outing_window")
require("ui.pages.setup.setup_io")
require("classes.SetupManager")
local app = require("app")
local cui = require("ui.cui")

local carStatusActive = true
local setupExchangeActive = false
local setupAppsActive = false

local vec2Temp1 = vec2()

local genericButtonHeight = 50
local fontSize = genericButtonHeight

sm = SetupManager()

local function setupItemWindow()
        ui.setCursor(0)
        cui.pushWindow("car_setup_items_window", ui.windowWidth() / 4, 0, ui.windowWidth() / 2, ui.windowHeight())
        ui.drawRectFilled(0, ui.windowSize(), rgbm(0, 0, 0, 0.25))

        ui.setCursor(0)
        car_setup(sm)
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
                                        genericButtonHeight,
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
                                        genericButtonHeight,
                                        0,
                                        0,
                                        0,
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
                        if
                                cui.menuButton(
                                        "Car Setup",
                                        genericButtonHeight,
                                        0,
                                        0,
                                        0,
                                        not setupAppsActive,
                                        false,
                                        ui.CornerFlags.TopLeft
                                )
                        then
                                setupAppsActive = false
                        end

                        ui.sameLine()

                        if
                                cui.menuButton(
                                        "Setup Apps",
                                        genericButtonHeight,
                                        0,
                                        0,
                                        0,
                                        setupAppsActive,
                                        false,
                                        ui.CornerFlags.TopRight
                                )
                        then
                                setupAppsActive = true
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
                                        genericButtonHeight,
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
                                        genericButtonHeight,
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
        genericButtonHeight = 50 * cui.uiScale()
        fontSize = math.floor(genericButtonHeight * 0.55)

        setupItemWindow()
        carStatusWindow()
        setupIoWindow()

        return app.state.setupTab > 1 and "" or "apps"
end

return page
