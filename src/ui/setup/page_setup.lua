local page = {}

require("classes.SetupManager")
require("ui.setup.setup_window")
require("ui.setup.car_status_window")

local sim = ac.getSim()
local sm = SetupManager()

local bottomBarButtons = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			goToHomePage()
		end,
	},
	{
		label = "APPS",
		enabled = false,
		func = function()
			goToSetupAppsPage()
			STORAGE.setupTab = "SETUP I/O"
		end,
	},
	{
		label = "SETUP PRESETS",
		enabled = true,
		func = function()
			goToSetupIoPage()
			STORAGE.setupTab = "SETUP I/O"
		end,
	},
	{
		label = "RESET",
		enabled = false,
		func = function()
			ac.resetSetupToDefault("")
		end,
	},
	{
		label = "UNDO",
		enabled = true,
		func = function()
			sm:undo()
		end,
	},
	{
		label = "REDO",
		enabled = true,
		func = function()
			sm:redo()
		end,
	},
}

function page.draw()
	topBar(false)

	cui.contentWindow(
		"car_setup_window",
		STORAGE.setupTab,
		vec2(60 * cui.scaleX(), 240 * cui.scaleY()),
		vec2(sim.windowWidth - 120 * cui.scaleX(), sim.windowHeight - 383 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			-- ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm.colors.aqua)
			STORAGE.setupTab = setupTabBar(sm.setupTabs)

			cui.contentWindow(
				"car_setup_window2",
				STORAGE.setupTab .. "2",
				vec2(ui.windowWidth() / 4, 56 * cui.scaleY()),
				vec2(ui.windowWidth() / 2, ui.availableSpaceY()),
				ui.WindowFlags.None,
				function()
					-- ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm.colors.aqua)
					ui.setCursor(0)
					car_setup(sm)
				end,
				false,
				true
			)

			ui.setCursor(0)
			cui.contentWindow(
				"help_window42",
				STORAGE.setupTab .. "42",
				vec2((ui.windowWidth() / 4) * 3, 56 * cui.scaleY()),
				vec2(ui.windowWidth() / 4, ui.availableSpaceY()),
				ui.WindowFlags.None,
				function()
					ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm(0, 0, 0, 0.25))
					ui.setCursor(0)

					-- if HELP_TEXT ~= "NULL" and HELP_TEXT ~= "" then
					-- 	ui.dummy(vec2(230 * cui.scaleY(), 0))
					-- 	-- ui.bringWindowToFront()
					-- 	local helpSections = string.split(HELP_TEXT, "\\n\\n")

					-- 	for i in ipairs(helpSections) do
					-- 		cui.dwriteTextWrapped(helpSections[i], 24)
					-- 	end
					-- end

					HELP_TEXT = ""
				end,
				false,
				true
			)

			ui.setCursor(0)
			cui.contentWindow(
				"help_window432",
				STORAGE.setupTab .. "423",
				vec2(0, 56 * cui.scaleY()),
				vec2(ui.windowWidth() / 4, ui.availableSpaceY()),
				ui.WindowFlags.None,
				function()
					ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm(0, 0, 0, 0.25))
					CarStatusWindow()
				end,
				false,
				true
			)
		end
	)

	bottomBarButtons[#bottomBarButtons - 1].enabled = sm:isUndoAvailable()
	bottomBarButtons[#bottomBarButtons].enabled = sm:isRedoAvailable()

	bottomBar(bottomBarButtons)

	if ui.keyboardButtonPressed(ui.KeyIndex.Escape) then
		goToHomePage()
	end

	return "debug"
end

return page
