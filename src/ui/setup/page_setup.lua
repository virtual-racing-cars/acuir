local page = {}

require("ui.setup.setup_window")
require("ui.setup.car_status_window")
require("src.ui.setup.setup_io")
require("classes.SetupManager")
local app = require("app")
local cui = require("ui.cui")

local vec2Temp1 = vec2()

sm = SetupManager()

local function setupItemWindow()
        ui.setCursor(0)
        cui.pushWindow(
                "car_setup_items_window",
                ui.windowWidth() / 4,
                56 * cui.scaleY(),
                ui.windowWidth() / 2,
                ui.windowHeight() - 56 * cui.scaleY()
        )
        ui.drawRectFilled(0, ui.windowSize(), rgbm(0, 0, 0, 0.25))

        ui.setCursor(0)
        car_setup(sm)
        cui.popWindow()
end

local function carStatusWindow()
        ui.setCursor(0)
        cui.pushWindow(
                "car_status_window",
                (ui.windowWidth() / 4) * 3,
                56 * cui.scaleY(),
                ui.windowWidth() / 4,
                ui.windowHeight() - 56 * cui.scaleY()
        )
        ui.setCursor(0)
        ui.drawRectFilled(0, ui.windowSize(), rgbm(0, 0, 0, 0.5))
        ui.drawRectFilled(0, vec2(ui.windowWidth(), ui.windowHeight() / 20), rgbm(0, 0, 0, 1))

        cui.menuButton("Car Status", vec2Temp1:set(ui.windowWidth() / 2, ui.windowHeight() / 20), 0, 0, 0, false, false)
        ui.sameLine()

        cui.menuButton(
                "Last Outing",
                vec2Temp1:set(ui.windowWidth() / 2, ui.windowHeight() / 20),
                0,
                0,
                ui.ButtonFlags.Disabled,
                false,
                false
        )

        ui.setCursor(0)
        cui.contentWindow(
                "car_status_subwindow",
                vec2(0, ui.windowHeight() / 20),
                vec2(ui.windowWidth() + 20, ui.windowHeight() - ui.windowHeight() / 20),
                ui.WindowFlags.None,
                function() CarStatusWindow() end
        )
        cui.popWindow()
end

local setupExchangeActive = false
local setupGarageActive = false

local function setupIoWindow()
        ui.setCursor(0)
        cui.contentWindow(
                "setup_left_window",
                vec2(0, 56 * cui.scaleY()),
                vec2(ui.windowWidth() / 4, ui.windowHeight() - 56 * cui.scaleY()),
                ui.WindowFlags.None,
                function()
                        ui.setCursor(0)
                        ui.drawRectFilled(0, ui.windowSize(), rgbm(0.1, 0.1, 0.1, 1))
                        ui.drawRectFilled(0, vec2(ui.windowWidth(), ui.windowHeight() / 20), rgbm(0, 0, 0, 1))
                        local genericButtonHeight = ui.windowHeight() / 20

                        if
                                cui.menuButton(
                                        "I/O",
                                        vec2Temp1:set(ui.windowWidth() / 2, genericButtonHeight),
                                        0,
                                        0,
                                        0,
                                        not setupGarageActive,
                                        false
                                )
                        then
                                setupGarageActive = false
                        end
                        ui.sameLine()

                        if
                                cui.menuButton(
                                        "Edit Setup",
                                        vec2Temp1:set(ui.windowWidth() / 2, genericButtonHeight),
                                        0,
                                        0,
                                        0,
                                        setupGarageActive,
                                        false
                                )
                        then
                                setupGarageActive = true
                        end

                        ui.setCursor(0)
                        cui.contentWindow(
                                "setup_io_track_subwindow",
                                vec2(0, genericButtonHeight),
                                vec2(ui.windowWidth(), ui.windowHeight() - genericButtonHeight),
                                ui.WindowFlags.None,
                                function()
                                        if setupGarageActive then
                                                cui.contentWindow(
                                                        "setup_garage_window",
                                                        vec2(0, 0),
                                                        vec2(ui.windowWidth(), ui.windowHeight() - genericButtonHeight),
                                                        ui.WindowFlags.NoScrollWithMouse,
                                                        function()
                                                                ui.setCursorY(0)

                                                                app.state.setupTab = setupTabBar(sm.setupTabs)
                                                        end,
                                                        false,
                                                        true
                                                )

                                                ui.setCursorX(0)
                                                if
                                                        cui.menuButton(
                                                                "Reset",
                                                                vec2Temp1:set(ui.windowWidth() / 3, genericButtonHeight),
                                                                0,
                                                                0,
                                                                0,
                                                                false,
                                                                false
                                                        )
                                                then
                                                        sm:resetSetup()
                                                end
                                                ui.sameLine()

                                                if
                                                        cui.menuButton(
                                                                "Undo",
                                                                vec2Temp1:set(ui.windowWidth() / 3, genericButtonHeight),
                                                                0,
                                                                0,
                                                                sm:isUndoAvailable() and 0 or ui.ButtonFlags.Disabled,
                                                                false,
                                                                false
                                                        )
                                                then
                                                        sm:undo()
                                                end
                                                ui.sameLine()

                                                if
                                                        cui.menuButton(
                                                                "Redo",
                                                                vec2Temp1:set(ui.windowWidth() / 3, genericButtonHeight),
                                                                0,
                                                                0,
                                                                sm:isRedoAvailable() and 0 or ui.ButtonFlags.Disabled,
                                                                false,
                                                                false
                                                        )
                                                then
                                                        sm:redo()
                                                end

                                                return
                                        end

                                        ui.setCursor(0)

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
                                                        sm._apps["Setup Exchange"] and ui.ButtonFlags.None
                                                                or ui.ButtonFlags.Disabled,
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
                                                                ui.drawRectFilled(
                                                                        vec2(0, 0),
                                                                        ui.windowSize(),
                                                                        rgbm(0.1, 0.1, 0.1, 1)
                                                                )
                                                                sm._apps["Setup Exchange"].script[sm._apps["Setup Exchange"].setupWindow]()
                                                        else
                                                                setupIoDraw(sm)
                                                        end
                                                end
                                        )
                                end
                        )
                end
        )
end

function page:draw()
        cui.pushWindowFitted("setup_page_window")

        topBar("/ Vehicle Setup")

        cui.pushWindow(
                "car_setup_window",
                0,
                124 * cui.scaleY(),
                ui.windowWidth(),
                ui.windowHeight() - 124 * cui.scaleY()
        )
        ui.setCursor(0)

        setupItemWindow()
        carStatusWindow()
        setupIoWindow()

        cui.popWindow()

        -- bottomBar(bottomBarButtons)

        cui.popWindow()

        return app.state.setupTab > 1 and "" or "apps"
end

return page
