local sim = ac.getSim()

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local cui = {}

local defaultWidth = 2560
local defaultHeight = 1440
local ratio = defaultWidth / defaultHeight
local windowMaxWidth = 0
local windowMaxHeight = 0
local currentScale = 1
local itemSpacing = 5

local scaleX = sim.windowWidth / 2560
local scaleY = sim.windowHeight / 1440

function cui.bestFit()
	windowMaxWidth = math.clamp(ui.windowWidth(), 0, ui.windowHeight() * ratio)
	windowMaxHeight = math.clamp(ui.windowHeight(), 0, ui.windowWidth() / ratio)

	scaleX = windowMaxWidth / defaultHeight
	scaleY = windowMaxHeight / defaultHeight

	currentScale = ui.windowHeight() / defaultHeight
	itemSpacing = 5 * currentScale
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

	local clicked = false

	local textWidth = ui.measureDWriteText(string.upper(label), fontSize * scaleX).x

	local fontColor = fontColor

	if flags == ui.ButtonFlags.Disabled then
		fontColor = rgbm(0.6, 0.6, 0.6, 1)
		ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.05, 0.05, 0.05, 1))
	end

	local tempCursor = ui.getCursor()
	if ui.button("##" .. label, vec2Temp1:set(textWidth + 30 * scaleX, sizeY * scaleY), flags) then
		clicked = true
	end

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

	return clicked
end

function cui.settingsButton(label, sizeX, sizeY, flags)
	sizeX = sizeX * scaleX
	sizeY = sizeY * scaleY

	local clicked = false

	local fontSize = 35 * scaleY

	local disabled = flags == ui.ButtonFlags.Disabled

	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.231373, 0.223529, 0.262745, 1))
	ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 0, 0, 1))
	ui.pushStyleColor(ui.StyleColor.ButtonActive, rgbm(1, 0, 0, 1))

	local tempCursor = ui.getCursor()
	if ui.button("##" .. label, vec2Temp1:set(sizeX, sizeY), flags) then
		clicked = true
	end
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

	return clicked
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

	size = size * scaleY

	local clicked = false

	local fontSize = size / 2.5
	local textWidth = ui.measureDWriteText(string.upper(label), fontSize).x + 100 * scaleY

	local fontColor = active and rgbm(0, 0, 0, 1) or nil

	ui.pushStyleColor(ui.StyleColor.ButtonHovered, rgbm(1, 0, 0, 1))

	if flags == ui.ButtonFlags.Disabled then
		fontColor = rgbm(0.6, 0.6, 0.6, 1)
		ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.05, 0.05, 0.05, 1))
	end

	local tempCursor = ui.getCursor()
	if ui.button("##" .. label, vec2Temp1:set(textWidth, size), flags) then
		clicked = true
	end

	if flags == ui.ButtonFlags.Disabled then
		ui.popStyleColor(1)
	end

	ui.popStyleColor(1)

	ui.sameLine()

	ui.offsetCursorY(1)
	ui.setCursor(tempCursor)
	ui.dwriteTextAligned(
		string.upper(label),
		fontSize,
		horizontalAligment,
		verticalAlignment,
		vec2Temp1:set(textWidth, size),
		false,
		ui.itemHovered() and rgbm(1, 1, 1, 1) or fontColor
	)

	ui.popDWriteFont()

	return clicked
end

function cui.modernButton(label, sizeX, sizeY, flags, icon)
	if ui.modernButton(label, vec2(sizeX, sizeY) * scaleY, flags, icon, 16 * scaleY) then
		return true
	end

	return false
end

function cui.iconButton(label, icon, sizeX, sizeY, flags)
	if not flags then
		flags = ui.ButtonFlags.None
	end

	ui.pushStyleColor(ui.StyleColor.Button, rgbm(0.25, 0.25, 0.25, 0.5))

	local clicked = false

	local tempCursorX = ui.getCursorX()

	if ui.button("##" .. label, vec2(sizeX, sizeY) * scaleY, flags) then
		clicked = true
	end

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

	return clicked
end

function cui.dummy(x, y)
	ui.dummy(x * scaleY, y * scaleY)
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
