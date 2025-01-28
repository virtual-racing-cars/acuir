local page = {}

local sim = ac.getSim()

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo)

local pauseButtons = {
	{
		label = "Resume",
		enabled = true,
		func = function()
			ac.tryToPause(false)
		end,
	},
	{
		label = "Replay",
		enabled = true,
		func = function()
			ac.tryToToggleReplay(true)
		end,
	},

	{
		label = "Settings",
		enabled = false,
		func = function() end,
	},
	{
		label = "View Settings",
		enabled = false,
		func = function() end,
	},
	{
		label = "Back To Pitlane",
		enabled = true,
		func = function()
			ac.tryToPause(false)
			ac.tryToTeleportToPits()
		end,
	},
	{
		label = "Restart Session",
		enabled = true,
		func = function()
			ac.tryToPause(false)
			ac.tryToRestartSession()
		end,
	},
	{
		label = "Quit",
		enabled = true,
		func = function()
			ac.shutdownAssettoCorsa()
		end,
	},
}

ac.onCarJumped(0, function(carIndex)
	if not sim.isInMainMenu then
		ac.tryToOpenRaceMenu()
	end
end)

function page.draw(dt)
	acLogoSize = ui.imageSize(acLogo) * 1.5 * cui.scaleY()
	ui.setCursorX(ui.windowWidth() / 2 - acLogoSize.x / 2)
	ui.image(acLogo, acLogoSize)
	ui.newLine()

	ui.setCursorX(ui.windowWidth() / 8)
	ui.beginGroup(ui.windowWidth() - (ui.windowWidth() / 8) * 2)
	ui.pushStyleVar(ui.StyleVar.ItemSpacing, ui.windowHeight() / 50)

	local menuButtonSize = vec2(ui.availableSpaceX(), 40)

	ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.transparent)
	for i in ipairs(pauseButtons) do
		local menuButton = pauseButtons[i]

		if
			cui.menuButton(
				menuButton.label,
				menuButtonSize,
				ui.Alignment.Center,
				ui.Alignment.Center,
				menuButton.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled
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
