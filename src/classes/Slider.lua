local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local itemActive = ""
local itemHeld = ""

local SpinnerButtonType = { Left = 0, Right = 1 }

local function drawSpinnerButton(direction, size)
	size = size / 2

	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(0, 0, 0, 0))
	ui.pushStyleColor(ui.StyleColor.TextHovered, rgbm(1, 0, 0, 1))

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

	-- if arrowButton(direction, size / 2) then
	-- 	-- setupItem.buttonHeldTimer[direction] = os.clock() + 0.5
	-- 	-- setupItem.buttonHeldStart = os.clock()

	-- 	clicked = true
	-- elseif
	-- 	-- setupItem.buttonHeldTimer[direction] < os.clock()
	-- 	-- and
	-- 	ui.itemActive() and ui.mouseDown(ui.MouseButton.Left)
	-- then
	-- 	-- clicked = true

	-- 	-- setupItem.buttonHeldTimer[direction] = (os.clock() - setupItem.buttonHeldStart) < 2.5 and os.clock() + 0.1
	-- 	-- 	or os.clock() + 0.075
	-- end

	ui.popStyleColor(4)

	return clicked
end

function drawSlider(
	name,
	xPos,
	yPos,
	width,
	height,
	locked,
	value,
	min,
	max,
	step,
	shiftStep,
	round,
	format,
	multiplier,
	offset,
	noScroll
)
	local value, changed = value, false
	local xMax = xPos + width
	local fontSize = math.floor(height * 0.38)
	fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

	ui.setCursorX(xPos)
	ui.setCursorY(yPos)
	ui.pushDWriteFont(ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.SemiBold))
	ui.dwriteTextAligned(
		name,
		fontSize,
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2Temp1:set(width, height / 2),
		false,
		rgbm.colors.white
	)

	ui.setCursorX(xPos)
	ui.setCursorY(yPos)
	ui.invisibleButton("invis" .. name, vec2Temp1:set(width, height))

	local active = ui.itemActive() or (itemHeld == name and ui.mouseDown(ui.MouseButton.Left))
	local sliderHovered = ui.mouseLocalPos() > vec2Temp1:set(xPos, yPos)
		and ui.mouseLocalPos() <= vec2Temp2:set(xPos + width, yPos + height)
	local sliderClicked = ui.mouseClicked(ui.MouseButton.Left) and not ui.itemHovered(ui.HoveredFlags.None)
	local sliderScrolling = ui.mouseWheel() ~= 0 and not noScroll

	if active or (sliderHovered and (sliderClicked or sliderScrolling)) then
		if sliderScrolling then
			local valueChangeAmount = (ui.keyboardButtonDown(ui.KeyIndex.Shift) and shiftStep or step)
			value = ui.mouseWheel() < 0 and (math.round(value) - valueChangeAmount)
				or (math.round(value) + valueChangeAmount)

			audioTrigger()
		else
			itemHeld = name
			value = (ui.mouseLocalPos().x - xPos) / (xMax - xPos) * (max - min) + min
		end

		changed = true
	end

	value = math.round(math.clamp(value, min, max), round)

	ui.drawRectFilled(
		vec2Temp1:set(xPos, yPos + height),
		vec2Temp2:set(xPos + (((value - min) / (max - min)) * width), yPos + height * 1.083),
		settings.uiColor2
	)

	ui.setCursorX(xPos)
	ui.setCursorY(yPos + height / 2)
	ui.dwriteTextAligned(
		string.format(format, value * multiplier + offset),
		fontSize,
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2Temp1:set(width, height / 2),
		false,
		rgbm.colors.black
	)

	ui.popDWriteFont()

	if ui.mouseDown(ui.MouseButton.Left) then
		changed = false
	end
	if itemActive == name and ui.mouseReleased(ui.MouseButton.Left) then
		changed = true
		itemHeld = ""
		itemActive = ""
	end
	if active then
		itemActive = name
	end

	return value, changed, active
end

function drawSpinner(
	name,
	xPos,
	yPos,
	width,
	height,
	locked,
	value,
	min,
	max,
	step,
	shiftStep,
	round,
	format,
	multiplier,
	offset,
	noScroll
)
	local buttonSize = height / 2
	local value = value
	local changed = false

	ui.setCursorX(xPos)
	ui.setCursorY(yPos)

	ui.drawRectFilled(
		vec2Temp1:set(xPos + height, yPos),
		vec2Temp2:set(xPos + width - height, yPos + buttonSize),
		settings.uiColor1
	)
	ui.drawRectFilled(
		vec2Temp1:set(xPos + height, yPos + buttonSize),
		vec2Temp2:set(xPos + width - height, yPos + height),
		settings.uiColor3
	)

	local hovered = ui.mouseLocalPos() >= vec2Temp1:set(xPos + buttonSize, yPos)
		and ui.mouseLocalPos() < vec2Temp2:set(xPos + width - buttonSize, yPos + height)

	ui.setCursorX(xPos + buttonSize)
	ui.setCursorY(yPos + buttonSize)
	if hovered and not locked then
		if drawSpinnerButton(SpinnerButtonType.Left, vec2Temp1:set(height, height)) then
			if value ~= min then
				value = value - step
				changed = true
			end
		end
	else
		ui.dummy(vec2Temp1:set(height, height))
	end

	local _value, _changed, active = drawSlider(
		name,
		xPos + height,
		yPos,
		width - (height * 2),
		height,
		locked,
		value,
		min,
		max,
		step,
		shiftStep,
		round,
		format,
		multiplier,
		offset,
		noScroll
	)
	if _changed then
		value = _value
		changed = _changed
	elseif active then
		value = _value
	end

	ui.setCursorX(xPos + width - height)
	ui.setCursorY(yPos + buttonSize)
	if hovered and not locked then
		if drawSpinnerButton(SpinnerButtonType.Right, vec2Temp1:set(height, height)) then
			if value ~= max then
				value = value + step
				changed = true
			end
		end
	else
		ui.dummy(vec2Temp1:set(height, height))
	end

	return value, changed, active, hovered
end
