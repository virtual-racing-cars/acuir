require("src.ui.setup.pitstop_strategy_window")
require("src.ui.setup.gear_window")
require("src.classes.SetupManager")
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

local spinnerWidth = 600 * cui.scaleX()
local spinnerHeight = 70 * cui.scaleY()

local function drawSetupSpinner(sm, si)
	if si.child then
		return
	end

	si:run(true)

	local positions = {
		[0] = 0,
		[0.5] = ui.windowWidth() / 2 - spinnerWidth / 2,
		[1] = (ui.windowWidth() - spinnerWidth),
	}

	local xPos = positions[si.xPos]
	local yPos = (si.yPos * 97 + 60) * cui.scaleY()
	local locked = si.min == si.max

	if #si.items > 0 then
		si.format = si.items[si.value + 1]
	end

	local value, changed, active, hovered = drawSpinner(
		si.name,
		xPos,
		yPos,
		spinnerWidth,
		spinnerHeight,
		locked,
		si.value,
		si.min,
		si.max,
		si.step,
		1,
		0,
		si.format,
		si.multiplier,
		0,
		false
	)

	if si.mirrorAvailable and not locked then
		ui.setCursorX(ui.windowWidth() / 2 - spinnerHeight / 4)
		ui.setCursorY(yPos + spinnerHeight / 4)
		if linkButton(si.name, vec2(spinnerHeight / 2, spinnerHeight / 2), si.mirrored) then
			si.mirrored = not si.mirrored
		end
	end

	if changed or active then
		si:setValue(value)
	end

	if active or locked then
		changed = false
	end

	return changed
end

function car_setup(sm)
	local changed = false
	local tab = sm.setupTabs[tonumber(STORAGE.setupTab)]

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
	end
end
