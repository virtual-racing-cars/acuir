require("src\\utils\\utils_setup")
require("src\\ui\\setup\\io_window")
require("src\\ui\\setup\\pitstop_strategy_window")
require("src\\ui\\setup\\gear_window")

loadSetupSpinners()

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

	if storage.setupTab == "GEARS" then
		gearWindow()
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

local currentApp = 0

local function tabItem(tabCount, index, title)
	ui.pushStyleColor(
		ui.StyleColor.ButtonHovered,
		currentApp == index and rgbm(0.74, 0, 0, 1) or rgbm(0.25, 0.25, 0.25, 0.4)
	)
	ui.pushStyleColor(ui.StyleColor.Button, currentApp == index and rgbm(0.74, 0, 0, 1) or rgbm.colors.transparent)
	ui.pushStyleColor(
		ui.StyleColor.ButtonActive,
		currentApp == index and rgbm(0.74, 0, 0, 1) or rgbm.colors.transparent
	)

	cui.setCursorY(0)
	local width = ui.measureDWriteText(title, 14)
	if cui.button(title, width.x + 10, 34, 12, ui.Alignment.Center, ui.Alignment.Center) then
		currentApp = index
	end

	ui.sameLine()

	ui.popStyleColor(3)
end

local tabBarPosition = 0
local tabItemPositions = { [0] = 0 }
-- local tabItemPositions = {
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- 	0,
-- }

local function tabBar(apps)
	ui.pushFont(ui.Font.Title)
	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)

	cui.setCursorX(0)

	ui.drawRectFilled(vec2(0, 0), vec2(790, 36) * cui.scaleY(), rgbm(0.1, 0.1, 0.1, 0.5))
	ui.pushClipRect(vec2(0, 0), vec2(790, 36) * cui.scaleY())

	if ui.mouseLocalPos() >= vec2(0, 0) and ui.mouseLocalPos() < vec2(790, 36) * cui.scaleY() then
		if ui.mouseWheel() > 0 then
			currentApp = currentApp >= #apps - 1 and 0 or currentApp + 1
		elseif ui.mouseWheel() < 0 then
			currentApp = currentApp == 0 and #apps - 1 or currentApp - 1
		end
	end

	tabBarPosition = math.applyLag(
		tabBarPosition,
		-math.max(tabItemPositions[currentApp] - 705 * cui.scaleY(), 0),
		0.4,
		ac.getScriptDeltaT()
	)

	ui.setCursorX(tabBarPosition)
	for i in ipairs(apps) do
		tabItem(#apps, i - 1, apps[i])

		if not tabItemPositions[i - 1] then
			tabItemPositions[i - 1] = ui.getCursorX()
		end
	end

	ui.popClipRect()

	ui.popStyleVar(1)
	ui.popFont()

	currentApp = 2

	return currentApp + 1
end

function SetupWindow()
	contentWindow("car_setup_window", storage.setupTab, vec2(20, 200), vec2(790, 830), ui.WindowFlags.None, function()
		pushMainMenuStyle()

		storage.setupTab = tabs[tabBar(tabs)]

		setupTabBanner()
		setupItemSpinners()

		popMainMenuStyle()
	end)
end
