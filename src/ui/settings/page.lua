require("src\\ui\\settings\\list")

local setupPageWindowPos = vec2(100 * UI_SCALE_X / 100, 110 * UI_SCALE_Y / 100)

local setupPageFontSize = ui.Font.Title
if UI_SCALE_Y < 50 then
	setupPageFontSize = ui.Font.Tiny
elseif UI_SCALE_Y < 75 then
	setupPageFontSize = ui.Font.Small
elseif UI_SCALE_Y < 100 then
	setupPageFontSize = ui.Font.Main
end

function SettingsPage(sim)
	-- ui.drawRectFilled(vec2(0, 0), vec2(sim.windowWidth, sim.windowHeight), rgbm(0.2, 0.2, 0.2, 1))
	ui.pushFont(setupPageFontSize)

	SettingsList(sim)

	ui.popFont()
end
