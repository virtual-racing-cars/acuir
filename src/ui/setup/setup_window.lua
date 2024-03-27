require("src\\utils\\utils_setup")
require("src\\ui\\setup\\io_window")

loadSetupSpinners()

local setupSpinnersWindowSize = vec2(830 * UI_SCALE_X / 100, 605 * UI_SCALE_Y / 100)
local setupSpinnersWindowHeaderSize = vec2(830 * UI_SCALE_X / 100, 50 * UI_SCALE_Y / 100)

local function setupItemSpinners()
	if storage.setupTab == "SETUP I/O" then
		ioTab()
	end

	for k, v in pairs(setupSpinners) do
		v:run(v.tab == storage.setupTab)
	end
end

local function setupTabBanner()
	ui.drawRectFilled(vec2(0, 0), setupSpinnersWindowHeaderSize, rgbm(0.1, 0.1, 0.1, 0.5), 0, ui.CornerFlags.None)
	ui.dwriteTextAligned(
		storage.setupTab,
		35 * UI_SCALE_Y / 100,
		ui.Alignment.Center,
		ui.Alignment.Start,
		ui.availableSpace(),
		false,
		rgbm.colors.white
	)
end

function SetupWindow()
	setCursorX(350)
	setCursorY(15)
	childWindow("car_setup_window", setupSpinnersWindowSize, false, ui.WindowFlags.None, function()
		ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
		ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

		pushMainMenuStyle()

		setupItemSpinners()
		setupTabBanner()

		popMainMenuStyle()
	end)
end
