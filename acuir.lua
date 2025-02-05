package.add("src")
require("ui.main_window")
require("ui.pause.pause_window")
require("audio")
local app = require("app")
local settings = require("settings")
local audio = require("audio")
local csp = require("csp")
local pages = require("ui.pages")

app.state.appOpen = settings.General.autoStart
app.state.hasAppOpened = false
app.state.appOpen = true

ac.setWindowOpen("main", true)

local modeLast = ""
ui.onExclusiveHUD(function(mode)
	if not app.state.appOpen or ac.getLastError() then
		return
	end

	local dt = ac.getScriptDeltaT()

	if mode == "menu" then
		audio:driver(dt)

		if modeLast ~= mode then
			pages.manager:resetUndo(true)
			pages:goToMainMenu()
		end

		modeLast = mode

		return MainMenuWindow(dt)
	end

	if mode == "pause" then
		audio:driver(dt)

		if modeLast ~= mode then
			pages.manager:resetUndo(true)
			pages:goToPauseMenu()
		end

		modeLast = mode

		return PauseMenuWindow()
	end

	if mode == "game" then
		if modeLast ~= mode then
			pages.manager:resetUndo(true)
			pages:goToPauseMenu()
		end
	end

	modeLast = mode
end)

local windowTimeSync = 0
function script.main()
	if not app.state.hasAppOpened then
		app.state.hasAppOpened = true
		ac.setMousePosition(ui.cursorScreenPos())
	end

	windowTimeSync = os.clock()
end

local isInMainMenu = false
teleportPitsCallback = nil
function script.update(dt)
	if teleportPitsCallback then
		if teleportPitsCallback() then
			teleportPitsCallback = nil
		end
	end

	if csp.sim.isInMainMenu and settings.General.autoStart and windowTimeSync < os.clock() - 1 then
		ac.tryToOpenRaceMenu("race")
		ac.tryToOpenRaceMenu("setup")
	end

	if csp.ui.ctrlDown and csp.ui.shiftDown and ui.keyboardButtonPressed(ui.KeyIndex.F5) then
		settings.General.autoStart = not app.state.appOpen
		app.state.appOpen = not app.state.appOpen
	end

	if not app.state.appOpen then
		return
	end

	local redirectVM = (csp.sim.isInMainMenu and ac.isWindowOpen("main")) or csp.sim.isPaused
	ac.redirectVirtualMirror(redirectVM)

	if not sm then
		return
	end

	if isInMainMenu and not csp.sim.isInMainMenu then
		sm:applyPitstopStrategy()
	end

	isInMainMenu = csp.sim.isInMainMenu
end

function script.pause() end
