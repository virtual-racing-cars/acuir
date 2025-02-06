local page = {}

local settings = require("settings")
local cui = require("ui.cui")
local pages = require("ui.pages")

local settingsPages = {
	{
		label = "General",
		icon = ui.Icons.AppWindow,
		enabled = true,
		func = function()
			pages:goToSettingsGeneral()
		end,
	},
	{
		label = "Controls",
		icon = ui.Icons.SteeringWheel,
		enabled = false,
		func = function()
			pages:goToSettingsControls()
		end,
	},
	{
		label = "Audio",
		icon = ui.Icons.Music,
		enabled = true,
		func = function()
			pages:goToSettingsAudio()
		end,
	},
	{
		label = "Appearance",
		icon = ui.Icons.Contrast,
		enabled = true,
		func = function()
			pages:goToSettingsAppearance()
		end,
	},
	-- {
	-- 	label = "AI",
	-- 	icon = ui.Icons.AppWindow,
	-- 	enabled = false,
	-- 	func = function()
	-- 		pages:goToSettingsAi()
	-- 	end,
	-- },
}

function page.draw()
	ui.drawRectFilled(vec2(0, 0), vec2(ui.windowWidth(), ui.windowHeight()), settings.Appearance.uiColor1 / 1.1)
	topSubBar("/Settings")

	cui.setCursorX(320)
	cui.setCursorY(366)

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 122 * cui.scaleX())
	ui.beginGroup()

	for i = 1, #settingsPages do
		local page = settingsPages[i]

		if
			cui.settingsButton(
				page.label,
				560,
				300,
				page.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled,
				page.icon
			)
		then
			page.func()
		end

		ui.sameLine()
		if i == 3 then
			cui.setCursorX(320)
			cui.offsetCursorY(422)
		end
	end

	ui.endGroup()
	ui.popStyleVar(1)

	bottomBar({
		{
			label = "BACK",
			enabled = true,
			func = function()
				pages:goToParent()
			end,
		},
	})

	return ""
end

return page
