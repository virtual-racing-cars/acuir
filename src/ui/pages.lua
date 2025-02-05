local pages = {}

pages.mainMenuPM = PageManager()

pages.mainMenu = {}

function pages.mainMenu:isUndoAvailable()
	return pages.mainMenuPM:isUndoAvailable()
end

function pages.mainMenu:isRedoAvailable()
	return pages.mainMenuPM:isRedoAvailable()
end

function pages.mainMenu:goToHome()
	pages.mainMenuPM:setPage("HomePage")
end

function pages.mainMenu:goToSetup()
	pages.mainMenuPM:setPage("SetupPage")
end

function pages.mainMenu:goToSettings()
	pages.mainMenuPM:setPage("SettingsPage")
end

function pages.mainMenu:goToSetupApps()
	pages.mainMenuPM:setPage("SetupAppsPage")
end

function pages.mainMenu:goToSettingsGeneral()
	pages.mainMenuPM:setPage("SettingsGeneralPage")
end

function pages.mainMenu:goToSettingsControls()
	pages.mainMenuPM:setPage("SettingsControlsPage")
end

function pages.mainMenu:goToSettingsAudio()
	pages.mainMenuPM:setPage("SettingsAudioPage")
end

function pages.mainMenu:goToSettingsAppearance()
	pages.mainMenuPM:setPage("SettingsAppearancePage")
end

function pages.mainMenu:goToSettingsAi()
	pages.mainMenuPM:setPage("SettingsAiPage")
end

pages.pausePM = PageManager()

pages.pause = {}

function pages.pause:isUndoAvailable()
	return pages.pausePM:isUndoAvailable()
end

function pages.pause:isRedoAvailable()
	return pages.pausePM:isRedoAvailable()
end

function pages.pause:goToHome()
	pages.pausePM:setPage("HomePage")
end

function pages.pause:goToSettings()
	pages.pausePM:setPage("SettingsPage")
end

function pages.pause:goToSettingsGeneral()
	pages.pausePM:setPage("SettingsGeneralPage")
end

function pages.pause:goToSettingsControls()
	pages.pausePM:setPage("SettingsControlsPage")
end

function pages.pause:goToSettingsAudio()
	pages.pausePM:setPage("SettingsAudioPage")
end

function pages.pause:goToSettingsAppearance()
	pages.pausePM:setPage("SettingsAppearancePage")
end

function pages.pause:goToSettingsAi()
	pages.pausePM:setPage("SettingsAiPage")
end

return pages
