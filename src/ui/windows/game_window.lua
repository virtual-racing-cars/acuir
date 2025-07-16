require("ui.common")
require("classes.PageManager")
local app = require("app")
local callback = require("callback")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")
local style = require("ui.cui.style")

pages.manager:registerPage("GamePage", require("ui.pages.page_game"))

function GameWindow(dt)
        local exclusiveHudMode = ""

        style:pushStyleMain()

        local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse

        if callback.dialog then
                mainWindowFlags = mainWindowFlags
                        + ui.WindowFlags.NoInputs
                        + ui.WindowFlags.NoMouseInputs
                        + ui.WindowFlags.NoFocusOnAppearing
        end

        cui.contentWindow(
                "pause_window",
                vec2(0, 0),
                ui.windowSize(),
                mainWindowFlags,
                function() exclusiveHudMode = pages.manager:draw() end
        )

        if callback.dialog then
                cui.contentWindow(
                        "callback_window",
                        vec2(0, 0),
                        ui.windowSize(),
                        ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
                        function()
                                ui.setCursor(0)
                                ui.drawRectFilled(0, ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.98)
                                local childWindowWith = ui.windowWidth() / 5
                                local childWindowHeight = ui.windowHeight() / 5
                                cui.contentWindow(
                                        "callback_subwindow",
                                        vec2(
                                                (ui.windowWidth() - childWindowWith) / 2,
                                                (ui.windowHeight() - childWindowHeight) / 2
                                        ),
                                        vec2(childWindowWith, childWindowHeight),
                                        ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
                                        function()
                                                ui.bringWindowToFront()
                                                ui.setCursor(0)
                                                if callback.dialog() then callback.dialog = nil end
                                        end
                                )
                        end
                )
        end

        style:popStyleMain()

        return app.state.debug and "debug" or exclusiveHudMode
end
