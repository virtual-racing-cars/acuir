local scaleX = 1
local scaleY = 1

local vec2Temp1 = vec2()
local vec2Temp2 = vec2()

local cui = {}

function cui.setScale(x, y)
	scaleX = x
	scaleY = y
end

function cui.setScaleX(x)
	scaleX = x
end

function cui.setScaleY(y)
	scaleY = y
end

local defaultWidth = 1020
local defaultHeight = 510
local ratio = defaultWidth / defaultHeight
local windowMaxWidth = 0
local windowMaxHeight = 0
local currentScale = 1
local itemSpacing = 5

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
	ui.offsetCursorY(v * scaleX)
end

function cui.button(label, sizeX, sizeY, fontSize, horizontalAligment, verticalAlignment, flags)
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

	local tempCursorX = ui.getCursorX()
	if ui.button("##" .. label, vec2Temp1:set(sizeX * scaleX, sizeY * scaleY), flags) then
		clicked = true
	end
	ui.sameLine()
	ui.offsetCursorY(1)
	ui.setCursorX(tempCursorX)
	ui.dwriteTextAligned(
		label,
		fontSize * scaleX,
		horizontalAligment,
		verticalAlignment,
		vec2Temp1:set(sizeX * scaleX, sizeY * scaleY)
	)

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

function cui.pushTabWindow(id, x, y, width, height, scroll)
	local windowFlags = ui.WindowFlags.NoResize

	if not scroll then
		windowFlags = windowFlags + ui.WindowFlags.NoScrollbar + ui.WindowFlags.NoScrollWithMouse
	end

	local tabX = x * scaleX
	local tabY = y * scaleY
	local tabWidth = width * scaleX
	local tabHeight = height * scaleY

	ui.setCursorX(tabX)
	ui.setCursorY(tabY)

	ui.pushStyleVar(ui.StyleVar.WindowPadding, 0)
	ui.beginChild(id, vec2(tabWidth, tabHeight), true, windowFlags)

	if not scroll then
		ui.pushClipRect(vec2(0, 0), vec2(tabWidth, tabHeight))
	end

	ui.setCursorX(margins * scaleY)
	ui.setCursorY(margins * scaleY)

	ui.beginGroup(tabWidth)
end

function cui.popTabWindow(scroll)
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
