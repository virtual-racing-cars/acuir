local page = {}

require("src.classes.PlayerListButton")
local cui = require("ui.cui")
local state = require("state")
local sim = ac.getSim()

-- require("src.ui.home.map")

function promptShutdownAC()
	local mouseMoved = false

	cui.modalDialog(function()
		ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
		local textBoxHeight = ui.windowHeight() / 4

		ui.setCursor(0)
		ui.dwriteTextAligned("Quit Session", textBoxHeight / 2, nil, nil, vec2(ui.windowWidth(), textBoxHeight))
		local titleTextWidth = ui.measureDWriteText(" Quit Session ", textBoxHeight / 2).x

		ui.drawSimpleLine(
			vec2(ui.windowWidth() / 2 - titleTextWidth / 2, ui.getCursorY()),
			vec2(ui.windowWidth() / 2 + titleTextWidth / 2, ui.getCursorY()),
			settings.Appearance.uiColor2,
			3
		)

		ui.setCursorX(0)
		ui.dwriteTextAligned(
			"Abandon the current session and return to Content Manager?",
			textBoxHeight / 4,
			nil,
			nil,
			vec2(ui.windowWidth(), textBoxHeight)
		)

		local buttonWidth = ui.windowWidth() / 3
		ui.setCursorX(ui.windowWidth() / 2 - buttonWidth - 5 * cui.scaleY())
		if cui.modalButton("Cancel", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
			ui.popStyleVar(1)

			return true
		end
		ui.sameLine()

		if not mouseMoved then
			ac.setMousePosition(ui.cursorScreenPos() + vec2(ui.availableSpaceX() / 2, 20))
			mouseMoved = true
		end

		ui.setCursorX(ui.windowWidth() / 2 + 5 * cui.scaleY())
		if cui.modalButton("Confirm", ui.windowWidth() / 3, 50 * cui.scaleY(), ui.ButtonFlags.None) then
			ac.shutdownAssettoCorsa()
			ui.popStyleVar(1)

			return true
		end

		ui.popStyleVar(1)
	end)
end

local menuButtonList = {
	{
		label = "DRIVE",
		enabled = true,
		condition = function() end,
		func = function()
			ac.tryToStart()
		end,
	},
	{
		label = "VEHICLE SETUP",
		enabled = true,
		condition = function() end,
		func = function()
			goToSetupPage()
		end,
	},
	{
		label = "TIME TABLE",
		enabled = false,
		condition = function() end,
		func = function() end,
	},
	{
		label = "TELEMETRY",
		enabled = false,
		condition = function() end,
		func = function() end,
	},
	{
		label = "SETTINGS",
		enabled = true,
		condition = function() end,
		func = function()
			goToSettingsPage()
		end,
	},
	{
		label = "SKIP SESSION",
		enabled = true,
		condition = function()
			return not (sim.sessionsCount > 1 and sim.currentSessionIndex + 1 < sim.sessionsCount)
		end,
		func = function()
			ac.tryToSkipSession()
		end,
	},
	{
		label = "RESTART SESSION",
		enabled = true,
		condition = function()
			return sim.isOnlineRace
		end,
		func = function()
			ac.tryToRestartSession()
		end,
	},
	{
		label = "QUIT",
		enabled = true,
		condition = function() end,
		func = function()
			promptShutdownAC()
		end,
	},
}

function page.update() end

function page.draw()
	topBar(true)
	homeBar(menuButtonList)

	cui.contentWindow(
		"home_leaderboard_window",
		vec2(0, 286 * cui.scaleY()),
		vec2(750 * cui.scaleX(), sim.windowHeight - 459 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			local height = 50 * cui.scaleY()

			playerListBanner(0, 0, ui.windowWidth(), height)

			cui.contentWindow(
				"home_leaderboard_entrant_window",
				vec2(0, height),
				vec2(ui.windowWidth(), ui.windowHeight() - height),
				ui.WindowFlags.None,
				function()
					for i, car in ac.iterateCars.leaderboard() do
						playerListButton(car, 0, (i - 1) * height, ui.windowWidth(), height)
					end
				end
			)
		end,
		false,
		true
	)

	bottomBar({})

	return ""
end

return page
