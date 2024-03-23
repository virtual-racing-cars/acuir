require("src\\utils\\utils_setup")
require("src\\ui\\setup\\specials")

loadSetupSpinners()

local setupSpinnersWindowSize = vec2(875 * UI_SCALE_X / 100, 560 * UI_SCALE_Y / 100)

local setupSpinnersWindowHeaderSize = vec2(875 * UI_SCALE_X / 100, 50 * UI_SCALE_Y / 100)

function SetupWindow()
	setCursorX(400)
	setCursorY(0)
	ui.childWindow("setup_window", setupSpinnersWindowSize, false, ui.WindowFlags.None, function()
		ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)
		ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(1, 1, 1, 0.25), 0, ui.CornerFlags.None)

		pushMainMenuStyle()

		SetupSpecialTabs(storage.setupTab)
		for k, v in pairs(setupSpinners) do
			if v.tab == storage.setupTab then
				v:run()
			end
		end

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

		popMainMenuStyle()
	end)
end
