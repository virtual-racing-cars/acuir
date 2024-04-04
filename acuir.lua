local sim = ac.getSim()

UI_SCALE_X = sim.windowWidth / 2560 * 100
UI_SCALE_Y = sim.windowHeight / 1440 * 100

MenuPages = {
	Setup = 0,
	Notes = 1,
	TimeTable = 2,
	Apps = 3,
	Manual = 4,
	Settings = 5,
}

MenuPagesString = {
	[-1] = "",
	[0] = "Setup",
	[1] = "Notes",
	[2] = "Time Table",
	[3] = "Apps",
	[4] = "Manual",
	[5] = "Settings",
}

storage = ac.storage({
	appOpen = false,
	hasAppOpened = false,
	setupTab = "SETUP I/O",
	settingsTab = "GENERAL",
	page = MenuPages.Setup,
})

-- storage.setupTab = "SETUP I/O"
storage.settingsTab = "GENERAL"

settings = ac.storage({
	autoStart = true,
	showVersions = true,
	autoLoadLastSetup = true,
	hideOtherTrackSetups = true,
	uiHideonIdle = true,
	uiPrimaryColor = rgbm(0.1, 0.1, 0.1, 0.75),
	uiSecondaryColor = rgbm(1, 0, 0, 1),
})

storage.appOpen = false
storage.hasAppOpened = false

package.add("src")
require("init")
require("classes\\button")
require("utils\\utils_scale")
require("ui\\styles")
require("ui\\main\\main_window")

ui.onExclusiveHUD(function(mode)
	if mode == "menu" then
		return MainWindow(sim)
	end
end)

function script.update(dt)
	if
		sim.isInMainMenu
		and settings.autoStart
		and not storage.hasAppOpened
		and not storage.appOpen
		and ac.isWindowOpen("main")
	then
		ac.tryToOpenRaceMenu("race")
		ac.tryToOpenRaceMenu("setup")
		storage.appOpen = settings.autoStart
	end
end

function script.main()
	setCursorX(0)
	setCursorY(0)

	if
		ui.modernButtonAdvanced(
			storage.appOpen and "Deactivate Advanced Setup" or "Activate Advanced Setup",
			vec2(300, 50),
			ui.ButtonFlags.None
		)
	then
		storage.appOpen = not storage.appOpen
	end
end
