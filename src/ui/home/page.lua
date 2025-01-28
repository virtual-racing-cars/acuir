local page = {}

local sim = ac.getSim()

-- require("src.ui.home.map")
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
		enabled = false,
		func = function()
			goToSettingsPage()
		end,
	},
	{
		label = "RESTART SESSION",
		enabled = true,
		func = function()
			cui.modalDialog(function()
				ac.log(os.clock())
			end)

			ac.tryToRestartSession()
		end,
	},
	{
		label = "QUIT",
		enabled = true,
		func = function()
			local mouseMoved = false

			cui.modalDialog(function()
				ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
				local textBoxHeight = ui.windowHeight() / 4

				ui.dwriteTextAligned("QUIT", textBoxHeight / 2, nil, nil, vec2(ui.availableSpaceX(), textBoxHeight))

				ui.setCursorX(0)
				ui.drawSimpleLine(ui.getCursor(), vec2(ui.windowWidth(), ui.getCursorY()), rgbm.colors.white, 3)

				ui.dwriteTextAligned(
					"Abandon the current session and return to Content Manager?",
					textBoxHeight / 4,
					nil,
					nil,
					vec2(ui.availableSpaceX(), textBoxHeight)
				)

				ui.setCursorX(0)
				if cui.treeNodeButton("Cancel", vec2(ui.availableSpaceX() / 2, 40 * cui.scaleY()), false, false) then
					ui.popStyleVar(1)

					return true
				end
				ui.sameLine()

				if not mouseMoved then
					ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
					mouseMoved = true
				end

				if cui.treeNodeButton("Confirm", vec2(ui.availableSpaceX(), 40 * cui.scaleY()), false, false) then
					ac.shutdownAssettoCorsa()
					ui.popStyleVar(1)

					return true
				end

				ui.popStyleVar(1)
			end)
		end,
	},
}

function page.update() end

function page.draw()
	topBar(true)
	homeBar(menuButtonList)

	cui.contentWindow(
		"home_leaderboard_window",
		STORAGE.setupTab,
		vec2(0, 286 * cui.scaleY()),
		vec2(650 * cui.scaleX(), sim.windowHeight - 459 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			local height = 50 * cui.scaleY()
			for i, car in ac.iterateCars.leaderboard() do
				playerListButton(car, 0, (i - 1) * height, ui.windowWidth(), height)
			end
		end,
		false,
		true,
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

	bottomBar({})

	return ""
end

return page
