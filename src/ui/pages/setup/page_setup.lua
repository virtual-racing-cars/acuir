local page = {}

require("ui.pages.setup.setup_window")
require("ui.pages.setup.car_status_window")
require("ui.pages.setup.last_outing_window")
require("ui.pages.setup.setup_io")
require("classes.SetupManager")
local app = require("app")
local cui = require("ui.cui")

local carStatusActive = true

local vec2Temp1 = vec2()

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
        local genericButtonHeight = 50 * cui.uiScale()

        ui.setCursor(0)
        cui.pushWindow("car_status_window", (ui.windowWidth() / 4) * 3, 0, ui.windowWidth() / 4, ui.windowHeight())
        ui.setCursor(0)
        ui.drawRectFilled(0, ui.windowSize(), rgbm(0, 0, 0, 0.5))
        ui.drawRectFilled(0, vec2(ui.windowWidth(), genericButtonHeight), rgbm(0, 0, 0, 1))

        if
                cui.menuButton(
                        "Car Status",
                        vec2Temp1:set(ui.windowWidth() / 2, genericButtonHeight),
                        0,
                        0,
                        0,
                        carStatusActive,
                        false
                )
        then
                carStatusActive = true
        end
        ui.sameLine()

        if
                cui.menuButton(
                        "Last Outing",
                        vec2Temp1:set(ui.windowWidth() / 2, genericButtonHeight),
                        0,
                        0,
                        ui.ButtonFlags.Disabled,
                        not carStatusActive,
                        false
                )
        then
                carStatusActive = false
        end

        ui.setCursor(0)
        cui.contentWindow(
                "car_status_subwindow",
                vec2(0, genericButtonHeight),
                vec2(ui.windowWidth() + 20, ui.windowHeight() - genericButtonHeight),
                ui.WindowFlags.None,
                function()
                        if carStatusActive then
                                CarStatusWindow()
                        else
                                LastOutingWindow()
                        end
                end
        )
        cui.popWindow()
end

local setupExchangeActive = false

local function setupIoWindow()
        local genericButtonHeight = 50 * cui.uiScale()
        local fontSize = math.floor(genericButtonHeight * 0.55)

        ui.setCursor(0)
        cui.contentWindow(
                "setup_left_window",
                vec2(0, 0),
                vec2(ui.windowWidth() / 4, ui.windowHeight() * 0.5 - 7.5 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)
                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 1))
                        ui.drawRectFilled(0, vec2(ui.windowWidth(), genericButtonHeight), rgbm(0, 0, 0, 1))

                        cui.snapCursor()
                        ui.dwriteTextAligned(
                                "CAR SETUP",
                                fontSize,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                vec2(ui.windowWidth(), genericButtonHeight)
                        )

                        cui.contentWindow(
                                "setup_garage_window",
                                vec2(0, fontSize * 2),
                                vec2(ui.windowWidth(), ui.windowHeight() - genericButtonHeight * 2),
                                ui.WindowFlags.NoScrollWithMouse,
                                function()
                                        ui.setCursorY(0)

                                        app.state.setupTab = setupTabBar(sm.setupTabs)
                                end,
                                false,
                                true
                        )
                end
        )

        cui.contentWindow(
                "setup_left_window2",
                vec2(0, ui.windowHeight() * 0.5 + 7.5 * cui.uiScale()),
                vec2(ui.windowWidth() / 4, ui.windowHeight() * 0.5 - 7.5 * cui.uiScale()),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)
                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 1))
                        ui.drawRectFilled(0, vec2(ui.windowWidth(), genericButtonHeight), rgbm(0, 0, 0, 1))

                        if
                                cui.menuButton(
                                        "Local Setups",
                                        vec2Temp1:set(ui.windowWidth() / 2, genericButtonHeight),
                                        0,
                                        0,
                                        0,
                                        not setupExchangeActive,
                                        false
                                )
                        then
                                setupExchangeActive = false
                        end
                        ui.sameLine()

                        if
                                cui.menuButton(
                                        "Setup Exchange",
                                        vec2Temp1:set(ui.windowWidth() / 2, genericButtonHeight),
                                        0,
                                        0,
                                        sm._apps["Setup Exchange"] and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
                                        setupExchangeActive,
                                        false
                                )
                        then
                                setupExchangeActive = true
                        end

                        cui.contentWindow(
                                "setup_io_window_6",
                                vec2(0, genericButtonHeight),
                                vec2(ui.windowWidth(), ui.windowHeight() - genericButtonHeight),
                                ui.WindowFlags.None,
                                function()
                                        if setupExchangeActive then
                                                ui.drawRectFilled(vec2(0, 0), ui.windowSize(), rgbm(0.1, 0.1, 0.1, 1))
                                                sm._apps["Setup Exchange"].script[sm._apps["Setup Exchange"].setupWindow]()
                                        else
                                                drawSetupIO(sm)
                                        end
                                end
                        )
                end
        )
end

function page:draw()
        cui.pushWindow("car_setup_window", 0, 0, ui.windowWidth(), ui.windowHeight())
        ui.setCursor(0)

        setupItemWindow()
        carStatusWindow()
        setupIoWindow()

        cui.popWindow()

        return app.state.setupTab > 1 and "" or "apps"
end

return page
