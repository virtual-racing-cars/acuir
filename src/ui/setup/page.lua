require("src\\classes\\spinner")
require("src\\ui\\setup\\list")
require("src\\ui\\setup\\setup_window")
require("src\\ui\\setup\\car_status_window")

local setupPageWindowPos = vec2(100 * UI_SCALE_X / 100, 110 * UI_SCALE_Y / 100)

local setupPageFontSize = ui.Font.Title

if UI_SCALE_Y < 50 then
	setupPageFontSize = ui.Font.Tiny
elseif UI_SCALE_Y < 75 then
	setupPageFontSize = ui.Font.Small
elseif UI_SCALE_Y < 100 then
	setupPageFontSize = ui.Font.Main
end

function SetupPage(sim)
	ui.setCursor(setupPageWindowPos)
	ui.childWindow(
		"setup_window",
		vec2(sim.windowWidth, sim.windowHeight - 110),
		false,
		ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse,
		function()
			ui.bringWindowToFront()
			ui.pushFont(setupPageFontSize)

			SetupTabList()
			SetupWindow()
			CarStatusWindow()

			ui.popFont()
		end
	)
end
