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

package.add("src")
require("ui.main_window")
require("ui.pause.pause_window")
require("audio")
local settings = require("settings")
local state = require("state")
local audio = require("audio")

state.appOpen = settings.autoStart
state.hasAppOpened = false
state.appOpen = true

ac.setWindowOpen("main", true)
ui.onExclusiveHUD(function(mode)
	if not state.appOpen then
		return
	end

	local dt = ac.getScriptDeltaT()

	if mode == "menu" then
		audio:driver(dt)

		return MainMenuWindow(dt)
	end

	if mode == "pause" then
		audio:driver(dt)

		return PauseMenuWindow()
	end
end)

ac.setWindowOpen("main", true)

local windowTimeSync = 0

function script.main()
	if not state.hasAppOpened then
		state.hasAppOpened = true
		ac.setMousePosition(ui.cursorScreenPos())
	end

	windowTimeSync = os.clock()
end

local uic = ac.getUI()
local sim = ac.getSim()

local isInMainMenu = false

teleportPitsCallback = nil
function script.update(dt)
	-- for i in ipairs(settings.General) do
	-- 	print(settings.General[i])
	-- end

	if teleportPitsCallback then
		if teleportPitsCallback() then
			teleportPitsCallback = nil
		end
	end

	if sim.isInMainMenu and settings.autoStart and windowTimeSync < os.clock() - 1 then
		ac.tryToOpenRaceMenu("race")
		ac.tryToOpenRaceMenu("setup")
	end

	if uic.ctrlDown and uic.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
		settings.autoStart = not state.appOpen
		state.appOpen = not state.appOpen
	end

	if not state.appOpen then
		return
	end

	local redirectVM = (sim.isInMainMenu and ac.isWindowOpen("main")) or sim.isPaused
	ac.redirectVirtualMirror(redirectVM)

	if not sm then
		return
	end

	if isInMainMenu and not sim.isInMainMenu then
		sm:applyPitstopStrategy()
	end

	isInMainMenu = sim.isInMainMenu
end
