require("src\\utils\\utils_setup")
require("src\\ui\\setup\\io_window")
require("src\\ui\\setup\\pitstop_strategy_window")
require("src\\ui\\setup\\gear_window")

require("src.classes.SetupMgr")
require("src.classes.Button")
require("src.classes.Slider")

local currentApp = 0

local function tabItem(tabCount, index, title)
	ui.pushStyleColor(
		ui.StyleColor.ButtonHovered,
		currentApp == index and rgbm(0.74, 0, 0, 1) or rgbm(0.25, 0.25, 0.25, 0.4)
	)
	ui.pushStyleColor(
		ui.StyleColor.Button,
		currentApp == index and rgbm(1, 1, 1, 1) or rgbm(0.227451, 0.219608, 0.258824, 1)
	)

	ui.pushStyleColor(
		ui.StyleColor.ButtonActive,
		currentApp == index and rgbm(0.74, 0, 0, 1) or rgbm.colors.transparent
	)

	if
		cui.menuButton(title, 56, ui.Alignment.Center, ui.Alignment.Center, ui.ButtonFlags.None, currentApp == index)
	then
		currentApp = index
	end

	ui.sameLine()

	ui.popStyleColor(2)
end

local tabBarPosition = 0
local tabItemPositions = { [0] = 0 }

local sim = ac.getSim()

function setupTabBar(apps)
	ui.pushFont(ui.Font.Title)
	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)

	if
		ui.mouseLocalPos() >= vec2(0, 0)
		and ui.mouseLocalPos() < vec2(sim.windowWidth - 120 * cui.scaleX(), 56 * cui.scaleY())
	then
		if ui.mouseWheel() > 0 then
			currentApp = currentApp >= #apps - 1 and 0 or currentApp + 1
			audioTrigger()
		elseif ui.mouseWheel() < 0 then
			currentApp = currentApp == 0 and #apps - 1 or currentApp - 1
			audioTrigger()
		end
	end

	tabBarPosition = math.applyLag(
		tabBarPosition,
		-math.max(tabItemPositions[currentApp] - ui.windowWidth() / 2, 0),
		0.4,
		ac.getScriptDeltaT()
	)

	ui.setCursorX(tabBarPosition)
	ui.setCursorY(0)
	for i in ipairs(apps) do
		tabItem(#apps, i - 1, apps[i].name)

		if not tabItemPositions[i - 1] then
			tabItemPositions[i - 1] = ui.getCursorX()
		end
	end

	ui.popStyleVar(1)
	ui.popFont()

	return currentApp + 1
end

local SpinnerButtonType = { Left = 0, Right = 1 }

local function arrowButton(direction, size)
	local tmpPos = ui.getCursor()
	local clicked = ui.button("##dummyButton" .. direction, size, ui.ButtonFlags.PressedOnClick)
	local hovered = ui.itemHovered()
	ui.setCursor(tmpPos)

	ui.icon(
		direction == SpinnerButtonType.Left and ui.Icons.Skip or ui.Icons.Skip,
		size,
		hovered and rgbm.colors.red or rgbm.colors.white,
		direction == SpinnerButtonType.Left and -size or size
	)

	return clicked
end

local function linkButton(name, size, linked)
	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(0, 0, 0, 0))

	local tmpPos = ui.getCursor()
	local clicked = ui.button("##linkButton" .. name, size, ui.ButtonFlags.PressedOnClick)
	local hovered = ui.itemHovered()
	ui.setCursor(tmpPos)

	ui.beginRotation()
	ui.icon(
		linked and ui.Icons.Link or ui.Icons.LinkBroken,
		size,
		hovered and rgbm.colors.red or rgbm.colors.white,
		size
	)
	ui.endRotation(0)

	ui.popStyleColor(3)

	return clicked
end

local spinnerWidth = 580 * cui.scaleX()
local spinnerHeight = 34 * cui.scaleY()
local buttonSize = vec2(spinnerHeight, spinnerHeight)

function drawSpinnerButton(setupItem, direction)
	local changed = false

	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.TextHovered, rgbm(1, 0, 0, 1))
	ui.pushStyleColor(ui.StyleColor.HeaderHovered, rgbm(0, 0, 0, 0))
	if setupItem.min == setupItem.max then
		ui.dummy(buttonSize)
	elseif arrowButton(direction, buttonSize) then
		setupItem.buttonHeldTimer[direction] = os.clock() + 0.5
		setupItem.buttonHeldStart = os.clock()

		if direction == SpinnerButtonType.Left then
			changed = setupItem:decreaseValue()
		else
			changed = setupItem:increaseValue()
		end
	elseif
		setupItem.buttonHeldTimer[direction] < os.clock()
		and ui.itemActive()
		and ui.mouseDown(ui.MouseButton.Left)
	then
		if direction == SpinnerButtonType.Left then
			changed = setupItem:decreaseValue()
		else
			changed = setupItem:increaseValue()
		end

		setupItem.buttonHeldTimer[direction] = (os.clock() - setupItem.buttonHeldStart) < 2.5 and os.clock() + 0.1
			or os.clock() + 0.075
	end

	if setupItem.min ~= setupItem.max and ui.itemHovered(ui.HoveredFlags.None) then
		setupItem.helpWindowShow = true
	end

	ui.popStyleColor(4)

	ui.sameLine()
	return changed
end

function drawSlider(setupItem, pos)
	if #setupItem.items > 0 then
		setupItem.format = (
			setupItem.items[setupItem.value + 1] and setupItem.items[setupItem.value + 1] or setupItem.value
		)
	end

	local sliderWidth = spinnerWidth - (2 * spinnerHeight)
	local sliderHeight = spinnerHeight

	local value, changed, active = slider(
		setupItem.name,
		setupItem.value,
		setupItem.min,
		setupItem.max,
		0,
		setupItem.format,
		nil,
		vec2(sliderWidth, sliderHeight),
		setupItem.step,
		false,
		true,
		1,
		setupItem.multiplier
	)

	if changed then
		changed = setupItem:setValue(value)
	end

	if ui.mouseDown(ui.MouseButton.Left) then
		changed = false
	end

	if setupItem.itemActive and ui.mouseReleased(ui.MouseButton.Left) then
		changed = true
	end
	setupItem.itemActive = active

	ui.sameLine()
	return changed
end

local function drawSetupSpinner(sm, setupItem)
	if setupItem.child then
		return
	end

	local changed = false

	setupItem:run(true)

	local positions = {
		[0] = 0,
		[0.5] = ui.windowWidth() / 2 - spinnerWidth / 2,
		[1] = (ui.windowWidth() - spinnerWidth),
	}

	local xPos = positions[setupItem.xPos]
	local yPos = (setupItem.yPos * (ui.windowHeight() / spinnerHeight + 67) + 60) * cui.scaleY()

	ui.setCursorX(xPos)
	ui.setCursorY(yPos)

	ui.drawRectFilled(
		ui.getCursor() + vec2(spinnerHeight, 0),
		ui.getCursor() + vec2(spinnerWidth - spinnerHeight, spinnerHeight),
		rgbm.new("#3a3842")
	)

	local setupItemHovered = ui.mouseLocalPos() >= ui.getCursor() - vec2(0, spinnerHeight * 1.1)
		and ui.mouseLocalPos() < ui.getCursor() + vec2(spinnerWidth, spinnerHeight * 2)

	local sliderPos = ui.getCursor()

	if setupItemHovered then
		if drawSpinnerButton(setupItem, SpinnerButtonType.Left) then
			changed = true
		end
	else
		ui.dummy(buttonSize)
		ui.sameLine()
	end

	if drawSlider(setupItem, sliderPos) then
		changed = true
	end

	if setupItemHovered then
		if drawSpinnerButton(setupItem, SpinnerButtonType.Right) then
			changed = true
		end
	else
		ui.dummy(buttonSize)
		ui.sameLine()
	end

	if
		ui.mouseLocalPos() > vec2(xPos, yPos)
		and ui.mouseLocalPos() <= vec2(xPos, yPos) + vec2(spinnerWidth, spinnerHeight * 2 + spinnerHeight / 6)
	then
		HELP_TEXT = setupItem.help
	end

	if setupItem.mirrorAvailable then
		ui.setCursorX(ui.windowWidth() / 2 - spinnerHeight / 2)
		ui.offsetCursorY(-spinnerHeight / 2)
		if linkButton(setupItem.name, buttonSize, setupItem.mirrored) then
			setupItem.mirrored = not setupItem.mirrored
		end
	end

	ui.popStyleVar(1)

	return changed
end

function car_setup(sm)
	ui.newLine()

	local changed = false
	local tab = sm.setupTabs[tonumber(storage.setupTab)]

	for _, v in pairs(tab.setupSpinners) do
		if drawSetupSpinner(sm, v) then
			changed = true
		end
	end

	if changed then
		sm:makeUndo()
	end
end

function SetupWindow(sm)
	if ui.keyboardButtonPressed(ui.KeyIndex.Escape) then
		storage.page = MenuPages.Home
	end
end
