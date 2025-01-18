require("src\\ui\\settings\\general_settings")
require("src\\ui\\settings\\appearance_settings")
require("src\\ui\\settings\\audio_settings")
require("src\\ui\\settings\\view_settings")
require("src\\ui\\settings\\setup_settings")

local settingsTabs = {
	[0] = "GENERAL",
	[1] = "APPEARANCE",
	[2] = "VIEW",
	[3] = "AUDIO",
	[4] = "SETUP",
}

local listWidth = 335 * UI_SCALE_X / 100
local listMargins = 5
local setupTabHeight = 50

local settingsWindowSize = vec2(830 * UI_SCALE_X / 100, 710 * UI_SCALE_Y / 100)
local settingsListSize = vec2(listWidth, 710 * UI_SCALE_Y / 100)

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

function tabBar(apps)
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

	return currentApp + 1
end

function SettingsList(sim)
	-- contentWindow("settings_list", "SETTINGS", vec2(0, 0), settingsListSize, ui.WindowFlags.None, function()
	-- 	pushSetupListStyle()

	-- 	setCursorX(0)
	-- 	setCursorY(42)

	-- 	childWindow("settings_list", ui.availableSpace(), false, ui.WindowFlags.ThinScrollbar, function()
	-- 		local buttonXPos = 0
	-- 		local buttonYPos = 0
	-- 		for tab in ipairs(settingsTabs) do
	-- 			local buttonFlags = ui.ButtonFlags.None

	-- 			if storage.settingsTab == settingsTabs[tab] then
	-- 				buttonFlags = ui.ButtonFlags.Active
	-- 			end

	-- 			setCursorX(buttonXPos)
	-- 			setCursorY(buttonYPos)
	-- 			if
	-- 				ui.buttonAdvanced(
	-- 					settingsTabs[tab],
	-- 					vec2(ui.availableSpaceX(), setupTabHeight * UI_SCALE_Y / 100),
	-- 					buttonFlags
	-- 				)
	-- 			then
	-- 				storage.settingsTab = settingsTabs[tab]
	-- 			end

	-- 			buttonYPos = buttonYPos + setupTabHeight + listMargins
	-- 		end
	-- 	end)

	-- 	popSetupListStyle()
	-- end)

	contentWindow("settings_window", storage.setupTab, vec2(20, 340), vec2(790, 830), ui.WindowFlags.None, function()
		pushMainMenuStyle()

		storage.settingsTab = settingsTabs[tabBar(settingsTabs)]

		if storage.settingsTab == "GENERAL" then
			generalSettings()
		end

		if storage.settingsTab == "APPEARANCE" then
			appearanceSettings()
		end

		if storage.settingsTab == "AUDIO" then
			-- audioSettings()
		end

		if storage.settingsTab == "VIEW" then
			viewSettings()
		end

		if storage.settingsTab == "SETUP" then
			setupSettings()
		end

		popMainMenuStyle()
	end)

	-- contentWindow(
	-- 	"settings_window",
	-- 	storage.settingsTab,
	-- 	vec2(345, 0),
	-- 	settingsWindowSize,
	-- 	ui.WindowFlags.None,
	-- 	function()

	-- 	end
	-- )
end
