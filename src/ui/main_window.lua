require("classes.PageManager")
require("ui.common")
local app = require("app")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")
local style = require("style")
local sim = ac.getSim()

pages.manager:registerPage("MainMenu", require("ui.main.page_main_home"))
pages.manager:registerPage("SetupPage", require("ui.setup.page_setup"))
pages.manager:registerPage("SettingsPage", require("ui.settings.page_settings"))
pages.manager:registerPage("SetupAppsPage", require("ui.setup.page_apps"))
pages.manager:registerPage("SettingsGeneralPage", require("ui.settings.page_general"))
pages.manager:registerPage("SettingsControlsPage", require("ui.settings.page_controls"))
pages.manager:registerPage("SettingsAudioPage", require("ui.settings.page_audio"))
pages.manager:registerPage("SettingsAppearancePage", require("ui.settings.page_appearance"))
pages.manager:registerPage("SettingsAiPage", require("ui.settings.page_ai"))
pages.manager:registerPage("TelemetryPage", require("ui.telemetry.page_telemetry"))

local passthroughActive = false

function MainMenuWindow(dt)
        local exclusiveHudMode = ""

        if ac.isKeyPressed(ui.KeyIndex.XButton1) then
                if pages:isUndoAvailable() then pages:undo() end
        end

        if ac.isKeyPressed(ui.KeyIndex.XButton2) then
                if pages:isRedoAvailable() then pages:redo() end
        end

        style:pushStyleMain()
        ui.pushAllowKeyboardFocus(false)

        local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse
        if cui.modalDialogCallback then
                mainWindowFlags = mainWindowFlags
                        + ui.WindowFlags.NoInputs
                        + ui.WindowFlags.NoMouseInputs
                        + ui.WindowFlags.NoFocusOnAppearing
        end

        cui.pushWindowFull("main_window", mainWindowFlags)
        updateCommon()
        exclusiveHudMode = pages.manager:draw()
        cui.popWindow(false)

        if cui.modalDialogCallback then
                cui.pushWindowFull("callback_window")
                ui.setCursor(0)
                ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.Appearance.uiColor1 / 1.2)
                local childWindowWith = ui.windowWidth() / 5
                local childWindowHeight = ui.windowHeight() / 5
                cui.pushWindow(
                        "callback_subwindow",
                        (ui.windowWidth() - childWindowWith) / 2,
                        (ui.windowHeight() - childWindowHeight) / 2,
                        childWindowWith,
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

        if ui.mouseClicked(ui.MouseButton.Left) then passthroughActive = ui.getHoveredID() == 0 end
        if ui.mouseReleased(ui.MouseButton.Left) then passthroughActive = false end

        ui.setCursor(0)
        ui.childWindow("##Panner", vec2(10, 10), false, ui.WindowFlags.None, function()
                if passthroughActive then ui.passthroughIMGUI() end

                ui.drawRectFilled(vec2(0, 0), ui.windowSize(), rgbm.colors.transparent)
        end)

        return app.state.debug and "debug" or exclusiveHudMode
end
