require("classes.PageManager")
require("ui.common")
local app = require("app")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")
local style = require("src.ui.style")
local sim = ac.getSim()

pages.manager:registerPage("EmptyPage", require("ui.pages.empty.page_empty"))
pages.manager:registerPage("SessionPage", require("ui.pages.session.page_session"))
pages.manager:registerPage("SetupPage", require("ui.pages.setup.page_setup"))
pages.manager:registerPage("LapTimesPage", require("ui.pages.lap_times.page_lap_times"))
pages.manager:registerPage("SettingsPage", require("ui.pages.settings.page_settings"))
pages.manager:registerPage("SettingsGeneralPage", require("ui.pages.settings.page_general"))
pages.manager:registerPage("SettingsControlsPage", require("ui.pages.settings.page_controls"))
pages.manager:registerPage("SettingsAudioPage", require("ui.pages.settings.page_audio"))
pages.manager:registerPage("SettingsViewPage", require("ui.pages.settings.page_view"))
pages.manager:registerPage("SettingsAppearancePage", require("ui.pages.settings.page_appearance"))
pages.manager:registerPage("SettingsAiPage", require("ui.pages.settings.page_ai"))
pages.manager:registerPage("TelemetryPage", require("ui.pages.telemetry.page_telemetry"))

function MainMenuWindow(dt)
        local exclusiveHudMode = ""

        style:pushStyleMain()
        ui.pushAllowKeyboardFocus(false)

        local mainWindowFlags = bit.bor(ui.WindowFlags.NoScrollbar, ui.WindowFlags.NoScrollWithMouse)
        if cui.modalDialogCallback then
                mainWindowFlags = bit.bor(
                        mainWindowFlags,
                        ui.WindowFlags.NoInputs,
                        ui.WindowFlags.NoMouseInputs,
                        ui.WindowFlags.NoFocusOnAppearing
                )
        end

        updateCommon()

        cui.pushFittedWindow()
        topBar()
        cui.pushWindow(
                "main_menu_window_sub",
                0,
                195 * cui.scale(),
                ui.windowWidth(),
                ui.windowHeight() - 195 * cui.scale()
        )
        exclusiveHudMode = pages.manager:draw()
        cui.popWindow(false)
        cui.popWindow(false)

        if cui.modalDialogCallback then
                exclusiveHudMode = ""
                cui.pushFullWindow("callback_window")
                ui.setCursor(0)
                ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorBackgroundShade * 0.98)
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

        if sim.cameraMode == ac.CameraMode.OnBoardFree or sim.cameraMode == ac.CameraMode.Free then
                if ui.mouseClicked(ui.MouseButton.Left) then cui.menuPanAvailable = ui.getHoveredID() == 0 end
                if ui.mouseReleased(ui.MouseButton.Left) then cui.menuPanAvailable = false end

                cui.menuZoomAvailable = ui.getHoveredID() == 0
        else
                cui.menuZoomAvailable = false
                cui.menuPanAvailable = false
        end

        ui.setCursor(0)
        ui.childWindow("##Panner", vec2(10, 10), false, ui.WindowFlags.None, function()
                if cui.menuPanAvailable then ui.passthroughIMGUI() end
                ui.drawRectFilled(vec2(0, 0), ui.windowSize(), rgbm.colors.transparent)
        end)

        return app.state.debug and "debug" or exclusiveHudMode
end
