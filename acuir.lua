-- if true then
-- 	return
-- end
local sim = ac.getSim()

UI_SCALE_X = sim.windowWidth / 2560 * 100
UI_SCALE_Y = sim.windowHeight / 1440 * 100

MenuPages = {
	Home = 0,
	Setup = 1,
	Replay = 2,
	Settings = 3,
	Manual = 4,
}

storage = ac.storage({
	appOpen = false,
	hasAppOpened = false,
	setupTab = "SETUP I/O",
	settingsTab = 1,
	helpOpen = false,
	page = MenuPages.Home,
})

-- storage.setupTab = "SETUP I/O"
storage.settingsTab = 1

-- storage.page = MenuPages.Home

settings = ac.storage({
	autoStart = true,
	showVersions = true,
	autoLoadLastSetup = true,
	hideOtherTrackSetups = true,
	uiHideonIdleTime = 150,
	uiPrimaryColor = rgbm(0, 0, 0, 0.75),
	uiSecondaryColor = rgbm(0.74, 0, 0, 1),
})

storage.appOpen = settings.autoStart
storage.hasAppOpened = false

package.add("src")
cui = require("utils\\utils_cui")
require("init")
require("classes\\button")
require("utils\\utils_scale")
require("ui\\styles")
require("ui\\main")
require("ui\\audio")

ui.onExclusiveHUD(function(mode)
	if not storage.appOpen then
		return
	end

	if mode == "menu" then
		return MainWindow(sim)
	end
end)

ac.setWindowOpen("main", true)

function script.main()
	if not storage.hasAppOpened then
		storage.hasAppOpened = true
	end

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

function script.update(dt)
	if sim.isInMainMenu and settings.autoStart and not storage.hasAppOpened then
		ac.tryToOpenRaceMenu("race")
		ac.tryToOpenRaceMenu("setup")
	end
end
