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
-- storage.page = MenuPages.Home
storage.settingsTab = 1

-- storage.page = MenuPages.Home

settings = ac.storage({
	autoStart = true,
	showVersions = true,
	hideOtherTrackSetups = true,
	uiHideonIdleTime = 150,
	uiColor1 = rgbm.new("#3e3c46"),
	uiColor2 = rgbm(0.74, 0, 0, 1),
	uiColor3 = rgbm(1, 1, 1, 1),
})

for v, v in pairs(settings) do
	for _k, _v in pairs(v) do
		settings[_k] = _v.default
	end
end

storage.appOpen = settings.autoStart
storage.hasAppOpened = false

package.add("src")
cui = require("utils\\utils_cui")
require("classes\\button")
require("utils\\utils_scale")
require("ui\\styles")
require("ui\\main")
require("ui\\audio")

ac.setWindowOpen("main", true)

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
end

local uic = ac.getUI()

function script.update(dt)
	if sim.isInMainMenu and settings.autoStart and not storage.hasAppOpened then
		ac.tryToOpenRaceMenu("race")
		ac.tryToOpenRaceMenu("setup")
	end

	if uic.ctrlDown and uic.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
		settings.autoStart = not storage.appOpen
		storage.appOpen = not storage.appOpen
	end
end
