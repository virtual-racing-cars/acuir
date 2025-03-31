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

function pages:goToMainMenu() pages.manager:setPage("MainMenu") end

function pages:setParentMainMenu()
        pages.manager:setParentPageName("MainMenu")
        pages:goToMainMenu()
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

function pages:goToParent() pages.manager:setPage(pages.manager.parentName) end

function pages:goToSetup() pages.manager:setPage("SetupPage") end

function pages:goToSettings() pages.manager:setPage("SettingsPage") end

function pages:goToSetupApps() pages.manager:setPage("SetupAppsPage") end

function pages:goToSettingsGeneral() pages.manager:setPage("SettingsGeneralPage") end

function pages:goToSettingsControls() pages.manager:setPage("SettingsControlsPage") end

function pages:goToSettingsAudio() pages.manager:setPage("SettingsAudioPage") end

function pages:goToSettingsAppearance() pages.manager:setPage("SettingsAppearancePage") end

function pages:goToSettingsAi() pages.manager:setPage("SettingsAiPage") end

function pages:goToTelemetry() pages.manager:setPage("TelemetryPage") end

return pages
