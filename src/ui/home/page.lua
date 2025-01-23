local page = {}

local sim = ac.getSim()

require("src.ui.home.map")
require("src.classes.PlayerListButton")

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
			goToSetupPage()
		end,
	},
	{
		label = "TIME TABLE",
		enabled = false,
		func = function() end,
	},
	{
		label = "REPLAY",
		enabled = false,
		func = function()
			ac.tryToToggleReplay(true)
		end,
	},
	{
		label = "SETTINGS",
		enabled = true,
		func = function()
			goToSettingsPage()
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

function page.update() end

function page.draw()
	topBar(true)
	homeBar(menuButtonList)

	cui.contentWindow(
		"car_setup_window",
		STORAGE.setupTab,
		vec2(60 * cui.scaleX(), 316 * cui.scaleY()),
		vec2(650 * cui.scaleX(), sim.windowHeight - 459 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			for i, car in ac.iterateCars.leaderboard() do
				playerListButton(car, 0, (i - 1) * (ui.windowHeight() / 18), ui.windowWidth(), ui.windowHeight() / 18)
			end
		end,
		false,
		true
	)

	-- cui.contentWindow(
	-- 	"car_setup_window22",
	-- 	STORAGE.setupTab,
	-- 	vec2(sim.windowWidth - (800 + 60) * cui.scaleX(), 316 * cui.scaleY()),
	-- 	vec2(650 * cui.scaleX(), sim.windowHeight - 459 * cui.scaleY()),
	-- 	ui.WindowFlags.None,
	-- 	function()
	-- 		drawMap()
	-- 	end,
	-- 	false,
	-- 	true
	-- )

	bottomBar({
		{
			label = "QUIT",
			enabled = true,
			func = function()
				ac.shutdownAssettoCorsa()
			end,
		},
	})

	return ""
end

return page
