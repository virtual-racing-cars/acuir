require("classes.PageManager")
require("ui.common")
local app = require("app")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")
local style = require("style")
local sim = ac.getSim()

function SettingsWindow(dt)
        style:pushStyleMain()
        ui.pushAllowKeyboardFocus(false)

        local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse
        if cui.modalDialogCallback then
                mainWindowFlags = mainWindowFlags
                        + ui.WindowFlags.NoInputs
                        + ui.WindowFlags.NoMouseInputs
                        + ui.WindowFlags.NoFocusOnAppearing
        end

        updateCommon()

        cui.pushWindowFull("settings_main_window", mainWindowFlags, false)

        ui.drawRectFilled(
                vec2(0, 0),
                vec2(ui.windowWidth(), ui.windowHeight()),
                settings.Appearance.uiThemeColor1 / 1.1
        )

        cui.pushWindowFitted("settings_fitted_window")
        topSubBar()

        pages.manager:draw()

        cui.popWindow(false)
        cui.popWindow(false)

        if cui.modalDialogCallback then
                cui.pushWindowFull("callback_window")
                ui.setCursor(0)
                ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.Appearance.uiThemeColor1 / 1.2)
                local childWindowWith = ui.windowWidth() / 5
                local childWindowHeight = ui.windowHeight() / 5
                cui.pushWindow(
                        "callback_subwindow",
                        0,
                        (ui.windowHeight() - childWindowHeight) / 2,
                        ui.windowWidth(),
                        childWindowHeight
                )

                ui.bringWindowToFront()
                ui.setCursor(0)
                if cui.modalDialogCallback() then cui.modalDialogCallback = nil end

                cui.popWindow()
                cui.popWindow()
        end

        style:popStyleMain()
        ui.popAllowKeyboardFocus()

        return app.state.debug and "debug" or ""
end
