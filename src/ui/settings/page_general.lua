local page = {}

local settings = require("settings")
local cui = require("ui.cui")
local pages = require("ui.pages")

local bottomBarButtons = {
	{
		label = "BACK",
		enabled = true,
		func = function()
			pages:goToSettings()
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
}

function page.draw()
	settingsMenuCommon("/General", bottomBarButtons)

	cui.contentWindow(
		"car_setup_window",
		vec2(0, 240 * cui.scaleY()),
		vec2(ui.windowWidth(), ui.windowHeight() - 300 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			ui.drawLine(vec2(0, 2 * cui.scaleY()), vec2(ui.windowWidth(), 2 * cui.scaleY()), rgbm.colors.gray, 2)
			ui.drawRectFilled(vec2(0, 2 * cui.scaleY()), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

			cui.setCursorX(50)
			cui.setCursorY(100)

			ui.beginGroup(0)

			for i, v in ipairs(settings.General) do
				cui.setCursorY(100 * i)

				if v.widget == 1 then
					local value = settings.General[v.key] and 1 or 0
					local newValue = drawSpinner(
						v.label,
						v.label,
						ui.windowWidth() / 2 - 600 / 2,
						ui.getCursorY(),
						600,
						75,
						false,
						value,
						0,
						1,
						1,
						1,
						0,
						settings.General[v.key] and "Enabled" or "Disabled",
						1,
						0,
						false,
						nil
					)

					settings.General[v.key] = newValue == 1 and true or false
				elseif v.widget == 2 then
					settings.General[v.key] = drawSpinner(
						v.label,
						v.label,
						ui.windowWidth() / 2 - 600 / 2,
						ui.getCursorY(),
						600,
						75,
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
				end
			end

			ui.endGroup()

			ui.drawLine(
				vec2(0, ui.windowHeight() - 2),
				vec2(ui.windowWidth(), ui.windowHeight() - 2),
				rgbm.colors.gray,
				2
			)
		end
	)

	return ""
end

return page
