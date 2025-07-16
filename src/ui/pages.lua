local settings = require("settings")

local pages = {}

pages.manager = PageManager()

function pages:isUndoAvailable() return pages.manager:isUndoAvailable() end

function pages:undo()
        if pages:isUndoAvailable() then pages.manager:undo() end
end

function pages:isRedoAvailable() return pages.manager:isRedoAvailable() end

function pages:redo()
        if pages:isRedoAvailable() then pages.manager:redo() end
end

function pages:goToMainMenu() pages.manager:setPage("EmptyPage") end

function pages:setParentMainMenu()
        if pages.manager.parentName ~= "EmptyPage" then
                pages.manager:setParentPageName("EmptyPage")

                if settings.General.defaultSetupPage then
                        pages:goToSetup()
                else
                        pages:goToMainMenu()
                end
        end
end

function pages:goToPauseMenu() pages.manager:setPage("PauseMenu") end

function pages:setParentPauseMenu()
        pages.manager:setParentPageName("PauseMenu")
        pages:goToPauseMenu()
end

function pages:goToResults() pages.manager:setPage("ResultsMenu") end

function pages:setParentResultsMenu()
        pages.manager:setParentPageName("ResultsMenu")
        pages:goToResults()
end

function pages:setParentGameMenu()
        pages.manager:setParentPageName("GameMenu")
        pages:goToGame()
end

function pages:goToParent() pages.manager:setPage(pages.manager.parentName) end

function pages:goToGame() pages.manager:setPage("GamePage") end

function pages:goToSession() pages.manager:setPage("SessionPage") end

function pages:goToSetup() pages.manager:setPage("SetupPage") end

function pages:goToLapTimes() pages.manager:setPage("LapTimesPage") end

function pages:goToSettings() pages.manager:setPage("SettingsPage") end

function pages:goToSettingsGeneral() pages.manager:setPage("SettingsGeneralPage") end

function pages:goToSettingsControls() pages.manager:setPage("SettingsControlsPage") end

function pages:goToSettingsAudio() pages.manager:setPage("SettingsAudioPage") end

function pages:goToSettingsView() pages.manager:setPage("SettingsViewPage") end

function pages:goToSettingsAppearance() pages.manager:setPage("SettingsAppearancePage") end

function pages:goToSettingsAi() pages.manager:setPage("SettingsAiPage") end

function pages:goToTelemetry() pages.manager:setPage("TelemetryPage") end

function pages:goToAbout() pages.manager:setPage("AboutPage") end

return pages
