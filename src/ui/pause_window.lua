require("ui.common")
require("classes.PageManager")
local app = require("app")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")
local style = require("style")
pages.manager:registerPage("PauseMenu", require("ui.pause.page_pause_home"))

function PauseMenuWindow(dt)
        local exclusiveHudMode = ""

        ui.pushAllowKeyboardFocus(false)
        style:pushStyleMain()

        if ac.isKeyPressed(ui.KeyIndex.XButton1) then pages:undo() end
        if ac.isKeyPressed(ui.KeyIndex.XButton2) then pages:redo() end

        local childWindowWith = 2560 * cui.scaleX()
        local childWindowHeight = 1440 * cui.scaleY()
        local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse

        if cui.modalDialogCallback then
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

        if cui.modalDialogCallback then
                cui.contentWindow(
                        "callback_window",
                        vec2(0, 0),
                        ui.windowSize(),
                        ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
                        function()
                                ui.setCursor(0)
                                ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.Appearance.uiColor1 / 1.2)
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
                                                if cui.modalDialogCallback() then cui.modalDialogCallback = nil end
                                        end
                                )
                        end
                )
        end

        ui.popAllowKeyboardFocus()
        style:popStyleMain()

        return app.state.debug and "debug" or exclusiveHudMode
end
