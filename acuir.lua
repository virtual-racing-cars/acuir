STORAGE = ac.storage({
	appOpen = false,
	hasAppOpened = false,
	setupTab = 1,
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
require("ui.main_window")
require("ui.pause.pause_window")
require("ui.audio")

require("classes.SetupManager")
sm = SetupManager()

ac.setWindowOpen("main", true)
ui.onExclusiveHUD(function(mode)
	if not STORAGE.appOpen then
		return
	end

	local dt = ac.getScriptDeltaT()

	if mode == "menu" then
		return MainMenuWindow(dt)
	end

	if mode == "pause" then
		return PauseMenuWindow()
	end
end)

ac.setWindowOpen("main", true)

local windowTimeSync = 0

function script.main()
	if not STORAGE.hasAppOpened then
		STORAGE.hasAppOpened = true
		ac.setMousePosition(ui.cursorScreenPos())
	end

	windowTimeSync = os.clock()
end

local uic = ac.getUI()
local sim = ac.getSim()

local tempSpFile = ac.INIConfig.load(ac.getFolder(ac.FolderID.UserSetups) .. "\\" .. ac.getCarID(0) .. "\\_temp.sp")
tempSpFile:setAndSave("PRESET_0", "COMPOUND", -1)

local isInMainMenu = false

function script.update(dt)
	if sim.isInMainMenu and SETTINGS.autoStart and windowTimeSync < os.clock() - 1 then
		ac.tryToOpenRaceMenu("race")
		ac.tryToOpenRaceMenu("setup")
	end

	if uic.ctrlDown and uic.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
		SETTINGS.autoStart = not STORAGE.appOpen
		STORAGE.appOpen = not STORAGE.appOpen
	end

	if not STORAGE.appOpen then
		return
	end

	local redirectVM = (sim.isInMainMenu and ac.isWindowOpen("main")) or sim.isPaused
	ac.redirectVirtualMirror(redirectVM)

	if isInMainMenu and not sim.isInMainMenu then
		sm:applyPitstopStrategy()
	end

	isInMainMenu = sim.isInMainMenu
end
