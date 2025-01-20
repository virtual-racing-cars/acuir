local sim = ac.getSim()

local bottomBarButtons = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			storage.settingsTab = 1
		end,
	},
	{
		label = "APPLY",
		enabled = false,
		func = function() end,
	},
	{
		label = "CANCEL",
		enabled = false,
		func = function() end,
	},
	-- {
	-- 	label = "SETUP PRESETS",
	-- 	enabled = true,
	-- 	func = function() end,
	-- },
}

function generalSettings()
	contentWindow(
		"car_setup_window",
		storage.setupTab,
		vec2(60, 240),
		vec2(sim.windowWidth - 120, sim.windowHeight - 383),
		ui.WindowFlags.None,
		function()
			ui.drawLine(vec2(0, 2), vec2(ui.windowWidth(), 2), rgbm.colors.gray, 2)
			ui.drawRectFilled(vec2(0, 2), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

			ui.setCursorX(50)
			ui.setCursorY(100)

			ui.beginGroup(0)

			if ui.checkbox("Auto-Start new UI", settings.autoStart) then
				settings.autoStart = not settings.autoStart
			end

			local value, changed = ui.slider(
				"##afkhideui",
				settings.uiHideonIdleTime,
				0,
				300,
				settings.uiHideonIdleTime > 0 and "Hide UI after idle: %.0f seconds" or "Hide UI after idle: Disabled"
			)

			if changed then
				settings.uiHideonIdleTime = math.floor(value / 5 + 0.5) * 5
			end

			if ui.checkbox("Show app and CSP versions on bottom right of the screen", settings.showVersions) then
				settings.showVersions = not settings.showVersions
			end

			if ui.checkbox("Developer Mode", settings.showVersions) then
				settings.showVersions = not settings.showVersions
			end

			ui.endGroup()

			ui.drawLine(
				vec2(0, ui.windowHeight() - 2),
				vec2(ui.windowWidth(), ui.windowHeight() - 2),
				rgbm.colors.gray,
				2
			)
		end,
		false,
		true
	)

	bottomBar(bottomBarButtons)
end
