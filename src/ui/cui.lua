local cui = {}

local sim = ac.getSim()

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local storedBools = {}
local defaultWidth = 2560
local defaultHeight = 1440
local windowMaxWidth = 0
local windowMaxHeight = 0

local scaleY = math.min(sim.windowHeight / defaultHeight, sim.windowWidth / defaultWidth)
local scaleX = scaleY

ac.onResolutionChange(function(newSize, makingScreenshot)
	scaleY = math.min(newSize.y / defaultHeight, newSize.x / defaultWidth)
	scaleX = scaleY
end)

function cui.loadStoredBool(id)
	return storedBools[id]
end

function cui.storeBool(id, value)
	storedBools[id] = value
end

function cui.windowMaxWidth()
	return windowMaxWidth
end

function cui.windowMaxHeight()
	return windowMaxHeight
end

function cui.availableSpaceX()
	return ui.availableSpaceX()
end

function cui.availableSpaceY()
	return ui.availableSpaceY() * scaleY
end

function cui.scaleX()
	return scaleX
end

function cui.scaleY()
	return scaleY
end

function cui.setCursorX(v)
	ui.setCursorX(v * scaleX)
end

function cui.setCursorY(v)
	ui.setCursorY(v * scaleY)
end

function cui.offsetCursorX(v)
	ui.offsetCursorX(v * scaleX)
end

function cui.offsetCursorY(v)
	ui.offsetCursorY(v * scaleY)
end

function cui.childWindow(id, size, border, flags, content)
	ui.childWindow(id, size, false, flags, content)
end

function cui.contentWindow(id, title, position, size, flags, content, showTitle, hideBackground, scroll)
	cui.pushWindow(id .. "test", position.x, position.y, size.x, size.y, scroll)

	if not hideBackground then
		ui.drawRectFilled(vec2(0, 0), size, SETTINGS.uiColor1 / 2)
	end

	content()

	cui.popWindow()
end

local fontRegular = ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.SemiBold)
local fontBold = ui.DWriteFont("Rajdhani"):weight(ui.DWriteFont.Weight.Bold)
local fontSemiBold = ui.DWriteFont("Noto Sans SC"):weight(ui.DWriteFont.Weight.SemiBold)

function cui.dwriteTextWrapped(text, font)
	ui.pushDWriteFont(fontRegular)
	ui.dwriteTextWrapped(text, font * cui.scaleY())
	ui.popDWriteFont()
end

function cui.dwriteText(params)
	if not params.size then
		params.size = vec2Temp1:set(350, 100)
	end

	if params.xPos then
		ui.setCursorX(params.xPos * cui.scaleX())
	end

	if params.yPos then
		ui.setCursorY(params.yPos * cui.scaleY())
	end

	ui.pushDWriteFont(fontRegular)
	ui.dwriteText(params.text, params.fontSize * cui.scaleY(), params.color)
	ui.popDWriteFont()
end

function cui.dwriteTextAligned(params)
	if not params.size then
		params.size = vec2Temp1:set(350, 100)
	end

	if params.xPos then
		ui.setCursorX(params.xPos * cui.scaleX())
	end

	if params.yPos then
		ui.setCursorY(params.yPos * cui.scaleY())
	end

	ui.pushDWriteFont(fontRegular)
	ui.dwriteTextAligned(
		params.text,
		params.fontSize * cui.scaleY(),
		params.xAlign,
		params.yAlign,
		vec2Temp1:set(params.size.x * cui.scaleX(), params.size.y * cui.scaleY()),
		false,
		params.color
	)
	ui.popDWriteFont()
end

function cui.button(label, sizeX, sizeY, fontSize, horizontalAligment, verticalAlignment, flags, fontColor)
	if not horizontalAligment then
		horizontalAligment = ui.Alignment.Center
	end

	if not verticalAlignment then
		verticalAlignment = ui.Alignment.Center
	end

	if not flags then
		flags = ui.ButtonFlags.None
	end

	local textWidth = ui.measureDWriteText(string.upper(label), fontSize * scaleX).x
	local fontColor = fontColor

	if flags == ui.ButtonFlags.Disabled then
		fontColor = rgbm(0.6, 0.6, 0.6, 1)
		ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.05, 0.05, 0.05, 1))
	end

	local tempCursor = ui.getCursor()
	ui.button("##" .. label, vec2Temp1:set(textWidth + 30 * scaleX, sizeY * scaleY), flags)
	local hovered = ui.itemHovered()

	if flags == ui.ButtonFlags.Disabled then
		ui.popStyleColor(1)
	end

	ui.sameLine()
	ui.offsetCursorY(1)
	ui.setCursor(tempCursor)

	ui.pushDWriteFont(fontRegular)

	ui.dwriteTextAligned(
		string.upper(label),
		fontSize * scaleX,
		horizontalAligment,
		verticalAlignment,
		vec2Temp1:set(textWidth + 30 * scaleX, sizeY * scaleY),
		false,
		fontColor
	)

	ui.popDWriteFont()

	return hovered and ac.getUI().isMouseLeftKeyClicked and not (flags == ui.ButtonFlags.Disabled)
end

function cui.settingsButton(label, sizeX, sizeY, flags)
	sizeX = sizeX * scaleX
	sizeY = sizeY * scaleY

	local fontSize = 35 * scaleY

	local disabled = flags == ui.ButtonFlags.Disabled

	ui.pushStyleColor(ui.StyleColor.Button, SETTINGS.uiColor1)
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, SETTINGS.uiColor2)
	ui.pushStyleColor(ui.StyleColor.ButtonActive, SETTINGS.uiColor2)

	local tempCursor = ui.getCursor()
	ui.button("##" .. label, vec2Temp1:set(sizeX, sizeY), flags)
	local hovered = ui.itemHovered()
	local r1, r2 = ui.itemRect()

	if not ui.itemHovered() or disabled then
		ui.drawRect(r1, r2, disabled and rgbm.colors.gray or rgbm.colors.white, 0, ui.CornerFlags.None, 2)
	end

	ui.popStyleColor(3)

	ui.sameLine()
	ui.offsetCursorY(1)
	ui.setCursor(tempCursor)

	ui.pushDWriteFont(fontBold)

	ui.dwriteTextAligned(
		string.upper(label),
		fontSize,
		ui.Alignment.Center,
		ui.Alignment.Center,
		vec2Temp1:set(sizeX, sizeY),
		false,
		rgbm.colors.white
	)

	ui.popDWriteFont()

	return hovered and ac.getUI().isMouseLeftKeyClicked and not (flags == ui.ButtonFlags.Disabled)
end

function cui.menuButton(label, size, horizontalAligment, verticalAlignment, flags, active, bold)
	if bold then
		ui.pushDWriteFont(fontBold)
	else
		ui.pushDWriteFont(fontRegular)
	end

	if not horizontalAligment then
		horizontalAligment = ui.Alignment.Center
	end

	if not verticalAlignment then
		verticalAlignment = ui.Alignment.Center
	end

	if not flags then
		flags = ui.ButtonFlags.None
	end

	local sizeX, sizeY, buttonSize, fontSize

	if type(size) == "number" then
		size = size * scaleY
		sizeY = size
		fontSize = math.floor(sizeY * 0.45)
		fontSize = (fontSize % 2 ~= 0) and fontSize or fontSize + 1
		buttonSize = vec2Temp1:set(ui.measureDWriteText(string.upper(label), fontSize).x + 100 * cui.scaleY(), size)
	else
		sizeX = size.x
		sizeY = size.y
		fontSize = math.floor(sizeY * 0.45)
		fontSize = (fontSize % 2 ~= 0) and fontSize or fontSize + 1
		buttonSize = vec2Temp1(sizeX, sizeY)
	end

	local fontColor = active and rgbm(0, 0, 0, 1) or nil

	ui.pushStyleColor(ui.StyleColor.ButtonHovered, SETTINGS.uiColor2)
	ui.pushStyleColor(ui.StyleColor.ButtonActive, SETTINGS.uiColor2)

	if active then
		ui.pushStyleColor(ui.StyleColor.Button, SETTINGS.uiColor3)
	end

	if flags == ui.ButtonFlags.Disabled then
		fontColor = rgbm(0.6, 0.6, 0.6, 1)
		ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.05, 0.05, 0.05, 1))
	end

	local tempCursor = ui.getCursor()
	ui.button("##" .. label, buttonSize, flags)
	local hovered = ui.itemHovered()

	if flags == ui.ButtonFlags.Disabled then
		ui.popStyleColor(1)
	end

	if active then
		ui.popStyleColor(1)

		if ui.itemHovered() then
			ui.drawRect(tempCursor, tempCursor + buttonSize, SETTINGS.uiColor3)
		end
	end

	ui.popStyleColor(2)

	ui.sameLine()

	ui.offsetCursorY(1)
	ui.setCursor(tempCursor)
	ui.dwriteTextAligned(
		string.upper(label),
		fontSize,
		horizontalAligment,
		verticalAlignment,
		buttonSize,
		false,
		ui.itemHovered() and rgbm(1, 1, 1, 1) or fontColor
	)

	ui.popDWriteFont()

	return hovered and ac.getUI().isMouseLeftKeyClicked and not (flags == ui.ButtonFlags.Disabled)
end

function cui.modernButton(label, sizeX, sizeY, flags, icon)
	ui.modernButton(label, vec2(sizeX, sizeY) * scaleY, flags, icon, 16 * scaleY)
	local hovered = ui.itemHovered()
	return hovered and ac.getUI().isMouseLeftKeyClicked and not (flags == ui.ButtonFlags.Disabled)
end

function cui.iconButton(label, icon, sizeX, sizeY, flags)
	if not flags then
		flags = ui.ButtonFlags.None
	end

	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.25, 0.25, 0.25, 0.5))

	local tempCursorX = ui.getCursorX()

	ui.button("##" .. label, vec2(sizeX, sizeY) * scaleY, flags)
	local hovered = ui.itemHovered()

	ui.sameLine()
	ui.setCursorX(tempCursorX + 15 * scaleY)

	ui.dwriteTextAligned(
		label,
		14 * scaleX,
		ui.Alignment.Start,
		ui.Alignment.Center,
		vec2Temp1:set(sizeX, sizeY) * scaleY
	)

	ui.sameLine()
	ui.setCursorX(tempCursorX + 60 * scaleY)
	ui.icon(icon, vec2(sizeY, sizeY) * scaleY, nil, sizeY / 2 * scaleY)

	ui.popStyleColor(1)

	return hovered and ac.getUI().isMouseLeftKeyClicked and not (flags == ui.ButtonFlags.Disabled)
end

function cui.treeNodeButton(label, size, active, bold)
	if bold then
		ui.pushDWriteFont(fontBold)
	else
		ui.pushDWriteFont(fontRegular)
	end

	local fontSize = math.floor(size.y * 0.45)
	fontSize = (fontSize % 2 ~= 0) and fontSize or fontSize + 1
	local fontColor = active and rgbm(0, 0, 0, 1) or nil

	ui.pushStyleColor(ui.StyleColor.Button, bold and rgbm.colors.black or rgbm(0.1, 0.1, 0.1, 1))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, SETTINGS.uiColor2)
	ui.pushStyleColor(ui.StyleColor.ButtonActive, SETTINGS.uiColor2)

	if active then
		ui.pushStyleColor(ui.StyleColor.Button, SETTINGS.uiColor3)
	end

	local tempCursor = ui.getCursor()
	ui.button("##" .. label, size, ui.ButtonFlags.None)
	local hovered = ui.itemHovered()
	local id = ui.getLastID()

	if active then
		ui.popStyleColor(1)

		if hovered then
			ui.drawRect(tempCursor, tempCursor + size, SETTINGS.uiColor3)
		end
	end

	ui.popStyleColor(3)

	ui.sameLine()

	local textOffset = bold and size.x / 60 or size.x / 30
	ui.setCursor(tempCursor)
	ui.offsetCursorX(textOffset)
	ui.dwriteTextAligned(
		" " .. label,
		fontSize,
		ui.Alignment.Start,
		ui.Alignment.Center,
		vec2Temp1:set(size.x - textOffset, size.y),
		false,
		hovered and rgbm(1, 1, 1, 1) or fontColor
	)
	if bold then
		ui.addIcon(
			cui.loadStoredBool(id) and ui.Icons.Minus or ui.Icons.Plus,
			vec2Temp1:set(size.y / 2, size.y / 2),
			vec2Temp2:set(0.95, 0.5),
			nil
		)
	end

	ui.popDWriteFont()

	return (hovered and ac.getUI().isMouseLeftKeyClicked), id
end

function cui.treeNode(label, content)
	local clicked, id = cui.treeNodeButton(label, vec2Temp1:set(ui.availableSpaceX(), 50 * cui.scaleY()), false, true)

	local open = cui.loadStoredBool(id)
	if clicked then
		cui.storeBool(id, not open)
	end

	if open then
		ui.pushStyleVar(ui.StyleVar.ItemSpacing, 0)
		ui.beginGroup(ui.availableSpaceX())
		content()
		ui.endGroup()
		ui.popStyleVar(1)
	end

	return clicked
end

function cui.inputTextBox(label, stringInput, size)
	ui.pushDWriteFont(fontRegular)

	local fontSize = math.floor(size.y * 0.75)
	fontSize = (fontSize % 2 ~= 0) and fontSize or fontSize + 1

	local tempCursor = ui.getCursor()

	ui.pushStyleColor(ui.StyleColor.Button, rgbm.colors.white)
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm.colors.white)
	ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm.colors.white)
	local clicked = ui.button("##" .. label, size, ui.ButtonFlags.None)
	ui.popStyleColor(3)

	local id = ui.getLastID()
	local itemActive = cui.loadStoredBool(id)

	if itemActive == nil then
		cui.storeBool(id, false)
	end

	if clicked or ui.mouseClicked(ui.MouseButton.Left) then
		cui.storeBool(id, clicked)
	end

	ui.setCursor(tempCursor)
	local textOffset = size.x / 60
	ui.offsetCursorX(textOffset)
	ui.offsetCursorY(2)

	local text = (itemActive and math.floor(os.clock()) % 2 == 0) and stringInput .. "|" or stringInput
	ui.dwriteTextAligned(
		text,
		fontSize,
		ui.Alignment.Start,
		ui.Alignment.Center,
		vec2Temp1:set(size.x - textOffset, size.y),
		false,
		rgbm(0, 0, 0, 1)
	)

	ui.popDWriteFont()

	return clicked, itemActive
end

function cui.inputText(label, stringPrefix, stringInput, flags, size)
	local clicked, itemActive = cui.inputTextBox(label, stringPrefix .. stringInput, size)

	if not itemActive then
		return stringInput
	end

	local captured = ui.captureKeyboard(true, true, true)
	local charToAdd = nil

	if ui.keyPressed(ui.Key.Backspace) and #stringInput > 0 then
		stringInput = stringInput:sub(1, -2)
		audioTrigger()
	elseif #captured > 0 then
		charToAdd = captured:queue()

		if #charToAdd == 1 and charToAdd:match("[%w_ .;,><]") then
			stringInput = stringInput .. charToAdd
			audioTrigger()
		end
	end

	stringInput = stringInput:gsub("\n", "")

	return stringInput
end

function cui.dummy(x, y)
	ui.dummy(vec2Temp1:set(x * scaleY, y * scaleY))
end

local margins = 15

function cui.pushWindow(id, x, y, width, height, scroll)
	local windowFlags = ui.WindowFlags.NoResize

	if not scroll then
		windowFlags = windowFlags + ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse
	end

	local tabWidth = width
	local tabHeight = height

	ui.setCursorX(x)
	ui.setCursorY(y)

	ui.pushStyleVar(ui.StyleVar.WindowPadding, 0)
	ui.beginChild(id, vec2(tabWidth, tabHeight), true, windowFlags)

	if not scroll then
		ui.pushClipRect(vec2(0, 0), vec2(tabWidth, tabHeight))
	end

	ui.setCursorX(margins)
	ui.setCursorY(margins)

	ui.beginGroup(tabWidth)
end

function cui.popWindow(scroll)
	if not scroll then
		ui.popClipRect()
	end

	ui.endGroup()
	ui.endChild()
	ui.popStyleVar(1)
end

function cui.getWindow(windowName)
	local appWindows = ac.getAppWindows()
	local window = nil

	for i = 1, #appWindows do
		local app = appWindows[i]
		if app ~= nil and app.title == windowName and app.name ~= nil then
			window = ac.accessAppWindow(app.name)
		end
	end
	return window
end

return cui
