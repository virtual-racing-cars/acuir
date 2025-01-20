require("src\\utils\\utils_setup")
require("src\\ui\\setup\\io_window")
require("src\\ui\\setup\\pitstop_strategy_window")
require("src\\ui\\setup\\gear_window")

require("src.classes.SetupMgr")
require("src.classes.Button")
require("src.classes.Slider")

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

	cui.setCursorY(200)
	local width = ui.measureDWriteText(title, 14)
	if cui.button(title, width.x + 10, 56, 12, ui.Alignment.Center, ui.Alignment.Center) then
		currentApp = index
	end

	ui.sameLine()

	ui.popStyleColor(3)
end

local tabBarPosition = 0
local tabItemPositions = { [0] = 0 }

local uiStartY = 40
local uiStartX = 60

local topBarHeight = 200

local menuButtonSizeX = 120
local menuButtonSizeY = 56
local menuButtonFontSize = 12

local sim = ac.getSim()

local function tabBar(apps)
	ui.pushFont(ui.Font.Title)
	ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)

	cui.setCursorX(uiStartX)
	cui.setCursorY(uiStartY + topBarHeight)

	ui.drawRectFilled(vec2(0, 200), vec2(sim.windowWidth, 256) * cui.scaleY(), rgbm(0.1, 0.1, 0.1, 0.5))
	ui.pushClipRect(vec2(0, 200), vec2(sim.windowWidth, 256) * cui.scaleY())

	if ui.mouseLocalPos() >= vec2(60, 200) and ui.mouseLocalPos() < vec2(sim.windowWidth - 120, 256) * cui.scaleY() then
		if ui.mouseWheel() > 0 then
			currentApp = currentApp >= #apps - 1 and 0 or currentApp + 1
		elseif ui.mouseWheel() < 0 then
			currentApp = currentApp == 0 and #apps - 1 or currentApp - 1
		end
	end

	tabBarPosition = math.applyLag(
		tabBarPosition,
		-math.max(tabItemPositions[currentApp] - sim.windowWidth / 2 - 60, 0),
		0.4,
		ac.getScriptDeltaT()
	)

	ui.setCursorX(tabBarPosition)
	for i in ipairs(apps) do
		tabItem(#apps, i - 1, apps[i].name)

		if not tabItemPositions[i - 1] then
			tabItemPositions[i - 1] = ui.getCursorX()
		end
	end

	ui.popClipRect()

	ui.popStyleVar(1)
	ui.popFont()

	-- currentApp = 11

	return currentApp + 1
end

local sim = ac.getSim()

local max = math.max

local SpinnerButtonType = { Reset = -1, Left = 0, Right = 1 }

local _l_button_alignment = vec2(0.5, 0.1)

local function myButton(text, size, hovercolor, backcolor, thumbnail)
	ui.invisibleButton("##dummyButton", size)
	local r1, r2 = ui.itemRect()
	local hovered = ui.itemHovered()
	ui.drawRectFilled(r1, r2, hovered and hovercolor or backcolor, 4)

	if thumbnail ~= nil then
		ui.drawImage(thumbnail, r1, r2, rgbm.colors.white)
	end

	ui.drawRect(r1, r2, hovered and hovercolor or backcolor, 4, nil, 4)
	ui.drawTextClipped(text, r1, r2, rgbm.colors.white, _l_button_alignment, true)
	return hovered and ac.getUI().isMouseLeftKeyClicked
end

local function arrowButton(direction, size)
	local tmpPos = ui.getCursor()
	local clicked = ui.button("##dummyButton" .. direction, size, ui.ButtonFlags.PressedOnClick)
	local hovered = ui.itemHovered()
	ui.setCursor(tmpPos)

	if hovered then
		ui.popup(function()
			ui.text("hi")
		end)
	end

	ui.icon(
		direction == SpinnerButtonType.Left and ui.Icons.Skip or ui.Icons.Skip,
		size,
		hovered and rgbm.colors.red or rgbm.colors.white,
		direction == SpinnerButtonType.Left and -size or size
	)

	return clicked
end

local spinnerWidth = 580
local spinnerHeight = 30
local buttonSize = vec2(spinnerHeight, spinnerHeight)

function drawSpinnerButton(setupItem, direction)
	local changed = false

	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.TextHovered, rgbm(1, 0, 0, 1))
	ui.pushStyleColor(ui.StyleColor.HeaderHovered, rgbm(0, 0, 0, 0))
	if setupItem.min == setupItem.max then
		ui.dummy(buttonSize)
	elseif direction == SpinnerButtonType.Reset then
		if
			ui.modernButtonAdvanced(
				"##" .. direction .. setupItem.id,
				buttonSize,
				ui.ButtonFlags.PressedOnClick,
				ui.Icons.Stay,
				spinnerHeight / 2
			)
		then
			changed = setupItem:resetValue()
		end
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

	local sliderWidth = (spinnerWidth / 2.4) - (2 * spinnerHeight)
	local sliderHeight = spinnerHeight

	-- local sliderGrabSize =
	-- 	max(350 * cui.scaleY() / (setupItem.max - setupItem.min + setupItem.step) / setupItem.step, 10)

	local value, changed, active = slider(
		"##" .. setupItem.id .. setupItem.name,
		setupItem.value,
		setupItem.min,
		setupItem.max,
		0,
		setupItem.format,
		nil,
		vec2(sliderWidth, sliderHeight),
		1,
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

	if ui.itemHovered(ui.HoveredFlags.None) then
		setupItem.helpWindowShow = true
	end

	if setupItem.itemActive and ui.mouseReleased(ui.MouseButton.Left) then
		changed = true
	end
	setupItem.itemActive = active

	ui.sameLine()
	return changed
end

local function drawSetupSpinner(sm, setupItem)
	local changed = false

	setupItem:run(true)

	local padding = ui.windowWidth() * 0.017
	local positions = {
		[0] = padding,
		[0.5] = ui.windowWidth() / 2 - spinnerWidth / 2 - padding,
		[1] = (ui.windowWidth() - spinnerWidth - padding),
	}

	ui.setCursorX(positions[setupItem.xPos])
	cui.setCursorY(setupItem.yPos * 98 + 100)

	ui.drawRectFilled(
		ui.getCursor() - vec2(0, spinnerHeight * 1.1),
		ui.getCursor() + vec2(spinnerWidth, spinnerHeight * 2),
		rgbm.new("#3a3842")
	)

	local setupItemHovered = ui.mouseLocalPos() >= ui.getCursor() - vec2(0, spinnerHeight * 1.1)
		and ui.mouseLocalPos() < ui.getCursor() + vec2(spinnerWidth, spinnerHeight * 2)

	local sliderPos = ui.getCursor()
	local tempPos = ui.getCursor()

	ui.dwriteTextAligned(
		setupItem.name,
		spinnerHeight * 0.5,
		ui.Alignment.End,
		ui.Alignment.Start,
		vec2(spinnerWidth / 3, spinnerHeight)
	)
	ui.sameLine()

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

	ui.dwriteTextAligned(
		string.format(setupItem.format, setupItem.value * setupItem.multiplier),
		spinnerHeight * 0.5,
		ui.Alignment.Start,
		ui.Alignment.Center,
		vec2(spinnerWidth / 3, spinnerHeight)
	)

	-- if setupItemHovered then
	-- 	if drawSpinnerButton(setupItem, SpinnerButtonType.Reset) then
	-- 		changed = true
	-- 	end
	-- else
	-- 	ui.dummy(buttonSize)
	-- 	ui.sameLine()
	-- end
	if setupItem.helpWindowShow then
		HELP_TEXT = setupItem.help
		setupItem:helpWindow()
	end

	ac.debug("HistoryCount", #sm._history)
	ac.debug("HistoryPosition", sm._history_pos)

	ui.popStyleVar(1)

	return changed
end

local sm = SetupMgr()

function car_setup()
	-- spinnerWidth = ui.windowWidth() / 2.15
	-- spinnerHeight = spinnerWidth / 12
	-- buttonSize = vec2(spinnerHeight, spinnerHeight)

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

	ui.setCursorX(210)
	ui.setCursorY(20)

	if sm:isUndoAvailable() then
		if myButton("undo", vec2(40, 20), rgbm.colors.cyan, rgbm.colors.gray) then
			sm:undo()
		end
	end

	ui.setCursorX(255)
	ui.setCursorY(20)

	if sm:isRedoAvailable() then
		if myButton("redo", vec2(40, 20), rgbm.colors.cyan, rgbm.colors.gray) then
			sm:redo()
		end
	end
end

function SetupWindow()
	contentWindow(
		"car_setup_window",
		storage.setupTab,
		vec2(60, 40),
		vec2(sim.windowWidth - 120, sim.windowHeight - 183),
		ui.WindowFlags.None,
		function()
			pushMainMenuStyle()

			storage.setupTab = tabBar(sm.setupTabs)
			contentWindow(
				"car_setup_window2",
				storage.setupTab .. "2",
				vec2(ui.windowWidth() / 4, 256),
				vec2(ui.windowWidth() / 2, ui.availableSpaceY()),
				ui.WindowFlags.None,
				function()
					-- ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm.colors.aqua)
					ui.setCursor(0)
					car_setup()
				end,
				false,
				true
			)

			ui.setCursor(0)
			contentWindow(
				"help_window42",
				storage.setupTab .. "42",
				vec2((ui.windowWidth() / 4) * 3, 256),
				vec2(ui.windowWidth() / 4, ui.availableSpaceY()),
				ui.WindowFlags.None,
				function()
					-- ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), rgbm.colors.aqua)
					ui.setCursor(0)

					setCursorX(6)
					setCursorY(50)

					if HELP_TEXT ~= "NULL" and HELP_TEXT ~= "" then
						ui.dummy(vec2(230 * cui.scaleY(), 0))
						ui.bringWindowToFront()
						local helpSections = string.split(HELP_TEXT, "\\n\\n")

						for i in ipairs(helpSections) do
							ui.dwriteTextWrapped(helpSections[i], 24)
						end
					end

					HELP_TEXT = ""
				end,
				false,
				true
			)

			ui.setCursor(0)
			contentWindow(
				"help_window432",
				storage.setupTab .. "423",
				vec2(0, 256),
				vec2(ui.windowWidth() / 4, ui.availableSpaceY()),
				ui.WindowFlags.None,
				function()
					CarStatusWindow()
				end,
				false,
				true
			)

			popMainMenuStyle()
			-- CarStatusWindow()
		end
	)
end
