local page = {}

local cui = require("ui.cui")
local pages = require("ui.pages")
local sim = ac.getSim()

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

local audioChannels = {
	"Main",
	"Rain",
	"Weather",
	"Track",
	"Wipers",
	"Car Components",
	"Wind",
	"Tyres",
	"Surfaces",
	"Dirt",
	"Engine",
	"Transmission",
	"Opponents",
}

table.sort(audioChannels)

function page.draw()
	settingsMenuCommon("/Audio", bottomBarButtons)

	cui.contentWindow(
		"car_setup_window",
		vec2(60 * cui.scaleX(), 240 * cui.scaleY()),
		vec2(sim.windowWidth - 120 * cui.scaleX(), sim.windowHeight - 383 * cui.scaleY()),
		ui.WindowFlags.None,
		function()
			ui.drawLine(vec2(0, 2), vec2(ui.windowWidth(), 2), rgbm.colors.gray, 2)
			ui.drawRectFilled(vec2(0, 2), vec2(ui.windowWidth(), ui.windowHeight()), rgbm(0, 0, 0, 0.2))

			ui.setCursorY(100)

			for k, v in ipairs(audioChannels) do
				local id = string.replace(v, " ", "")

				ui.setCursorX(50)

				local value, changed =
					ui.slider("##" .. id, ac.getAudioVolume(ac.AudioChannel[id]) * 100, 0, 100, v .. ": %.0f")

				if changed then
					ac.setAudioVolume(ac.AudioChannel[id], value / 100)
				end
			end

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
