require("ui.common")
require("classes.PageManager")
local app = require("app")
local callback = require("callback")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")
local style = require("src.ui.style")
pages.manager:registerPage("PauseMenu", require("ui.pages.pause.page_pause_home"))

function PauseMenuWindow(dt)
        local exclusiveHudMode = ""

        ui.pushAllowKeyboardFocus(false)
        style:pushStyleMain()

        if ac.isKeyPressed(ui.KeyIndex.XButton1) then pages:undo() end
        if ac.isKeyPressed(ui.KeyIndex.XButton2) then pages:redo() end

        local childWindowWith = 2560 * cui.scale()
        local childWindowHeight = 1440 * cui.scale()
        local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse

        if callback.dialog then
                mainWindowFlags = mainWindowFlags
                        + ui.WindowFlags.NoInputs
                        + ui.WindowFlags.NoMouseInputs
                        + ui.WindowFlags.NoFocusOnAppearing
        end

        cui.contentWindow(
                "pause_window",
                vec2((ui.windowWidth() - childWindowWith) / 2, (ui.windowHeight() - childWindowHeight) / 2),
                vec2(childWindowWith, childWindowHeight),
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

        ui.popAllowKeyboardFocus()
        style:popStyleMain()

        return app.state.debug and "debug" or exclusiveHudMode
end
