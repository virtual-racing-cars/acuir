local page = {}

local sim = ac.getSim()

local settingsPages = {
	{
		label = "General",
		enabled = true,
		func = function()
			goToSettingsGeneralPage()
		end,
	},
	{
		label = "Controls",
		enabled = false,
		func = goToSettingsControlsPage,
	},
	{
		label = "Audio",
		enabled = true,
		func = function()
			goToSettingsAudioPage()
		end,
	},
	{
		label = "Appearance",
		enabled = true,
		func = function()
			goToSettingsAppearancePage()
		end,
	},
	{
		label = "AI",
		enabled = false,
		func = function()
			goToSettingsAiPage()
		end,
	},
}

function page.draw()
	-- ui.drawLine(vec2(220, 64), vec2(600, 64), rgbm.colors.white, 1)
	-- ui.drawLine(vec2(220, 90), vec2(600, 90), rgbm.colors.white, 1)

	settingsMenuCommon("", {
		{
			label = "BACK",
			enabled = true,
			func = function()
				goToHomePage()
			end,
		},
	}, goToHomePage)

	cui.setCursorX(320)
	cui.setCursorY(366)

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 122 * cui.scaleX())
	ui.beginGroup()

	for i = 1, #settingsPages do
		local page = settingsPages[i]

		if cui.modalButton(page.label, 560, 300, page.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled) then
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

	return ""
end

return page
