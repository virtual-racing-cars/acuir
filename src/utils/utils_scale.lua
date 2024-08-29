setCursorY = function(pos)
	ui.setCursorY(pos * UI_SCALE_Y / 100)
end

setCursorX = function(pos)
	ui.setCursorX(pos * UI_SCALE_X / 100)
end

childWindow = function(id, size, border, flags, content)
	ui.childWindow(id, size, false, flags, content)
end

contentWindow = function(id, title, position, size, flags, content)
	cui.pushWindow(id .. "test", position.x, position.y, size.x, size.y)
	ui.drawRectFilled(vec2(0, 0), size, settings.uiPrimaryColor, 0, ui.CornerFlags.None)

	ui.drawRectFilled(
		vec2(0, 0),
		vec2(size.x, 38 * UI_SCALE_Y / 100),
		rgbm(0.1, 0.1, 0.1, 0.25),
		0,
		ui.CornerFlags.None
	)
	ui.drawRectFilledMultiColor(
		vec2(0, 38),
		size,
		rgbm(1, 1, 1, 0.2),
		rgbm(1, 1, 1, 0.2),
		rgbm(0, 0, 0, 0),
		rgbm(0, 0, 0, 0)
	)

	setCursorX(0)
	setCursorY(0)
	ui.dwriteTextAligned(
		title,
		25 * UI_SCALE_Y / 100,
		ui.Alignment.Center,
		ui.Alignment.Start,
		size,
		false,
		rgbm.colors.white
	)

	content()

	setCursorX(0)
	setCursorY(0)

	ui.drawRect(vec2(0, 0), size, rgbm(0.3, 0.3, 0.3, 1), 0, ui.CornerFlags.None)

	cui.popWindow()
end
