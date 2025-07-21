require("ui.windows.pitstop_window")
require("ui.windows.onboarding_window")
require("ui.windows.ui_test_window")
local app = require("app")
local audio = require("audio")
local callback = require("callback")
local camera = require("camera")
local csp = require("csp")
local cui = require("ui.cui")
local pages = require("ui.pages")
local settings = require("settings")
local style = require("ui.cui.style")
local sim = ac.getSim()

pages.manager:registerPage("EmptyPage", require("ui.pages.page_empty"))
pages.manager:registerPage("SessionPage", require("ui.pages.page_session"))
pages.manager:registerPage("SetupPage", require("ui.pages.page_setup"))
pages.manager:registerPage("LapTimesPage", require("ui.pages.page_lap_times"))
pages.manager:registerPage("SettingsPage", require("ui.pages.page_settings"))
pages.manager:registerPage("SettingsGeneralPage", require("ui.pages.page_settings_general"))
pages.manager:registerPage("SettingsControlsPage", require("ui.pages.page_settings_controls"))
pages.manager:registerPage("SettingsAudioPage", require("ui.pages.page_settings_audio"))
pages.manager:registerPage("SettingsViewPage", require("ui.pages.page_settings_view"))
pages.manager:registerPage("SettingsAppearancePage", require("ui.pages.page_settings_appearance"))
-- pages.manager:registerPage("SettingsAiPage", require("ui.pages.settings.page_ai"))
pages.manager:registerPage("TelemetryPage", require("ui.pages.page_telemetry"))
pages.manager:registerPage("PauseMenu", require("ui.pages.page_pause"))
pages.manager:registerPage("ResultsMenu", require("ui.pages.page_results_home"))
pages.manager:registerPage("GamePage", require("ui.pages.page_game"))
pages.manager:registerPage("AboutPage", require("ui.pages.page_about"))

local fadingTimer = ui.FadingElement(function()
        cui.pushFullWindow("overlay_window_full")
        ui.drawRectFilled(0, ui.windowSize(), rgbm.colors.black)
        cui.popWindow()
end)

-- settings.AppData.shownOnboarding = false

local exclusiveHudMode = ""

local hudModes = {
        game = function(dt)
                pages:setParentGameMenu()
                exclusiveHudMode = nil
        end,
        menu = function(dt)
                if not settings.Modules.newMainMenu then return end

                pages:setParentMainMenu()

                ui.forceSimplifiedComposition()
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

                camera:panZoomController()
        end,
        pause = function(dt)
                if not settings.Modules.newPauseMenu and csp.versionAllowed then return end

                pages:setParentPauseMenu()

                local childWindowWith = 2560 * cui.scale()
                local childWindowHeight = 1440 * cui.scale()

                cui.contentWindow(
                        "pause_window",
                        vec2((ui.windowWidth() - childWindowWith) / 2, (ui.windowHeight() - childWindowHeight) / 2),
                        vec2(childWindowWith, childWindowHeight),
                        ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
                        function() exclusiveHudMode = pages.manager:draw() end
                )
        end,
        replay = function(dt)
                if not settings.Modules.newReplayMenu and csp.versionAllowed then return end
        end,
        results = function(dt)
                if not settings.Modules.newResultsMenu then return end

                pages:setParentResultsMenu()
        end,
        settings = function(dt)
                exclusiveHudMode = ""

                updateCommon()

                cui.pushFullWindow(
                        "settings_main_window",
                        ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
                        false
                )
                pages.manager:draw()
                cui.popWindow(false)
        end,
}

ui.onExclusiveHUD(function(mode)
        if ac.getLastError() or not app.state.appOpen then return end
        exclusiveHudMode = nil

        -- if true then
        --         style:pushStyleMain()
        --         testUI()
        --         style:popStyleMain()
        --         return ""
        -- end

        -- pages:goToSession()
        -- pages:goToLapTimes()
        -- pages:goToSetup()
        -- pages:goToSettingsControls()
        -- pages:goToSettingsGeneral()
        -- pages:goToSettingsAudio()
        -- pages:goToSettingsGeneral()
        -- pages:goToSettingsView()
        -- pages:goToTelemetry()
        -- pages:goToSettings()
        -- pages:goToAbout()

        camera.windowHovered = ui.getHoveredID() ~= 0
        style:pushStyleMain()
        ui.pushAllowKeyboardFocus(false)

        if pages.manager.currentPageName and string.find(pages.manager.currentPageName, "Setting") then
                mode = "settings"
        end

        app.state.blockEscapeButton = false

        if callback.update then
                ui.transparentWindow("dialog_window", 0, ui.windowSize(), true, true, function()
                        ui.bringWindowToFront()
                        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), rgbm.colors.black * 0.75)
                        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorPrimary)

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
                        cui.offsetCursorY(-15)
                        ui.dwriteTextAligned(
                                "INSTALLING ACUIR UPDATE...",
                                30,
                                0,
                                ui.Alignment.End,
                                vec2(ui.windowWidth(), ui.windowHeight() * 0.5)
                        )
                        cui.offsetCursorY(30)

                        ui.setCursorX(ui.windowWidth() * 0.5 - 100 * cui.scale() * 0.5)
                        ui.icon(ui.Icons.LoadingSpinner, vec2(100, 100) * cui.scale())

                        cui.popWindow()
                end)
        elseif not settings.AppData.shownOnboarding then
                exclusiveHudMode = OnboardingWindow()
        elseif callback.dialog then
                if mode == "settings" then app.state.blockEscapeButton = true end

                ui.transparentWindow("dialog_window", 0, ui.windowSize(), true, true, function()
                        ui.bringWindowToFront()
                        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), rgbm.colors.black * 0.75)
                        ui.drawRectFilled(vec2(0, 0), ui.windowSize(), settings.Appearance.uiColorPrimary)

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
                        if callback.dialog() then callback.dialog = nil end
                        cui.popWindow()
                end)

                exclusiveHudMode = ""
        else
                for hud, hudMode in pairs(hudModes) do
                        if mode == hud then
                                local dt = ac.getScriptDeltaT()
                                audio:driver(dt)
                                hudMode(dt)
                        end
                end
        end

        style:popStyleMain()
        ui.popAllowKeyboardFocus()

        fadingTimer(os.clock() < app.state.screenTransition)

        if app.state.debug and sim.isInMainMenu then exclusiveHudMode = "debug" end

        return exclusiveHudMode
end)
