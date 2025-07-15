local page = {}

require("ui.pages.setup.setup_window")
require("classes.SetupManager")
local app = require("app")
local cui = require("ui.cui")
local settings = require("settings")
local style = require("ui.style")

local car = ac.getCar(0)

local helpWindowDelay = 0

local vec2Temp1 = vec2()

sm = SetupManager()

local function setupItemWindow()
        cui.pushContentWindow(
                "car_setup_items_window",
                ui.windowWidth() * 0.22 + 15 * cui.scale(),
                0,
                ui.windowWidth() * 0.56 - 30 * cui.scale(),
                ui.windowHeight(),
                function()
                        ui.setCursor(0)

                        local title = sm.setupTabs[app.state.setupTab].name

                        ui.dwriteTextAligned(
                                title,
                                style.main.font.header.size,
                                ui.Alignment.Center,
                                ui.Alignment.Center,
                                ui.windowSize()
                        )
                end,
                nil,
                true
        )

        car_setup(sm)

        cui.popContentWindow()
end

local WidgetWindow = require("classes.WidgetWindow")

local setupHelpWidget = WidgetWindow("setup_help")
setupHelpWidget:addWidget("Help", require("ui.widgets.setup_help"))

local carSetupWindow = WidgetWindow("car_setup")

carSetupWindow:addWidget("Car Setup", require("ui.widgets.setup_tab_bar"))
carSetupWindow:addWidget("Local Setups", require("ui.widgets.local_setups"))
carSetupWindow:addWidget("Setup Exchange", require("ui.widgets.setup_exchange"))
-- carSetupWindow:addWidget("Setup Exchange", function() setupExchange:draw() end)

local saveSetupWindow = WidgetWindow("save_setup")
saveSetupWindow:addWidget("Save Setup", require("ui.widgets.save_setup"))

local carStatusWindow = WidgetWindow("car_status")
carStatusWindow:addWidget("Car Status", require("ui.widgets.car_status"))

local dataLoggerWindow = WidgetWindow("data_logger")
dataLoggerWindow:addWidget("CSP Data Logger", require("ui.widgets.data_logger"))

function page:draw()
        if sm.activeHelpString == "" then helpWindowDelay = os.clock() + 0.3 end

        if helpWindowDelay > os.clock() then
                carSetupWindow:setPosition(0, 0)
                carSetupWindow:setSize(ui.windowWidth() * 0.22, ui.windowHeight() * 0.75 - 7.5 * cui.scale())
                carSetupWindow:draw()

                saveSetupWindow:setPosition(0, ui.windowHeight() * 0.75 + 7.5 * cui.scale())
                saveSetupWindow:setSize(ui.windowWidth() * 0.22, ui.windowHeight() * 0.25 - 7.5 * cui.scale())
                saveSetupWindow:draw()
        else
                setupHelpWidget:setPosition(0, 0)
                setupHelpWidget:setSize(ui.windowWidth() * 0.22, ui.windowHeight())
                setupHelpWidget:draw()
        end

        setupItemWindow()

        carStatusWindow:setPosition(ui.windowWidth() * 0.78, 0)
        carStatusWindow:setSize(ui.windowWidth() * 0.22, ui.windowHeight() * 0.84 - 7.5 * cui.scale())
        carStatusWindow:draw()

        dataLoggerWindow:setPosition(ui.windowWidth() * 0.78, ui.windowHeight() * 0.84 + 7.5 * cui.scale())
        dataLoggerWindow:setSize(ui.windowWidth() * 0.22, ui.windowHeight() * 0.16 - 7.5 * cui.scale())
        dataLoggerWindow:draw()

        return app.state.setupTab > 1 and "finalize" or "apps"
end

return page
