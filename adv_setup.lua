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
	setupTab = "AERO",
	settingsTab = "APP SETTINGS",
	page = MenuPages.Setup,
})

settings = ac.storage({
	autoStart = false,
	showVersions = true,
	autoLoadLastSetup = true,
	hideOtherTrackSetups = true,
	uiHideonIdle = true,
	uiPrimaryColor = rgbm(0.1, 0.1, 0.1, 0.65),
	uiSecondaryColor = rgbm(1, 0, 0, 1),
})

ac.store("adv_setup_trigger", 0)
ac.store("adv_setup_open", 0)

package.add("src")
require("init")
require("classes\\button")
require("utils\\utils_scale")
require("ui\\styles")
require("ui\\main\\main_window")

local stateToggle = false

local timer = os.clock() + 60

ui.onExclusiveHUD(function(mode)
	if ac.isKeyDown(ui.KeyIndex.LeftControl) and ac.isKeyDown(ui.KeyIndex.LeftShift) then
		if not stateToggle then
			local state = ac.load("adv_setup_open")
			ac.store("adv_setup_open", state == 1 and 0 or 1)
			stateToggle = true
		end
	else
		stateToggle = false
	end

	if
		ac.load("adv_setup_trigger") == 0
		and ac.load("adv_setup_open") == 0
		and sim.isInMainMenu
		and not sim.isWindowForeground
		and settings.autoStart
	then
		ui.drawRectFilled(vec2(0, 0), vec2(sim.windowWidth, sim.windowHeight), rgbm.colors.black)
		ui.dwriteTextAligned(
			"CLICK OR DIE",
			200,
			ui.Alignment.Center,
			ui.Alignment.Center,
			vec2(sim.windowWidth, sim.windowHeight)
		)
	end

	if mode == "menu" and ac.load("adv_setup_open") == 1 then
		if settings.uiHideonIdle then
			if ui.mouseDelta() ~= vec2(0, 0) and sim.isWindowForeground then
				timer = os.clock() + 60
			end

			if timer < os.clock() then
				ac.setCurrentCamera(ac.CameraMode.Start)
				return ""
			end
		end

		MainWindow(sim)

		return "debug"
	end
end)

function script.update(dt)
	if ac.load("adv_setup_trigger") == 0 and sim.isInMainMenu and sim.isWindowForeground and settings.autoStart then
		ac.setMousePosition(vec2(50, 270))

		ac.setMouseLeftButtonDown(true)
	end
end

function script.main()
	if ac.load("adv_setup_trigger") == 0 and ac.load("adv_setup_open") == 0 then
		if settings.autoStart then
			ac.store("adv_setup_open", 1)
			stateToggle = true
		end

		ac.store("adv_setup_trigger", 1)
	end

	setCursorX(0)
	setCursorY(0)

	if
		ui.modernButtonAdvanced(
			ac.load("adv_setup_open") == 0 and "Activate Advanced Setup" or "Deactivate Advanced Setup",
			vec2(300, 50),
			ui.ButtonFlags.None
		)
	then
		local state = ac.load("adv_setup_open")
		ac.store("adv_setup_open", state == 1 and 0 or 1)
		stateToggle = true
	end
end
