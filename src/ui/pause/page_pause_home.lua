local page = {}

local sim = ac.getSim()

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo)

local pauseButtons = {
	{
		label = "Resume",
		enabled = true,
		condition = function() end,
		func = function()
			ac.tryToPause(false)
		end,
	},
	{
		label = "Replay",
		enabled = true,
		condition = function() end,
		func = function()
			ac.tryToToggleReplay(true)
		end,
	},

	{
		label = "Settings",
		enabled = false,
		condition = function() end,
		func = function() end,
	},
	{
		label = "View Settings",
		enabled = false,
		condition = function() end,
		func = function() end,
	},
	{
		label = "Back To Pitlane",
		enabled = true,
		condition = function() end,
		func = function()
			ac.tryToPause(false)
			ac.tryToTeleportToPits()
			teleportPitsCallback = function()
				ac.tryToOpenRaceMenu()
				ac.tryToOpenRaceMenu("setup")

				if sim.isInMainMenu then
					return true
				end
			end
		end,
	},
	{
		label = "Restart Session",
		enabled = true,
		condition = function()
			return sim.isOnlineRace
		end,
		func = function()
			ac.tryToPause(false)
			ac.tryToRestartSession()
		end,
	},
	{
		label = "Quit",
		enabled = true,
		condition = function() end,
		func = function()
			promptShutdownAC()
		end,
	},
}

function page.draw(dt)
	acLogoSize = ui.imageSize(acLogo) * 1.25 * cui.scaleY()
	ui.setCursorX(ui.windowWidth() / 2 - acLogoSize.x / 2)
	ui.image(acLogo, acLogoSize)
	ui.newLine()

	ui.setCursorX(ui.windowWidth() / 8)
	ui.beginGroup(ui.windowWidth() - (ui.windowWidth() / 8) * 2)
	ui.pushStyleVar(ui.StyleVar.ItemSpacing, ui.windowHeight() / 50)

	local menuButtonSize = vec2(ui.availableSpaceX(), ui.availableSpaceY() / 10)

	ui.pushStyleColor(ui.StyleColor.Button, SETTINGS.uiColor1)
	for i in ipairs(pauseButtons) do
		local menuButton = pauseButtons[i]
		local enabled = menuButton.enabled
		local hidden = false

		if menuButton.condition() then
			hidden = true
		end

		if
			not hidden
			and cui.menuButton(
				menuButton.label,
				menuButtonSize,
				ui.Alignment.Center,
				ui.Alignment.Center,
				enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
			)
		then
			menuButton.func()
		end
	end
	ui.popStyleColor(1)

	ui.popStyleVar(1)

	ui.endGroup()
end

return page
