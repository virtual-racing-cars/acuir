local page = {}

local settings = require("settings")
local cui = require("ui.cui")
local sim = ac.getSim()

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

function page.draw()
	settingsMenuCommon("/General", bottomBarButtons, goToSettingsPage)

	cui.contentWindow(
		"car_setup_window",
		"car_setup_window",
		vec2(60 * cui.scaleX(), 240 * cui.scaleY()),
		vec2(sim.windowWidth - 120 * cui.scaleX(), sim.windowHeight - 383 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			ui.drawLine(vec2(0, 2 * cui.scaleY()), vec2(ui.windowWidth(), 2 * cui.scaleY()), rgbm.colors.gray, 2)
			ui.drawRectFilled(vec2(0, 2 * cui.scaleY()), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

			cui.setCursorX(50)
			cui.setCursorY(100)

			ui.beginGroup(0)

			for i, v in ipairs(settings.General) do
				if v.widget == 1 then
					if ui.checkbox(v.label, settings.General[v.key]) then
						settings.General[v.key] = not settings.General[v.key]
					end
				elseif v.widget == 2 then
					settings.General[v.key] = drawSpinner(
						v.label,
						v.label,
						ui.windowWidth() / 2 - 500 / 2,
						ui.getCursorY(),
						500,
						50,
						false,
						settings.General[v.key],
						v.min,
						v.max,
						1,
						1,
						0,
						v.format,
						1,
						0,
						false,
						nil
					)
					-- ui.slider("##" .. v.label, settings.General[v.key], v.min, v.max, v.format)
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
