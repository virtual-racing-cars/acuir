STORAGE = ac.storage({
	appOpen = false,
	hasAppOpened = false,
	setupTab = "SETUP I/O",
	helpOpen = false,
})

SETTINGS = ac.storage({
	autoStart = true,
	showVersions = true,
	hideOtherTrackSetups = true,
	uiHideonIdleTime = 150,
	uiColor1 = rgbm.new("#3e3c46"),
	uiColor2 = rgbm(1, 0, 0, 1),
	uiColor3 = rgbm(1, 1, 1, 1),
})

-- for v, v in pairs(SETTINGS) do
-- 	for _k, _v in pairs(v) do
-- 		SETTINGS[_k] = _v.default
-- 	end
-- end

STORAGE.appOpen = SETTINGS.autoStart
STORAGE.hasAppOpened = false

package.add("src")
cui = require("ui.cui")
require("ui.main")
require("ui.audio")

ac.setWindowOpen("main", true)
ui.onExclusiveHUD(function(mode)
	if not STORAGE.appOpen then
		return
	end

	local dt = ac.getScriptDeltaT()

	if mode == "menu" then
		return MainMenuWindow(dt)
	end
end)

ac.setWindowOpen("main", true)
function script.main()
	if not STORAGE.hasAppOpened then
		STORAGE.hasAppOpened = true
	end
end

local uic = ac.getUI()
local sim = ac.getSim()

function script.update(dt)
	if sim.isInMainMenu and SETTINGS.autoStart and not STORAGE.hasAppOpened then
		ac.tryToOpenRaceMenu("race")
		ac.tryToOpenRaceMenu("setup")
	end

	if uic.ctrlDown and uic.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
		SETTINGS.autoStart = not STORAGE.appOpen
		STORAGE.appOpen = not STORAGE.appOpen
	end

	ac.redirectVirtualMirror(sim.isInMainMenu and ac.isWindowOpen("main"))
end
