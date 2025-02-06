local page = {}

local settings = require("settings")
local cui = require("ui.cui")
local pages = require("ui.pages")
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
		enabled = true,
		condition = function() end,
		func = function()
			pages:goToSettings()
		end,
	},
	{
		label = "View Settings",
		enabled = false,
		condition = function() end,
		func = function() end,
	},
	{
		label = "Go To Vehicle Setup",
		enabled = true,
		condition = function() end,
		func = function()
			ac.tryToPause(false)
			ac.tryToTeleportToPits()
			teleportPitsCallback = function()
				pages:goToSetup()
				ac.tryToOpenRaceMenu()
				ac.tryToOpenRaceMenu("setup")

				if sim.isInMainMenu then
					return true
				end
			end
		end,
	},
	{
		label = "Go To Pitlane",
		enabled = true,
		condition = function() end,
		func = function()
			ac.tryToPause(false)
			ac.tryToTeleportToPits()
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
	local childWindowWith = (2560 * cui.scaleX()) / 5
	local childWindowHeight = (1440 * cui.scaleY()) * 0.5
	local mainWindowFlags = ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse

	if cui.modalDialogCallback then
		mainWindowFlags = mainWindowFlags
			+ ui.WindowFlags.NoInputs
			+ ui.WindowFlags.NoMouseInputs
			+ ui.WindowFlags.NoFocusOnAppearing
	end

	cui.contentWindow(
		"pause_window",
		vec2((ui.windowWidth() - childWindowWith) / 2, (ui.windowHeight() - childWindowHeight) / 2),
		vec2(childWindowWith, childWindowHeight),
		mainWindowFlags,
		function()
			ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.Appearance.uiColor1 / 1.5)

			acLogoSize = ui.imageSize(acLogo) * 1.25 * cui.scaleY()
			ui.setCursorX(ui.windowWidth() / 2 - acLogoSize.x / 2)
			ui.image(acLogo, acLogoSize)
			ui.newLine()

			ui.setCursorX(ui.windowWidth() / 8)
			ui.beginGroup(ui.windowWidth() - (ui.windowWidth() / 8) * 2)

			local itemSpacing = ui.windowHeight() / 50
			ui.pushStyleVar(ui.StyleVar.ItemSpacing, itemSpacing)

			local menuButtonSize = vec2(ui.availableSpaceX(), ui.availableSpaceY() / 11)

			ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColor1)
			for i in ipairs(pauseButtons) do
				local menuButton = pauseButtons[i]
				local enabled = menuButton.enabled
				local hidden = false

				if menuButton.condition() then
					hidden = true
					ui.offsetCursorY(menuButtonSize.y + itemSpacing)
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
	)

	return ""
end

return page
