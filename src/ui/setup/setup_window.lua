require("src\\utils\\utils_setup")
require("src\\ui\\setup\\io_window")

loadSetupSpinners()

local setupSpinnersWindowSize = vec2(830 * UI_SCALE_X / 100, 605 * UI_SCALE_Y / 100)
local setupSpinnersWindowHeaderSize = vec2(830 * UI_SCALE_X / 100, 50 * UI_SCALE_Y / 100)

local linkButtonSize = vec2(50 * UI_SCALE_X / 100, 50 * UI_SCALE_X / 100)

local mirrorSetupTabs = {}
local mirrorButtonShow = {}
local mirrorButtonsInitialized = false

for _, tab in pairs(tabs) do
	mirrorSetupTabs[tab] = true
	mirrorButtonShow[tab] = false
end

local mirrorSetupStorage = ac.storage(mirrorSetupTabs)

local function setupItemSpinners()
	if storage.setupTab == "SETUP I/O" then
		ioTab()
	end

	for k, v in pairs(setupSpinners) do
		local tab = v.tab

		if mirrorSetupTabs[tab] ~= nil then
			v:run(tab == storage.setupTab, mirrorSetupStorage[tab])

			if not mirrorButtonsInitialized then
				if v.idMirror then
					mirrorButtonShow[tab] = true
				end
			end
		end
	end
end

local function setupTabBanner()
	ui.drawRectFilled(vec2(0, 0), setupSpinnersWindowHeaderSize, rgbm(0.1, 0.1, 0.1, 0.5), 0, ui.CornerFlags.None)
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

	if not mirrorButtonShow[storage.setupTab] or mirrorSetupTabs[storage.setupTab] == nil then
		return
	end

	setCursorY(0)
	ui.setCursorX(ui.availableSpaceX() - linkButtonSize.x)
	if
		ui.modernButtonAdvanced(
			"##linksetupitems",
			linkButtonSize,
			ui.ButtonFlags.None,
			mirrorSetupStorage[storage.setupTab] and ui.Icons.Link or ui.Icons.LinkBroken,
			15 * UI_SCALE_X / 100
		)
	then
		mirrorSetupStorage[storage.setupTab] = not mirrorSetupStorage[storage.setupTab]
	end
end

function SetupWindow()
	setCursorX(365)
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
