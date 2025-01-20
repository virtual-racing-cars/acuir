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
		label = "SETUP PRESETS",
		enabled = true,
		func = function()
			storage.setupTab = "SETUP I/O"
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

function SetupPage(sim)
	if storage.setupTab == "SETUP I/O" then
		if ui.keyboardButtonPressed(ui.KeyIndex.Escape) then
			storage.setupTab = "Tyres"
		end
		topSubBar("/Vehicle Setup Presets")
		ioTab()

		return
	end

	topBar(false)

	SetupWindow(sm)
	HelpWindow()

	bottomBarButtons[#bottomBarButtons - 1].enabled = sm:isUndoAvailable()
	bottomBarButtons[#bottomBarButtons].enabled = sm:isRedoAvailable()

	bottomBar(bottomBarButtons)
end
