require("src.ui.setup.setup_window")

local menuButtonList = {
	{
		label = "DRIVE",
		enabled = true,
		func = function()
			ac.tryToStart()
		end,
	},
	{
		label = "VEHICLE SETUP",
		enabled = true,
		func = function()
			storage.page = MenuPages.Setup
		end,
	},
	{
		label = "REPLAY",
		enabled = false,
		func = function()
			storage.page = MenuPages.Replay
			ac.tryToToggleReplay(true)
		end,
	},
	{
		label = "SETTINGS",
		enabled = true,
		func = function()
			storage.page = MenuPages.Settings
		end,
	},
	{
		label = "RESTART SESSION",
		enabled = true,
		func = function()
			ac.tryToRestartSession()
		end,
	},
}

function HomePage(sim)
	topBar(true)
	homeBar(menuButtonList)

	bottomBar({
		{
			label = "QUIT",
			enabled = true,
			func = function()
				ac.shutdownAssettoCorsa()
			end,
		},
	})
end
