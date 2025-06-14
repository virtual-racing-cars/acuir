require("ui.windows.main_menu_window")
require("ui.windows.pause_window")
require("ui.windows.pitstop_window")
require("ui.windows.results_window")
require("ui.windows.settings_window")
local app = require("app")
local audio = require("audio")
local camera = require("camera")
local pages = require("ui.pages.pages")

local hudModes = {
        game = function(dt) pages:setParentMainMenu() end,
        menu = function(dt)
                if pages.manager.currentPageName and string.find(pages.manager.currentPageName, "Setting") then
                        return SettingsWindow(dt)
                end

                ui.forceSimplifiedComposition()
                pages:setParentMainMenu()

                return MainMenuWindow(dt)
        end,
        pause = function(dt)
                if pages.manager.currentPageName and string.find(pages.manager.currentPageName, "Setting") then
                        return SettingsWindow(dt)
                end

                pages:setParentPauseMenu()

                return PauseMenuWindow()
        end,
        results = function(dt)
                pages:setParentResultsMenu()
                return ResultsMenuWindow()
        end,
}

ui.onExclusiveHUD(function(mode)
        if not app.state.appOpen then return end

        -- pages:goToSession()
        -- pages:goToLapTimes()
        -- pages:goToSetup()
        -- pages:goToSettingsControls()
        -- pages:goToSettingsGeneral()
        -- pages:goToSettingsAudio()
        -- pages:goToSettingsView()

        camera.windowHovered = ui.getHoveredID() ~= 0

        for hud, hudMode in pairs(hudModes) do
                if mode == hud then
                        local dt = ac.getScriptDeltaT()

                        audio:driver(dt)

                        return hudMode(dt)
                end
        end
end)
