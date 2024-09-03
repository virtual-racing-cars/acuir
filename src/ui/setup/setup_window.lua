require("src\\utils\\utils_setup")
require("src\\ui\\setup\\io_window")
require("src\\ui\\setup\\pitstop_strategy_window")

loadSetupSpinners()

local setupSpinnersWindowSize = vec2(1000 * UI_SCALE_X / 100, 730 * UI_SCALE_Y / 100)

local linkButtonSize = vec2(38 * UI_SCALE_X / 100, 38 * UI_SCALE_X / 100)

local mirrorSetupTabs = {}
local mirrorButtonShow = {}
local mirrorButtonsInitialized = false

for _, tab in pairs(tabs) do
	mirrorSetupTabs[tab] = true
	mirrorButtonShow[tab] = false
end

local mirrorSetupStorage = ac.storage(mirrorSetupTabs)

local function setupItemSpinners()
	storage.helpOpen = false

	if storage.setupTab == "SETUP I/O" then
		ioTab()
	end

	if storage.setupTab == "PITSTOP STRATEGY" then
		pitstopStrategyWindow()
	end

	ui.beginScale()
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
	ui.endScale(1)
end

local function setupTabBanner()
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
	contentWindow(
		"car_setup_window",
		storage.setupTab,
		vec2(370, 200),
		setupSpinnersWindowSize,
		ui.WindowFlags.None,
		function()
			pushMainMenuStyle()

			setupTabBanner()
			setupItemSpinners()

			popMainMenuStyle()
		end
	)
end
