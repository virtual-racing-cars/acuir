require("src\\utils\\utils_setup")
require("src\\ui\\setup\\specials")

loadSetupSpinners()

local setupSpinnersWindowSize = vec2(800 * UI_SCALE_X / 100, 560 * UI_SCALE_Y / 100)
local setupSpinnersWindowHeaderSize = vec2(800 * UI_SCALE_X / 100, 50 * UI_SCALE_Y / 100)

local function setupItemSpinners()
	SetupSpecialTabs(storage.setupTab)
	for k, v in pairs(setupSpinners) do
		if v.tab == storage.setupTab then
			v:run()
		end
	end
end

local function setupTabBanner()
	ui.drawRectFilled(vec2(0, 0), setupSpinnersWindowHeaderSize, rgbm(0.1, 0.1, 0.1, 0.5), 0, ui.CornerFlags.None)
	setCursorX(30)
	setCursorY(0)
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
	setCursorY(0)
	childWindow("car_setup_window", setupSpinnersWindowSize, false, ui.WindowFlags.None, function()
		ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
		ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

		pushMainMenuStyle()

		setupItemSpinners()
		setupTabBanner()

		popMainMenuStyle()
	end)
end
