require("ui.windows.main_menu_window")
require("ui.windows.pause_window")
require("ui.windows.pitstop_window")
require("ui.windows.results_window")
require("ui.windows.settings_window")
require("ui.windows.map_window")
local app = require("app")
local audio = require("audio")
local camera = require("camera")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")

local hudModes = {
        game = function(dt) pages:setParentMainMenu() end,
        menu = function(dt)
                ui.forceSimplifiedComposition()
                pages:setParentMainMenu()

                local voteDetails = ac.getCurrentVoteDetails()
                if voteDetails then
                        if voteDetails.type ~= "unknown" then
                                cui.menuBanner(
                                        string.upper(
                                                string.format(
                                                        "Vote %s %s %s",
                                                        voteDetails.type,
                                                        voteDetails.type == "kick"
                                                                        and ac.getDriverName(voteDetails.targetIndex)
                                                                or "Session",
                                                        voteDetails.voted and "" or "Yes [Y] No [N]"
                                                )
                                        ),
                                        voteDetails.timeLeft,
                                        rgbm.colors.red,
                                        true,
                                        "vote"
                                )
                        end
                end

                return MainMenuWindow(dt)
        end,
        pause = function(dt)
                pages:setParentPauseMenu()
                return PauseMenuWindow()
        end,
        results = function(dt)
                pages:setParentResultsMenu()
                return ResultsMenuWindow()
        end,
}

ui.onExclusiveHUD(function(mode)
        if not app.state.appOpen or ac.getLastError() then return end

        pages:goToSession()
        -- pages:goToSetup()

        camera.windowHovered = ui.getHoveredID() ~= 0

        for hud, hudMode in pairs(hudModes) do
                if mode == hud then
                        local dt = ac.getScriptDeltaT()

                        audio:driver(dt)

                        if pages.manager.currentPageName and string.find(pages.manager.currentPageName, "Setting") then
                                SettingsWindow(dt)
                                return ""
                        end

                        return hudMode(dt)
                end
        end
end)
