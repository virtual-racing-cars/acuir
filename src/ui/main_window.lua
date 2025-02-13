require("ui.common")
require("classes.PageManager")
local app = require("app")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")
local style = require("style")

pages.manager:registerPage("MainMenu", require("ui.home.page"))
pages.manager:registerPage("SetupPage", require("ui.setup.page_setup"))
pages.manager:registerPage("SettingsPage", require("ui.SETTINGS.page_settings"))
pages.manager:registerPage("SetupAppsPage", require("ui.setup.page_apps"))
pages.manager:registerPage("SettingsGeneralPage", require("ui.SETTINGS.page_general"))
pages.manager:registerPage("SettingsControlsPage", require("ui.SETTINGS.page_controls"))
pages.manager:registerPage("SettingsAudioPage", require("ui.SETTINGS.page_audio"))
pages.manager:registerPage("SettingsAppearancePage", require("ui.SETTINGS.page_appearance"))
pages.manager:registerPage("SettingsAiPage", require("ui.SETTINGS.page_ai"))

local exclusiveHudMode = ""

function MainMenuWindow(dt)
        local perfTime = os.preciseClock()

        ui.pushAllowKeyboardFocus(false)
        exclusiveHudMode = ""

        if ac.isKeyPressed(ui.KeyIndex.XButton1) then
                if pages:isUndoAvailable() then pages:undo() end
        end

        if ac.isKeyPressed(ui.KeyIndex.XButton2) then
                if pages:isRedoAvailable() then pages:redo() end
        end

        style:pushStyleMain()

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

        ac.debug("perfTime", (os.preciseClock() - perfTime) * 1000)

        return app.state.debug and "debug" or exclusiveHudMode
end
