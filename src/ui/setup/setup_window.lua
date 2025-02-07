require("src.ui.setup.gear_window")
require("src.classes.Slider")
local settings = require("settings")
local cui = require("ui.cui")
local audio = require("audio")
local app = require("app")

local currentApp = app.state.setupTab
local tabBarPosition = 0
local tabItemPositions = { [0] = 0 }

local function tabItem(index, title)
	if
		cui.menuButton(title, 56, ui.Alignment.Center, ui.Alignment.Center, ui.ButtonFlags.None, currentApp == index)
	then
		currentApp = index
	end
end

ac.onResolutionChange(function(newSize, makingScreenshot)
	for i in ipairs(tabItemPositions) do
		tabItemPositions[i] = nil
	end
	currentApp = 0
	tabBarPosition = 0
end)

local tabBarScrollDisabled = false

function setupTabBar(apps)
	if ui.mouseLocalPos() >= vec2(0, 0) and ui.mouseLocalPos() < vec2(ui.windowWidth(), 56 * cui.scaleY()) then
		if ui.mouseWheel() > 0 then
			currentApp = currentApp >= #apps - 1 and 0 or currentApp + 1
			audio:trigger()
		elseif ui.mouseWheel() < 0 then
			currentApp = currentApp == 0 and #apps - 1 or currentApp - 1
			audio:trigger()
		end
	end

	if not tabBarScrollDisabled and tabItemPositions[currentApp] then
		tabBarPosition = math.applyLag(
			tabBarPosition,
			-math.max(tabItemPositions[currentApp] - ui.windowWidth() / 2, 0),
			0.4,
			ac.getScriptDeltaT()
		)
	end

	ui.setCursorX(tabBarPosition)
	ui.setCursorY(0)
	ui.pushStyleColor(ui.StyleColor.Button, settings.Appearance.uiColor1)
	for i in ipairs(apps) do
		tabItem(i - 1, apps[i].name)

		if not tabItemPositions[i - 1] then
			tabItemPositions[i - 1] = ui.getCursorX()
		end
	end

	if tabItemPositions[#apps - 1] <= ui.windowWidth() then
		tabBarScrollDisabled = true
	end

	ui.popStyleColor(1)

	return currentApp + 1
end

local function linkButton(name, size, linked)
	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(0, 0, 0, 0))

	local tmpPos = ui.getCursor()
	local clicked = ui.button("##linkButton" .. name, size, ui.ButtonFlags.PressedOnClick)
	local hovered = ui.itemHovered() and not cui.modalDialogCallback
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
	local yPos = (si.yPos * 97 + 61) * cui.scaleY()

	if #si.items > 0 then
		si.format = si.items[si.value + 1]
	end

	local value, changed, active, hovered = drawSpinner(
		si.id,
		si.name,
		xPos,
		yPos,
		spinnerWidth,
		spinnerHeight,
		si.fixed,
		si.value,
		si.min,
		si.max,
		si.step,
		1,
		0,
		si.format,
		si.multiplier,
		0,
		false,
		si.help
	)

	if si.mirrorAvailable and not si.fixed then
		ui.setCursorX(ui.windowWidth() / 2 - spinnerHeight / 4)
		ui.setCursorY(yPos + spinnerHeight / 4)
		if linkButton(si.name, vec2(spinnerHeight / 2, spinnerHeight / 2), si.mirrored) then
			si.mirrored = not si.mirrored
		end
	end

	if hovered and ui.mouseClicked(ui.MouseButton.Right) then
		si:resetValue()
		audio:trigger()
	end

	if changed or active then
		if si:setValue(value) then
			audio:trigger()
		end
	end

	if active or si.fixed then
		changed = false
	end

	return changed
end

local pitstopStrategyPreset = 0

function car_setup(sm)
	spinnerWidth = 620 * cui.scaleX()
	spinnerHeight = 74 * cui.scaleY()

	local changed = false
	local tab = sm.setupTabs[tonumber(app.state.setupTab)]

	if tab.name == "GEARS" then
		gearWindow(#tab.setupSpinners)
	end

	for _, v in pairs(tab.setupSpinners) do
		if v.tab == "PITSTOP STRATEGY" then
			if v.id == "PRESET" then
				pitstopStrategyPreset = v.value - 1
				drawSetupSpinner(sm, v)
			end

			if string.find(v.id, "_PRESET_" .. pitstopStrategyPreset) then
				drawSetupSpinner(sm, v)
			end
		elseif v.yPos > -2 then
			if v.tab == "GEARS" and #tab.setupSpinners == 1 then
				v.xPos = 0.5
				v.yPos = 0
			end

			if drawSetupSpinner(sm, v) then
				changed = true
			end
		end
	end

	if changed then
		sm:makeUndo()
	end
end
