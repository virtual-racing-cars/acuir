require("src\\ui\\setup\\setup_window")
require("src\\ui\\setup\\help_window")
require("src\\ui\\setup\\car_status_window")

local setupPageFontSize = ui.Font.Title

if UI_SCALE_Y < 50 then
	setupPageFontSize = ui.Font.Tiny
elseif UI_SCALE_Y < 75 then
	setupPageFontSize = ui.Font.Small
elseif UI_SCALE_Y < 100 then
	setupPageFontSize = ui.Font.Main
end

function SetupPage(sim)
	ui.pushFont(setupPageFontSize)

	SetupWindow()
	HelpWindow()

	ui.popFont()
end
