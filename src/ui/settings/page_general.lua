local page = {}

local sim = ac.getSim()

local settings = require("settings")

local bottomBarButtons = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			goToSettingsPage()
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

local generalSettings = {
	{ key = "autoStart", label = "Auto-Start new UI", default = true },
	{ key = "showVersions", label = "Show app and CSP versions", default = true },
	{ key = "developerMode", label = "Developer Mode", default = false },
}

settings:register(generalSettings)

function page.draw()
	settingsMenuCommon("/General", bottomBarButtons, goToSettingsPage)

	cui.contentWindow(
		"car_setup_window",
		STORAGE.setupTab,
		vec2(60 * cui.scaleX(), 240 * cui.scaleY()),
		vec2(sim.windowWidth - 120 * cui.scaleX(), sim.windowHeight - 383 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			ui.drawLine(vec2(0, 2 * cui.scaleY()), vec2(ui.windowWidth(), 2 * cui.scaleY()), rgbm.colors.gray, 2)
			ui.drawRectFilled(vec2(0, 2 * cui.scaleY()), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

			cui.setCursorX(50)
			cui.setCursorY(100)

			ui.beginGroup(0)

			for i = 1, #generalSettings do
				local general = generalSettings[i]

				if ui.checkbox(general.label, settings[general.key]) then
					settings[general.key] = not settings[general.key]
				end
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

	return ""
end

return page
