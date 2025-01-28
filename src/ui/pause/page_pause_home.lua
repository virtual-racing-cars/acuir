local page = {}

local sim = ac.getSim()

local acLogo = ac.getFolder(ac.FolderID.Root) .. "\\launcher\\themes\\default\\graphics\\btn_AC_logo.png"
local acLogoSize = ui.imageSize(acLogo)

local teleportPitsCallback = nil

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
			ac.tryToTeleportToPits()
			ac.tryToPause(false)

			teleportPitsCallback = function()
				return ac.tryToOpenRaceMenu("setup")
			end
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

	if teleportPitsCallback then
		if teleportPitsCallback() then
			teleportPitsCallback = nil
		end
	end
end

return page
