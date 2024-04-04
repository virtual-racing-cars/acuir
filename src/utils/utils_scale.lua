setCursorY = function(pos)
	ui.setCursorY(pos * UI_SCALE_Y / 100)
end

setCursorX = function(pos)
	ui.setCursorX(pos * UI_SCALE_X / 100)
end

-- local scale = {}

-- function scale()

-- end

childWindow = function(id, size, border, flags, content)
	ui.childWindow(id, size, false, flags, function()
		content()
	end)
end

contentWindow = function(id, title, size, flags, content)
	ui.childWindow(id, size, false, flags, function()
		ui.drawRectFilled(vec2(0, 0), ui.availableSpace(), settings.uiPrimaryColor, 0, ui.CornerFlags.None)

		ui.drawRectFilled(
			vec2(0, 0),
			vec2(ui.availableSpaceX(), 38 * UI_SCALE_Y / 100),
			rgbm(0.1, 0.1, 0.1, 0.25),
			0,
			ui.CornerFlags.None
		)
		ui.drawRectFilledMultiColor(
			vec2(0, 38 * UI_SCALE_Y / 100),
			vec2(ui.availableSpaceX(), ui.availableSpaceY()),
			rgbm(1, 1, 1, 0.2),
			rgbm(1, 1, 1, 0.2),
			rgbm(0, 0, 0, 0),
			rgbm(0, 0, 0, 0)
		)

		setCursorY(0)
		ui.dwriteTextAligned(
			title,
			25 * UI_SCALE_Y / 100,
			ui.Alignment.Center,
			ui.Alignment.Start,
			ui.availableSpace(),
			false,
			rgbm.colors.white
		)

		content()

		setCursorX(0)
		setCursorY(0)

		ui.drawRect(vec2(0, 0), ui.availableSpace(), rgbm(0.3, 0.3, 0.3, 1), 0, ui.CornerFlags.None)
	end)
end
