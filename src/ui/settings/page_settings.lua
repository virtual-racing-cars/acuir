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
		label = "UI",
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
	ui.drawRectFilled(vec2(0, 0), vec2(sim.windowWidth, sim.windowHeight), SETTINGS.uiColor1 / 1.1)

	cui.setCursorX(320)
	cui.setCursorY(366)

	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 122 * cui.scaleX())
	ui.beginGroup()

	for i = 1, #settingsPages do
		local page = settingsPages[i]

		if
			cui.settingsButton(page.label, 560, 300, page.enabled and ui.ButtonFlags.None or ui.ButtonFlags.Disabled)
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
				goToHomePage()
			end,
		},
	})

	-- local storagePath = STORAGE.settingsTab > 1 and "Settings/" .. page.label or "Settings/"
	topSubBar("Settings/")

	if ui.keyboardButtonPressed(ui.KeyIndex.Escape) then
		goToHomePage()
	end

	return ""
end

return page
