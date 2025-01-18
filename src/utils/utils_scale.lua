setCursorY = function(pos)
	ui.setCursorY(pos * UI_SCALE_Y / 100)
end

setCursorX = function(pos)
	ui.setCursorX(pos * UI_SCALE_X / 100)
end

childWindow = function(id, size, border, flags, content)
	ui.childWindow(id, size, false, flags, content)
end

contentWindow = function(id, title, position, size, flags, content, showTitle)
	cui.pushWindow(id .. "test", position.x, position.y, size.x, size.y)
	size = size * cui.scaleY()
	ui.drawRectFilled(vec2(0, 0), size, settings.uiPrimaryColor)

	-- ui.drawRectFilled(vec2(0, 0), size, rgbm(0.1, 0.1, 0.1, 0.25), 10, ui.CornerFlags.Top)
	-- ui.drawRectFilledMultiColor(
	-- 	vec2(0, 38),
	-- 	size,
	-- 	rgbm(1, 1, 1, 0.2),
	-- 	rgbm(1, 1, 1, 0.2),
	-- 	rgbm(0, 0, 0, 0),
	-- 	rgbm(0, 0, 0, 0)
	-- )

	if showTitle then
		setCursorX(0)
		setCursorY(15)
		ui.dwriteTextAligned(
			title,
			25 * cui.scaleY(),
			ui.Alignment.Center,
			ui.Alignment.Start,
			size,
			false,
			rgbm.colors.white
		)
	end

	content()

	-- ui.drawRect(vec2(0, 0), size, rgbm(0.3, 0.3, 0.3, 1), 10, ui.CornerFlags.All)

	cui.popWindow()
end
