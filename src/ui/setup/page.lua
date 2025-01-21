local sim = ac.getSim()

require("src\\ui\\setup\\setup_window")
require("src\\ui\\setup\\help_window")
require("src\\ui\\setup\\car_status_window")

local sm = SetupMgr()

local bottomBarButtons = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			storage.page = MenuPages.Home
		end,
	},
	{
		label = "APPS",
		enabled = false,
		func = function()
			storage.setupTab = "SETUP I/O"
		end,
	},
	{
		label = "SETUP PRESETS",
		enabled = true,
		func = function()
			storage.setupTab = "SETUP I/O"
		end,
	},
	{
		label = "RESET",
		enabled = true,
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

function SetupPage()
	if storage.setupTab == "SETUP I/O" then
		if ui.keyboardButtonPressed(ui.KeyIndex.Escape) then
			storage.setupTab = "Tyres"
		end
		topSubBar("/Vehicle Setup Presets")
		ioTab()

		return
	end

	topBar(false)

	contentWindow(
		"car_setup_window",
		storage.setupTab,
		vec2(60 * cui.scaleX(), 240 * cui.scaleY()),
		vec2(sim.windowWidth - 120 * cui.scaleX(), sim.windowHeight - 383 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			-- ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm.colors.aqua)
			storage.setupTab = setupTabBar(sm.setupTabs)

			contentWindow(
				"car_setup_window2",
				storage.setupTab .. "2",
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
			contentWindow(
				"help_window42",
				storage.setupTab .. "42",
				vec2((ui.windowWidth() / 4) * 3, 56 * cui.scaleY()),
				vec2(ui.windowWidth() / 4, ui.availableSpaceY()),
				ui.WindowFlags.None,
				function()
					ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm(0, 0, 0, 0.25))
					ui.setCursor(0)

					if HELP_TEXT ~= "NULL" and HELP_TEXT ~= "" then
						ui.dummy(vec2(230 * cui.scaleY(), 0))
						-- ui.bringWindowToFront()
						local helpSections = string.split(HELP_TEXT, "\\n\\n")

						for i in ipairs(helpSections) do
							cui.dwriteTextWrapped(helpSections[i], 24)
						end
					end

					HELP_TEXT = ""
				end,
				false,
				true
			)

			ui.setCursor(0)
			contentWindow(
				"help_window432",
				storage.setupTab .. "423",
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
end
