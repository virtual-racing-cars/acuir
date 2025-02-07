local bindings = {}

require("classes.TabBar")
local cui = require("ui.cui")
local controls = require("controls")
controls:initialize()

local controlsINI = ac.INIConfig.controlsConfig()
local contentManagerControlsTabBar = {}
local extCarControlsTabBar = {}
local appControlsTabBar = {}

local checkBoxSize = 20
local checkBoxMargin = 5
local checkBoxSizeV = vec2(checkBoxSize, checkBoxSize)
local WINDOW_MARGIN = 20

local carSpecificPreset = controlsINI:get("__LAUNCHER_CM", "PRESET_NAME", "")
local carSpecificPresetEnabled = controlsINI:get("__LAUNCHER_CM", "PRESET_CHANGED", -1) == 0

if carSpecificPresetEnabled then
	carSpecificPreset = string.replace(string.replace(carSpecificPreset, "savedSetups\\", ""), ".ini", "")
end

local function labelAligned(text, yOffset)
	ui.textAligned(text, vec2(1, 1), vec2(100, 22))
	ui.sameLine()
end

local function checkbox(controlBinding)
	local changed = false

	ui.sameLine(ui.windowWidth() - checkBoxSize - WINDOW_MARGIN - 33)
	ui.textAligned("MPS", vec2(0, 0.51), vec2(25, 25))
	ui.sameLine()
	ui.setCursorY(ui.getCursorY() + 3)

	local selectedX = ui.getCursorX()
	local selectedY = ui.getCursorY()

	ui.drawRectFilled(
		vec2(selectedX, selectedY),
		vec2(selectedX + checkBoxSize, selectedY + checkBoxSize),
		rgbm(0.175, 0.175, 0.175, 1)
	)
	if ui.modernButton("##button" .. controlBinding.name, checkBoxSizeV, ui.ButtonFlags.None) then
		controlBinding:toggleMPS()
		changed = true
	end
	if ui.itemHovered(ui.HoveredFlags.AllowWhenBlockedByActiveItem) then
		ui.tooltip(function()
			ui.text("Toggle binding modes from sequential\nand Multi-Position Switch (MPS)")
		end)
	end

	if controlBinding.mpsToggle then
		ui.sameLine()
		ui.drawRectFilled(
			vec2(selectedX + checkBoxMargin, selectedY + checkBoxMargin),
			vec2(selectedX + checkBoxSize - checkBoxMargin, selectedY + checkBoxSize - checkBoxMargin),
			rgbm.colors.white
		)

		if ac.getPatchVersionCode() > 2664 then
			if not controlBinding.buttonDown:disabled() or not controlBinding.buttonUp:disabled() then
				controlBinding.buttonDown:setDisabled(true)
				controlBinding.buttonUp:setDisabled(true)
			end
		end
	else
		if ac.getPatchVersionCode() > 2664 then
			if controlBinding.buttonDown:disabled() or controlBinding.buttonDown:disabled() then
				controlBinding.buttonDown:setDisabled(false)
				controlBinding.buttonUp:setDisabled(false)
			end
		end
	end

	if ac.getPatchVersionCode() > 2664 then
		if SETTINGS.disableBindDeactivation and (controlBinding:disabled() or controlBinding:disabled()) then
			controlBinding:setDisabled(true)
			controlBinding:setDisabled(true)
		end
	end

	-- for i = 1, tonumber(bindSection.POS[1]) do
	-- 	local iSection = bind .. "_" .. i
	-- 	local iButtonSection = iSection

	-- 	if tonumber(bindSection.LUA[1]) == 1 then
	-- 		iButtonSection = "__EXT_CAR_" .. iButtonSection
	-- 	end

	-- 	if ac.getPatchVersionCode() > 2664 then
	-- 		if controlBinding.mpsToggle then
	-- 			if controlBinding[iSection]:disabled() then
	-- 				controlBinding[iSection]:setDisabled(false)
	-- 			end
	-- 		else
	-- 			if not controlBinding[iSection]:disabled() then
	-- 				controlBinding[iSection]:setDisabled(true)
	-- 			end
	-- 		end
	-- 	end
	-- end

	ui.setCursorY(selectedY + checkBoxSize + 5)

	return changed
end

local function infoText()
	if carSpecificPresetEnabled then
		if carSpecificPreset ~= "" then
			ui.textAligned(
				"Car-Specific Controls: " .. carSpecificPreset,
				vec2(0.5, 0.5),
				vec2(ui.availableSpaceX(), 30)
			)
		end
	else
		ui.textAligned("", vec2(0.5, 0.5), vec2(ui.availableSpaceX(), 30))
	end
end

local function helpInfoButton(controlBinding)
	if controlBinding.help ~= "" and controlBinding.help ~= nil then
		ui.sameLine()
		ui.offsetCursorX(-5)
		ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
		ui.iconButton(ui.Icons.Info, vec2(12, 12), rgbm.colors.white, nil, 1)
		if ui.itemHovered(ui.HoveredFlags.AllowWhenBlockedByActiveItem) then
			ui.tooltip(function()
				ui.text(controlBinding.help)
			end)
		end
		ui.popStyleColor(1)
	end

	if controlBinding.isLuaControlled then
		ui.sameLine()
		ui.offsetCursorX(-5)
		ui.icon(ui.Icons.Lua, vec2(12, 12), rgbm.colors.white, nil, 1)
	else
		if controlBinding.isExtendedPhysics then
			ui.sameLine()
			ui.offsetCursorX(-5)
			ui.icon(ui.Icons.Speedometer, vec2(12, 12), rgbm.colors.white, nil, 1)
		end
	end
end

local function bindingBoxes(name, label, button, bind, yOffset)
	local controlButtonFlags = ui.ControlButtonControlFlags.None

	-- if global then
	-- 	controlButtonFlags = controlButtonFlags + ui.ControlButtonControlFlags.AlterRealConfig
	-- end

	-- if string.find(bind, "__EXT_LIGHT") then
	-- 	if ui.button(label, vec2(100, 32), ui.ButtonFlags.None) then
	-- 		ac.simulateCustomHotkeyPress(bind)
	-- 		ac.trySimKeyPressCommand(bind)
	-- 	end
	-- 	if ui.itemHovered(ui.HoveredFlags.None) and ui.itemActive() then
	-- 		ac.simulateCustomHotkeyPress(bind)
	-- 		ac.trySimKeyPressCommand(bind)
	-- 	end
	-- else
	-- end
	-- labelAligned(label .. ":", yOffset)

	ui.setCursorX(WINDOW_MARGIN)
	ui.dwriteTextAligned(
		name .. " " .. label,
		24 * cui.scaleY(),
		ui.Alignment.Start,
		ui.Alignment.Center,
		vec2(ui.windowWidth(), 50 * cui.scaleY())
	)
	ui.sameLine()
	ui.setCursorX(0)

	button:control(vec2(ui.windowWidth(), 50), controlButtonFlags)
end

local function buttonBinder(controlBinding)
	-- helpInfoButton(controlBinding)

	if controlBinding.isActivationBind then
		bindingBoxes(controlBinding.name, "", controlBinding.button, controlBinding.bind)

		return
	end

	-- if controlBinding.isMultiPositionSwitchBind then
	-- 	checkbox(controlBinding)
	-- end

	if controlBinding.isMultiPositionSwitchBind then -- and controlBinding.mpsToggle then
		for index, button in ipairs(controlBinding.buttonPosition) do
			bindingBoxes(controlBinding.name, controlBinding.buttonPositionLabel[index], button, controlBinding.bind)
		end

		return
	end

	if controlBinding.isSequentialBind then
		bindingBoxes(controlBinding.name, controlBinding.buttonUpLabel, controlBinding.buttonUp, controlBinding.bind, 8)
		ui.newLine()
		ui.setCursorX(WINDOW_MARGIN)

		bindingBoxes(
			controlBinding.name,
			controlBinding.buttonDownLabel,
			controlBinding.buttonDown,
			controlBinding.bind,
			8
		)
	end
end

local function tabContentsWindow(tab)
	for _i, controlBinding in pairs(tab.content) do
		buttonBinder(controlBinding)
		ui.newLine()
	end
end

local function carControlsTabBar()
	ui.tabBar("carControlsTabBar", ui.TabBarFlags.TabListPopupButton + ui.TabBarFlags.FittingPolicyScroll, function()
		for _i, tab in ipairs(extCarControlsTabBar.tabs) do
			ui.tabItem(tab.name, function()
				tabContentsWindow(tab)
			end)
		end
	end)
end

local function appsControlsTabBar()
	ui.setCursor(0)
	ac.log("hi")
	ac.log(appControlsTabBar)

	-- ui.tabBar("appTabBar", ui.TabBarFlags.TabListPopupButton + ui.TabBarFlags.FittingPolicyScroll, function()
	-- 	for _i, app in ipairs(appControlsTabBar) do
	-- 		ui.tabItem(app.name, function()
	-- 			ui.tabBar(
	-- 				"appControlsTabBar",
	-- 				ui.TabBarFlags.TabListPopupButton + ui.TabBarFlags.FittingPolicyScroll,
	-- 				function()
	-- 					for _i, tab in ipairs(app.tabs) do
	-- 						ui.tabItem(tab.name, function()
	-- 							tabContentsWindow(tab)
	-- 						end)
	-- 					end
	-- 				end
	-- 			)
	-- 		end)
	-- 	end
	-- end)
end

local categoryTabBar = TabBar()
local carControlsTabBar = TabBar()
local generalControlsTabBar = TabBar()
local applicationControlsTabBar = TabBar()

local appsTabBars = {}

local function drawCarControlsTabBar()
	local tab = carControlsTabBar:draw(controls.car.tabs)

	cui.pushWindow("bindings_list_window", 0, 56, ui.windowWidth(), ui.windowHeight() - 56, true)
	for _, controlBinding in pairs(tab.content) do
		buttonBinder(controlBinding)
		ui.newLine()
	end
	cui.popWindow(true)
end

local function drawContentManagerControlsTabBar()
	local tab = generalControlsTabBar:draw(controls.cm.tabs)

	cui.pushWindow("bindings_list_window", 0, 56, ui.windowWidth(), ui.windowHeight() - 56, true)
	for _, controlBinding in pairs(tab.content) do
		buttonBinder(controlBinding)
		ui.newLine()
	end
	cui.popWindow(true)
end

local function drawAppControlsTabBar()
	local app = applicationControlsTabBar:draw(controls.apps)
	ui.newLine()
	if not appsTabBars[app.name] then
		appsTabBars[app.name] = TabBar()
	end

	local tab = appsTabBars[app.name]:draw(app.tabs)

	cui.pushWindow("bindings_list_window", 0, 168, ui.windowWidth(), ui.windowHeight() - 56, true)
	for _, controlBinding in pairs(tab.content) do
		buttonBinder(controlBinding)
		ui.newLine()
	end
	cui.popWindow(true)
end

local categoryTabs = {
	{ name = "Car", content = drawCarControlsTabBar },
	{ name = "General", content = drawContentManagerControlsTabBar },
	{ name = "Apps", content = drawAppControlsTabBar },
}

local function cmControlsTabBar()
	if contentManagerControlsTabBar == nil then
		ui.setCursorX(ui.windowWidth() / 2 - 25)
		ui.setCursorY(ui.windowHeight() / 2 - 25)
		ui.icon(ui.Icons.LoadingSpinner, vec2(50, 50))
		return
	end

	ui.setCursor(0)
	local category = categoryTabBar:draw(categoryTabs)

	cui.pushWindow("bindings_list_main_window", 0, 56, ui.windowWidth(), ui.windowHeight() - 56)
	ui.setCursor(0)
	category.content()
	cui.popWindow()

	-- tabBar:draw(contentManagerControlsTabBar.tabs)

	-- ui.tabBar("cmControlsTabBar", ui.TabBarFlags.TabListPopupButton + ui.TabBarFlags.FittingPolicyScroll, function()
	-- 	if extCarControlsTabBar ~= nil then
	-- 		ui.tabItem("Car", function()
	-- 			carControlsTabBar()
	-- 		end)
	-- 	end

	-- 	if table.count(appControlsTabBar) > 0 then
	-- 		ui.tabItem("Apps", function()
	-- 			appsControlsTabBar()
	-- 		end)
	-- 	end

	-- 	for _i, tab in ipairs(contentManagerControlsTabBar.tabs) do
	-- 		ui.tabItem(tab.name, function()
	-- 			tabContentsWindow(tab)
	-- 		end)
	-- 	end
	-- end)
end

local function footerInfo()
	-- ui.drawSimpleLine(vec2(0, 600), vec2(100, 600), rgbm.colors.aqua)
	-- ui.drawSimpleLine(vec2(451, 600), vec2(351, 600), rgbm.colors.aqua)
	ui.setCursorY(ui.windowHeight() - 28)
	ui.setCursorX(0)
	ui.textAligned("Info            Extended Physics            Lua    ", vec2(0.5, 0), vec2(ui.windowWidth()))
	ui.setCursorY(ui.windowHeight() - 26)
	ui.setCursorX(130)
	ui.icon(ui.Icons.Info, vec2(12, 12), rgbm.colors.white, nil, 1)
	ui.sameLine(275)
	ui.icon(ui.Icons.Speedometer, vec2(12, 12), rgbm.colors.white, nil, 1)
	ui.sameLine(340)
	ui.icon(ui.Icons.Lua, vec2(12, 12), rgbm.colors.white, nil, 1)
end

-- function windowMain()
-- 	pushButtonStyle()

-- 	if SETTINGS.showIconLegend then
-- 	end

-- 	popButtonStyle()
-- end

function bindings:draw()
	-- infoText()
	cmControlsTabBar()
	-- footerInfo()
end

return bindings
