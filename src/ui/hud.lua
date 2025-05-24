require("ui.windows.main_menu_window")
require("ui.windows.pause_window")
require("ui.windows.pitstop_window")
require("ui.windows.results_window")
require("ui.windows.settings_window")
local app = require("app")
local audio = require("audio")
local cui = require("ui.cui")
local pages = require("ui.pages.pages")

local modeLast = ""

ui.onExclusiveHUD(function(mode)
        if not app.state.appOpen or ac.getLastError() then return end

        local dt = ac.getScriptDeltaT()

        if pages.manager.currentPageName and string.find(pages.manager.currentPageName, "Setting") then
                SettingsWindow(dt)
                return ""
        end

        if mode == "menu" then
                ui.forceSimplifiedComposition()

                -- pages:goToSetup()
                -- pages:goToSettings()
                -- pages:goToSettingsGeneral()
                -- pages:goToSession()

                audio:driver(dt)

                if modeLast ~= mode then pages:setParentMainMenu() end

                modeLast = mode

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
        end

        -- if mode == "replay" then
        --         audio:driver(dt)

        --         if modeLast ~= mode then pages:setParentMainMenu() end

        --         modeLast = mode

        --         return MainMenuWindow(dt)
        -- end

        if mode == "results" then
                audio:driver(dt)

                if modeLast ~= mode then pages:setParentResultsMenu() end
                modeLast = mode

                return ResultsMenuWindow()
        end

        if mode == "pause" then
                audio:driver(dt)

                if modeLast ~= mode then pages:setParentPauseMenu() end
                modeLast = mode

                return PauseMenuWindow()
        end

        if mode == "game" then
                if modeLast ~= mode then pages:setParentMainMenu() end
        end

        modeLast = mode
end)
