require("ui.windows.main_menu_window")
require("ui.windows.pause_window")
require("ui.windows.pitstop_window")
require("ui.windows.results_window")
require("ui.windows.settings_window")
require("ui.windows.onboarding_window")
require("ui.windows.ui_test_window")
local app = require("app")
local audio = require("audio")
local camera = require("camera")
local csp = require("csp")
local cui = require("src.ui.cui")
local pages = require("ui.pages.pages")
local settings = require("settings")
local style = require("style")

local fadingTimer = ui.FadingElement(function()
        cui.pushWindowFull("overlay_window_full")
        ui.drawRectFilled(0, ui.windowSize(), rgbm.colors.black)
        cui.popWindow()
end)

local hudModes = {
        game = function(dt) pages:setParentMainMenu() end,
        menu = function(dt)
                if not settings.AppData.shownOnboarding then return OnboardingWindow(dt) end

                if not settings.Modules.newMainMenu then return end

                if pages.manager.currentPageName and string.find(pages.manager.currentPageName, "Setting") then
                        return SettingsWindow(dt)
                end

                ui.forceSimplifiedComposition()
                pages:setParentMainMenu()

                return MainMenuWindow(dt)
        end,
        pause = function(dt)
                if not settings.Modules.newPauseMenu and csp.versionAllowed then return end

                if pages.manager.currentPageName and string.find(pages.manager.currentPageName, "Setting") then
                        return SettingsWindow(dt)
                end

                pages:setParentPauseMenu()

                return PauseMenuWindow()
        end,
        replay = function(dt)
                if not settings.Modules.newPauseMenu and csp.versionAllowed then return end

                return
        end,
        results = function(dt)
                if not settings.Modules.newResultsMenu then return end

                pages:setParentResultsMenu()
                return ResultsMenuWindow()
        end,
}

ui.onExclusiveHUD(function(mode)
        if true then
                style:pushStyleMain()
                testUI()
                style:popStyleMain()
                return ""
        end

        if ac.getLastError() or not app.state.appOpen then return end

        -- pages:goToSession()
        -- pages:goToLapTimes()
        -- pages:goToSetup()
        -- pages:goToSettingsControls()
        -- pages:goToSettingsGeneral()
        -- pages:goToSettingsAudio()
        -- pages:goToSettingsView()
        -- pages:goToTelemetry()
        -- pages:goToSettings()

        camera.windowHovered = ui.getHoveredID() ~= 0

        local hudReturn = ""
        for hud, hudMode in pairs(hudModes) do
                if mode == hud then
                        local dt = ac.getScriptDeltaT()
                        audio:driver(dt)
                        hudReturn = hudMode(dt)
                end
        end

        fadingTimer(os.clock() < app.state.screenTransition)

        return hudReturn
end)
