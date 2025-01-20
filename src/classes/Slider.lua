local activeItem = ""

function slider(label, value, min, max, round, format, color, size, step, noScroll, ceil, shiftStep, mult, offset)
	if not step then
		step = 1
	end

	if not offset then
		offset = 0
	end

	if not shiftStep then
		shiftStep = 1
	end

	if not color then
		color = rgbm(0.5, 0.5, 0.5, 1)
	end

	if not mult then
		mult = 1
	end

	local width, height

	if not size then
		width = 475
		height = 32
	else
		width = size.x
		height = size.y
	end

	local sliderWidth = 10 * cui.scaleY()

	local value, changed, active = value, false, false

	local xPos = ui.getCursorX()
	local yPos = ui.getCursorY()
	local xMax = xPos + width

	ui.drawRectFilled(ui.getCursor(), ui.getCursor() + vec2(width, height), rgbm(1, 1, 1, 1))

	ui.invisibleButton("invis" .. label, vec2(width, height))
	ui.setCursor(vec2(xPos, yPos))

	local sliderPosition = ((value - min) / (max - min)) * width

	ui.drawRectFilled(
		vec2(xPos, yPos + height),
		vec2(xPos + sliderPosition, yPos + height + height / 6),
		rgbm(1, 0, 0, 1)
	)

	if not ui.mouseDown(ui.MouseButton.Left) then
		activeItem = ""
	end

	ui.offsetCursorX(sliderPosition)
	ui.invisibleButton("##" .. label, vec2(sliderWidth / 2, height))

	active = ui.itemActive() or (activeItem == label and ui.mouseDown(ui.MouseButton.Left))
	if
		active
		or (
			ui.mouseLocalPos() > vec2(xPos, yPos - height)
			and ui.mouseLocalPos() <= vec2(xPos, yPos) + vec2(width, height + height / 6)
			and (
				(ui.mouseClicked(ui.MouseButton.Left) and not ui.itemHovered(ui.HoveredFlags.None))
				or (ui.mouseWheel() ~= 0 and not noScroll)
			)
		)
	then
		changed = true

		if ui.mouseWheel() ~= 0 then
			local valueChangeAmount = (ui.keyboardButtonDown(ui.KeyIndex.Shift) and shiftStep or step)
			value = ui.mouseWheel() < 0 and (math.round(value) - valueChangeAmount)
				or (math.round(value) + valueChangeAmount)
		else
			activeItem = label
			value = (ui.mouseLocalPos().x - xPos) / (xMax - xPos) * (max - min) + min
		end
	end

	value = math.clamp(value, min, max)

	if ceil then
		value = math.ceil(value)
	else
		value = math.round(value, round)
	end

	ui.sameLine()
	ui.setCursorX(xPos)
	ui.setCursorY(yPos)

	local fontSize = math.floor(size.y * 0.5)
	fontSize = (fontSize % 2 ~= 0) and fontSize + 1 or fontSize

	ui.dwriteTextAligned(
		string.format(format, value * mult + offset),
		math.round(size.y * 0.6),
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2(width, height),
		false,
		rgbm.colors.black
	)

	return value, changed, active
end
