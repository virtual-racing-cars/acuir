local pages = {}

pages.manager = PageManager()

function pages:isUndoAvailable()
	return pages.manager:isUndoAvailable()
end

function pages:undo()
	if pages:isUndoAvailable() then
		pages.manager:undo()
	end
end

function pages:isRedoAvailable()
	return pages.manager:isRedoAvailable()
end

function pages:redo()
	if pages:isRedoAvailable() then
		pages.manager:redo()
	end
end

function pages:goToMainMenu()
	pages.manager:setPage("MainMenu")
end

function pages:goToPauseMenu()
	pages.manager:setPage("PauseMenu")
end

function pages:goToSetup()
	pages.manager:setPage("SetupPage")
end

function pages:goToSettings()
	pages.manager:setPage("SettingsPage")
end

function pages:goToSetupApps()
	pages.manager:setPage("SetupAppsPage")
end

function pages:goToSettingsGeneral()
	pages.manager:setPage("SettingsGeneralPage")
end

function pages:goToSettingsControls()
	pages.manager:setPage("SettingsControlsPage")
end

function pages:goToSettingsAudio()
	pages.manager:setPage("SettingsAudioPage")
end

function pages:goToSettingsAppearance()
	pages.manager:setPage("SettingsAppearancePage")
end

function pages:goToSettingsAi()
	pages.manager:setPage("SettingsAiPage")
end

return pages
